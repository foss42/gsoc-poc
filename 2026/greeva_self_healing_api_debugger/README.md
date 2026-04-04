# ⚡ Agentic Self-Healing API Debugger

🚀 Built by Greeva Patel as part of GSoC 2026 PoC for API Dash.

---

## 🧠 Overview

This project demonstrates an **agent-based self-healing API debugging system** that:

- Detects API failures
- Analyzes errors
- Automatically applies fixes
- Retries requests until success

---

## ⚙️ Architecture

Pipeline:

Executor → Analyzer → Fixer → Retry → Evaluation

---

## 🔥 Features

- Automatic API error detection (404, invalid endpoints)
- Intelligent URL correction (pluralization, fuzzy matching)
- Self-healing retry mechanism
- Visual debugging UI (React + Tailwind)
- Step-by-step agent pipeline execution

---

## 🎥 Demo Video

👉 https://drive.google.com/file/d/1uX3yqTJDTSeXKvV-O7WwmcrRL8U6G-9J/view?usp=sharing

---

## 💻 GitHub Repository

👉 https://github.com/Greeva48/api-self-healing-debugger

---

## 🧪 Example

### Input
```
https://jsonplaceholder.typicode.com/post
```

### Output
```
Detected: Endpoint not found  
Fix applied: /post → /posts  
Status: 200 OK
```

---

## 🚀 How to Run Locally

### Backend

```bash
node server.js
```

### Frontend

```bash
cd client
npm install
npm run dev
```

---

## 🏆 Why This Matters

This is not just a debugger.

It is a **self-healing agent system** capable of:
- Understanding failures
- Taking corrective action
- Improving reliability automatically

---

## 👩‍💻 Author

**Greeva Patel**
