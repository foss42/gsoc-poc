"""Evaluation API routes — start eval, stream progress."""

from __future__ import annotations

import asyncio
import json
from typing import Any

from fastapi import APIRouter, HTTPException
from sse_starlette.sse import EventSourceResponse

from eval_datasets.loader import DatasetRow
from evaluators.image_understanding import ImageUnderstandingEvaluator
from evaluators.image_generation import ImageGenerationEvaluator
from evaluators.audio_stt import AudioSTTEvaluator
from evaluators.text_eval import TextEvaluator
from jobs import db
from jobs.executor import run_evaluation
from jobs.models import EvalRequest, EvalConfig
from metrics.text_similarity import ExactMatchMetric, ContainsMatchMetric, BLEUMetric
from metrics.rouge import ROUGEMetric
from metrics.llm_judge import LLMJudgeMetric
from metrics.wer_cer import WERMetric, CERMetric
from providers.base import TaskKind
from providers.registry import registry

router = APIRouter(tags=["evaluation"])

# SSE heartbeat interval in seconds — keeps proxies from closing idle connections
_HEARTBEAT_INTERVAL = 15.0


def _get_evaluator(modality: str):
    """Get the evaluator for a given modality."""
    text_metrics = [ExactMatchMetric(), ContainsMatchMetric(), BLEUMetric(), ROUGEMetric()]

    if modality == TaskKind.IMAGE_UNDERSTANDING:
        return ImageUnderstandingEvaluator(metrics=text_metrics)

    if modality == TaskKind.IMAGE_GENERATION:
        judge = registry.get("openai")
        if judge is None:
            raise HTTPException(
                status_code=400,
                detail="OpenAI provider required as LLM judge for image generation eval",
            )
        return ImageGenerationEvaluator(metrics=[LLMJudgeMetric()], judge_provider=judge)

    if modality == TaskKind.AUDIO_STT:
        return AudioSTTEvaluator(metrics=[WERMetric(), CERMetric()])

    if modality == TaskKind.AUDIO_TTS:
        try:
            from evaluators.audio_tts import AudioTTSEvaluator
            judge = registry.get("openai")
            if judge is None:
                raise HTTPException(
                    status_code=400,
                    detail="OpenAI provider required as LLM judge for audio TTS eval",
                )
            return AudioTTSEvaluator(metrics=[LLMJudgeMetric()], judge_provider=judge)
        except ImportError:
            raise HTTPException(status_code=501, detail="AudioTTS evaluator not available")

    if modality == TaskKind.VIDEO_UNDERSTANDING:
        try:
            from evaluators.video_understanding import VideoUnderstandingEvaluator
            return VideoUnderstandingEvaluator(metrics=text_metrics)
        except ImportError:
            raise HTTPException(status_code=501, detail="VideoUnderstanding evaluator not available")

    if modality == TaskKind.TEXT:
        return TextEvaluator(metrics=text_metrics)

    # Unknown modality — fail fast instead of silently using the wrong evaluator
    raise HTTPException(
        status_code=400,
        detail=f"Unknown modality '{modality}'. Valid values: "
               + ", ".join(t.value for t in TaskKind),
    )


# Per-job event queues: job_id → asyncio.Queue of dicts (None = stream ended)
_job_queues: dict[str, asyncio.Queue] = {}
# Background tasks held to prevent GC
_job_tasks: dict[str, asyncio.Task] = {}


async def _run_job_background(
    job_id: str,
    queue: asyncio.Queue,
    gen,
) -> None:
    """Drive the evaluation generator in a background task and push events to the queue."""
    try:
        async for event in gen:
            await queue.put(event)
    except Exception as exc:
        import traceback
        traceback.print_exc()
        await queue.put({
            "event": "error",
            "data": json.dumps({"error": str(exc), "type": type(exc).__name__}),
        })
    finally:
        await queue.put(None)  # Sentinel: evaluation finished
        _job_tasks.pop(job_id, None)


@router.post("/eval")
async def start_evaluation(req: EvalRequest) -> dict[str, Any]:
    """Start a new evaluation job. The job runs immediately in the background."""

    # Validate dataset exists
    ds = await db.get_dataset(req.dataset_id)
    if not ds:
        raise HTTPException(status_code=404, detail="Dataset not found")

    # Validate providers
    provider_pairs = []
    for p_sel in req.providers:
        provider = registry.get(p_sel.id)
        if not provider:
            raise HTTPException(status_code=400, detail=f"Provider '{p_sel.id}' not found")
        provider_pairs.append((provider, p_sel.model))

    # Load dataset items
    raw_items = await db.get_dataset_items(req.dataset_id)
    items = [
        DatasetRow(
            index=item["seq_index"],
            task_kind=item["task_kind"],
            prompt=item["prompt_text"],
            expected_text=item["expected_text"],
            media_path=item["media_path"],
            media_type=item["media_type"],
        )
        for item in raw_items
    ]

    total = len(items) * len(provider_pairs)

    # Merge eval_config params into the config dict so evaluators pass them to providers
    merged_config = dict(req.config)
    ec: EvalConfig = req.eval_config or EvalConfig()
    if ec.temperature is not None:
        merged_config["temperature"] = ec.temperature
    if ec.max_tokens is not None:
        merged_config["max_tokens"] = ec.max_tokens
    if ec.system_prompt:
        merged_config["system_prompt"] = ec.system_prompt

    # Create job in DB
    job_id = await db.create_job(
        name=req.name,
        dataset_id=req.dataset_id,
        modality=req.modality,
        providers=[p.model_dump() for p in req.providers],
        config=merged_config,
        total=total,
        temperature=ec.temperature,
        max_tokens=ec.max_tokens,
        system_prompt=ec.system_prompt,
    )

    # Get evaluator (raises HTTP 400 for unknown modality)
    evaluator = _get_evaluator(req.modality)

    # Create a queue and kick off evaluation immediately as a background asyncio task.
    # Previously the generator was lazy and only ran when a client connected to the SSE
    # endpoint — meaning the job would never start if the client delayed or never connected.
    queue: asyncio.Queue = asyncio.Queue()
    _job_queues[job_id] = queue

    gen = run_evaluation(
        job_id=job_id,
        items=items,
        providers=provider_pairs,
        evaluator=evaluator,
        config=merged_config,
    )
    task = asyncio.create_task(_run_job_background(job_id, queue, gen))
    _job_tasks[job_id] = task  # hold reference to prevent GC

    return {
        "job_id": job_id,
        "status": "pending",
        "stream_url": f"/api/eval/{job_id}/stream",
    }


@router.get("/eval/{job_id}/stream")
async def stream_evaluation(job_id: str):
    """SSE stream of evaluation progress with heartbeat to keep proxy connections alive."""
    queue = _job_queues.get(job_id)
    if not queue:
        raise HTTPException(status_code=404, detail="Job stream not found or already completed")

    async def event_generator():
        try:
            while True:
                try:
                    event = await asyncio.wait_for(
                        queue.get(), timeout=_HEARTBEAT_INTERVAL
                    )
                except asyncio.TimeoutError:
                    # Send a keepalive ping so the connection isn't closed by proxies
                    yield {"event": "ping", "data": json.dumps({"ts": asyncio.get_event_loop().time()})}
                    continue

                if event is None:  # Sentinel — evaluation finished
                    _job_queues.pop(job_id, None)
                    break
                yield event
        except Exception as exc:
            import traceback
            traceback.print_exc()
            yield {
                "event": "error",
                "data": json.dumps({"error": str(exc), "type": type(exc).__name__}),
            }
        finally:
            _job_queues.pop(job_id, None)

    return EventSourceResponse(event_generator())
