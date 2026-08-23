# 🚀 API Dash MCP Server

[![npm version](https://img.shields.io/npm/v/apidash-mcp.svg)](https://www.npmjs.com/package/apidash-mcp)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

The official **Model Context Protocol (MCP)** bridge for [API Dash](https://github.com/foss42/apidash). 

This server enables AI assistants (like Claude, Roo Code, or Cline) to autonomously draft, inspect, and execute HTTP requests directly through your local API Dash native engine. By running a seamless background bridge, your AI gets full programmatic access to API Dash's execution capabilities, history ledger, and interactive studio canvas.

---

## Prerequisites

1.  **Node.js**: You must have Node.js and `npx` installed on your machine.
2.  **API Dash Desktop App**: You must have the API Dash native application installed.

---

## Configuration & Setup

Because this MCP server communicates directly with the native API Dash Flutter engine, it needs to know where your `apidash` executable is located. 

You can configure this in one of two ways:

### Option A: Add to System PATH (Recommended)
If API Dash is in your global system PATH, the server will find it automatically. No extra configuration is needed in your MCP client!

*   **Windows:** Press `Win` > search "Environment Variables" > click "Environment Variables..." > edit "Path" under System/User variables > add the folder containing `apidash.exe`.
*   **macOS/Linux:** Add `export PATH="$PATH:/path/to/apidash_folder"` to your `~/.zshrc` or `~/.bashrc` file, then restart your terminal.

**Example for VS Code:**
```json
{
	"servers": {
		"apidash": {
      "command": "npx",
      "args": [
        "-y",
        "apidash-mcp@latest"
      ]
    }
	}
}
```

### Option B: Configure via `APIDASH_PATH` Environment Variable
If you prefer not to modify your system PATH, you can explicitly pass the exact path to the executable inside your AI client's MCP configuration file (e.g., `mcp.json` or `cline_mcp_settings.json`).

**Example for VS Code:**
```json
{
  "servers": {
    "apidash": {
      "command": "npx",
      "args": [
        "-y",
        "apidash-mcp@latest"
      ],
      "env": {
        "APIDASH_PATH": "C:\\Your\\Path\\To\\apidash.exe"
      }
    }
  }
}
```

*(Note: On Windows, remember to escape your backslashes `\\` in JSON!)*

---

## Available MCP Tools

Once successfully connected, the server dynamically registers the following tools with your AI assistant:

*   **`apidash_execute_request`**: Executes HTTP requests (GET, POST, PUT, DELETE, etc.). Accepts URLs, methods, headers, and body payloads.
*   **`apidash_get_results`**: Fetches runtime execution payloads for UI hydration.
*   **`apidash_list_history`**: Retrieves historical execution runs from the local database layer.
*   **`apidash_delete_request`**: Safely deletes a history record by its execution ID.
*   **`apidash_launch_workbench`**: Instructs the system to open the main interactive API Dash visual studio UI.
*   **`apidash_btn_send`**: Triggered upon clicking 'Send' inside the visual studio workspace to run an agentic pre-flight sanity check on the draft payload.

---

## Troubleshooting

### `[FATAL ERROR]: API Dash executable not found`
If the bridge cannot locate your API Dash engine, it will instantly shut down and output a highly visible error in your client's logs. Ensure that you have followed **Option A** or **Option B** above, and completely restart your AI client or VS Code window to apply changes.

### Unformatted `[Engine Log]` output in client logs
When inspecting the MCP server logs in your client, you may see raw text like `[Engine Log]: package:media_kit...`. **This is completely normal.** The server safely routes native engine initialization logs to `stderr` to protect the JSON-RPC communication stream on `stdout`. Your AI agent is still successfully connected!

### Leftover Background Processes
If you force-quit your editor and the API Dash engine gets orphaned in the background, you can easily clean it up:
*   **Windows (PowerShell):** `taskkill /F /IM apidash.exe`

---

## 📄 License & Links

*   **GitHub Repository**: [foss42/apidash](https://github.com/foss42/apidash)
*   **License**: Apache-2.0