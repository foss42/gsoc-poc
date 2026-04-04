"""ROUGE-L metric for text similarity evaluation."""

from __future__ import annotations

from metrics.base import Metric, MetricContext, MetricResult
from providers.base import TaskKind


class ROUGEMetric(Metric):
    """ROUGE-L F1 score — measures longest common subsequence overlap."""

    id = "rouge_l"
    name = "ROUGE-L"
    applicable_tasks = [
        TaskKind.IMAGE_UNDERSTANDING,
        TaskKind.AUDIO_STT,
        TaskKind.VIDEO_UNDERSTANDING,
        TaskKind.TEXT,
    ]
    higher_is_better = True

    async def evaluate(self, context: MetricContext) -> MetricResult:
        if not context.expected_text or not context.provider_result.text_output:
            return MetricResult(
                metric_id=self.id,
                score=0.0,
                explanation="Missing expected or actual text",
            )

        try:
            from rouge_score import rouge_scorer

            scorer = rouge_scorer.RougeScorer(["rougeL"], use_stemmer=True)
            scores = scorer.score(
                context.expected_text.strip(),
                context.provider_result.text_output.strip(),
            )
            f1 = scores["rougeL"].fmeasure
            return MetricResult(
                metric_id=self.id,
                score=round(f1, 4),
                raw_value=round(f1, 4),
                details={
                    "precision": round(scores["rougeL"].precision, 4),
                    "recall": round(scores["rougeL"].recall, 4),
                    "f1": round(f1, 4),
                },
            )
        except ImportError:
            # Fallback: manual LCS-based ROUGE-L when rouge_score is not installed
            return self._manual_rouge_l(
                context.expected_text.strip(),
                context.provider_result.text_output.strip(),
            )

    @staticmethod
    def _lcs_length(a: list[str], b: list[str]) -> int:
        """Compute the length of the longest common subsequence."""
        m, n = len(a), len(b)
        # Use O(n) space DP
        prev = [0] * (n + 1)
        for i in range(1, m + 1):
            curr = [0] * (n + 1)
            for j in range(1, n + 1):
                if a[i - 1] == b[j - 1]:
                    curr[j] = prev[j - 1] + 1
                else:
                    curr[j] = max(curr[j - 1], prev[j])
            prev = curr
        return prev[n]

    def _manual_rouge_l(self, reference: str, hypothesis: str) -> MetricResult:
        ref_tokens = reference.lower().split()
        hyp_tokens = hypothesis.lower().split()
        if not ref_tokens or not hyp_tokens:
            return MetricResult(metric_id=self.id, score=0.0)
        lcs = self._lcs_length(ref_tokens, hyp_tokens)
        precision = lcs / len(hyp_tokens)
        recall = lcs / len(ref_tokens)
        f1 = (2 * precision * recall / (precision + recall)) if (precision + recall) > 0 else 0.0
        return MetricResult(
            metric_id=self.id,
            score=round(f1, 4),
            raw_value=round(f1, 4),
            details={"precision": round(precision, 4), "recall": round(recall, 4), "f1": round(f1, 4)},
            explanation="rouge_score not installed — computed via manual LCS",
        )
