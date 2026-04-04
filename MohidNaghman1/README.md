# AI Model Evaluation PoC — Mohid Naghman

**GSoC 2026 · API Dash · Multimodal AI and Agent API Evaluation Framework**

## 🎬 Demo
👉 https://youtu.be/FawtOMIb_pA

## PoC Repository
👉 https://github.com/MohidNaghman1/eval-mcp-poc

## What This Builds
Multi-provider LLM evaluation (Groq + Gemini + Mistral) with:
- Concurrent asyncio execution
- BLEU + Exact Match metrics  
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