# AI Model Evaluation Framework — MCP Apps PoC

**GSoC 2026 Proof of Concept**
**Student:** Rana Awais Ahmad
**Project:** End-to-End Multimodal AI & Agent Evaluation Framework
**Mentor:** @animator

---

## Overview

This PoC demonstrates how an **AI Evaluation UI** can be built using the **MCP Apps chatflow** architecture — the same pattern used in the [sample-mcp-apps-chatflow](https://github.com/ashitaprasad/sample-mcp-apps-chatflow) reference project.

Instead of a sales analytics workflow, this PoC adapts the MCP Apps pattern to serve an **AI model benchmarking use case** — where users can select models, datasets, and metrics, trigger evaluations, and view results — all from inside an AI Agent chat window (VS Code Insiders + GitHub Copilot).

This directly addresses the mentor's requirement:

> *"Explore if AI evaluation UI can be built using MCP Apps to make it easy for end users to run evals from inside AI agents."*

---
<img width="1499" height="890" alt="Screenshot 2026-04-04 092249" src="https://github.com/user-attachments/assets/bde1579a-4c74-49a3-b0c8-c46aff44c02a" />

## Demo

### 1. Agent retrieves eval config via MCP tool

User types `get eval config` → Agent calls `select-eval-config` tool → returns available models, datasets, and metrics from the MCP server.



---

### 2. Agent fetches evaluation data & MCP server runs

Agent calls `get-eval-data` tool with selected parameters → MCP server (`ai-eval-poc`) runs evaluation → results returned to agent context. Terminal confirms server is running with **3 tools discovered**.

<img width="1882" height="912" alt="Screenshot 2026-04-04 094021" src="https://github.com/user-attachments/assets/a83cb77c-9f69-46cc-bc76-4e03e42f3fa1" />


---

### 3. Agent displays evaluation report

Agent calls `show-eval-report` tool → returns benchmark results table with Accuracy, Latency, Cost, and F1 Score for each model.

<img width="1065" height="899" alt="image" src="https://github.com/user-attachments/assets/db32164a-675f-4c36-977f-4a316c13029f" />


---

## Architecture

```
User (VS Code Chat)
        │
        ▼
  AI Agent (Copilot)
        │  calls MCP tools
        ▼
  MCP Server (ai-eval-poc)
  ┌─────────────────────────────────┐
  │  Tool 1: select-eval-config     │  ← Shows available models/datasets/metrics
  │  Tool 2: get-eval-data          │  ← Fetches benchmark results (internal)
  │  Tool 3: show-eval-report       │  ← Returns results table to agent
  └─────────────────────────────────┘
        │
        ▼
  UI Resources (HTML widgets)
  ┌─────────────────────────────────┐
  │  eval-form.ts   → eval-form     │  ← Interactive config selector
  │  eval-report.ts → eval-report   │  ← Results viewer
  └─────────────────────────────────┘
```

**Pattern adopted from:** [sample-mcp-apps-chatflow](https://github.com/ashitaprasad/sample-mcp-apps-chatflow)
- `select-sales-metric` → `select-eval-config`
- `get-sales-data` → `get-eval-data`
- `show-sales-pdf-report` → `show-eval-report`

---

## Project Structure

```
awaisranahmad_ai_eval_poc/
├── src/
│   ├── index.ts              ← MCP server — tool & resource registration
│   └── ui/
│       ├── eval-form.ts      ← Eval config selector widget (HTML)
│       └── eval-report.ts    ← Benchmark results viewer (HTML)
├── dist/                     ← Compiled JS (auto-generated)
├── .vscode/
│   └── mcp.json              ← VS Code MCP server config
├── package.json
├── tsconfig.json
└── README.md
```

---

## MCP Tools

| Tool | Description | Visibility |
|------|-------------|------------|
| `select-eval-config` | Opens evaluation configuration panel | Agent |
| `get-eval-data` | Fetches benchmark data for selected models | Agent + App |
| `show-eval-report` | Displays results table with all metrics | Agent |

## Supported Options

**Models:** GPT-4o, Claude Sonnet 4.5, Gemini 1.5 Pro, LLaMA 3 70B

**Datasets:** MMLU, HellaSwag, GSM8K, HumanEval, TruthfulQA

**Metrics:** Accuracy, Latency (s), Cost/Token, F1 Score

---

## Setup & Run

### Prerequisites
- Node.js 18+
- VS Code Insiders
- GitHub Copilot (free plan works)

### Install & Build

```bash
git clone https://github.com/foss42/gsoc-poc
cd 2026/awaisranahmad_ai_eval_poc
npm install
npm run build
```

### Configure VS Code

`.vscode/mcp.json` is already included:

```json
{
  "servers": {
    "ai-eval-poc": {
      "type": "stdio",
      "command": "node",
      "args": ["${workspaceFolder}/dist/index.js"]
    }
  }
}
```

Open project in VS Code Insiders — the MCP server starts automatically.

### Test in Agent Chat

Open Copilot Chat → select **Agent** mode → try:

```
get eval config
```
```
call the tool get-eval-data with models gpt-4o and claude-3-5-sonnet, dataset mmlu, metrics accuracy and latency
```
```
call the tool show-eval-report
```

---

## Connection to Proposed GSoC Project

This PoC directly validates the core technical components of my GSoC proposal:

| Proposal Component | PoC Validation |
|---|---|
| MCP Apps chatflow architecture | ✅ Implemented — 3 tools, 2 UI resources |
| Multimodal eval UI inside AI agent | ✅ Runs inside VS Code Copilot Agent |
| Structured data flow between tools | ✅ `get-eval-data` passes structured results to agent context |
| Real-time metrics (Accuracy, Latency, Cost, F1) | ✅ All 4 metrics returned in benchmark table |
| TypeScript MCP server | ✅ Built with `@modelcontextprotocol/sdk` |

The full GSoC project would extend this with: Flutter UI, FastAPI backend, `lm-harness` integration, SSE streaming, and multi-modal support (Image/Audio/Text).

---

## References

- [sample-mcp-apps-chatflow](https://github.com/ashitaprasad/sample-mcp-apps-chatflow) — Reference implementation by mentor
- [How I built MCP Apps based Sales Analytics Agentic UI](https://dev.to/aws/how-i-built-mcp-apps-based-sales-analytics-agentic-ui-deployed-it-on-amazon-bedrock-agentcore-4e9i) — Article by @ashitaprasad
- [MCP Apps Protocol](https://github.com/modelcontextprotocol/ext-apps) — Official spec
- [GSoC 2026 Proposal](https://github.com/foss42/api-dash) — API Dash

---

*Built by Rana Awais Ahmad — GSoC 2026 applicant for API Dash (foss42)*
