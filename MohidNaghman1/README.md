# AI Model Evaluation PoC — Mohid Naghman

**GSoC 2026 · API Dash · Multimodal AI and Agent API Evaluation Framework**

## 🎬 Demo

👉 https://youtu.be/jxZyAHhV2Wk

## PoC Repository

👉 https://github.com/MohidNaghman1/POC_Ai-Models-Eval_Gsoc

## What This Builds

Multi-provider LLM evaluation (Groq + Mistral) with:

- Concurrent asyncio execution
- BLEU + ROUGE-L + Exact Match metrics
- MCP Apps chat widget integration
- CSV upload → evaluate → export pipeline

## Run Locally

```bash
pip install -r backend/requirements.txt
cp .env.example .env
python backend/main.py
# Open http://localhost:8000
```

**Mohid Naghman** · mohidnaghman0@email.com
