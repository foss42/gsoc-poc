#!/usr/bin/env node

const { spawn, execSync } = require('child_process');
const readline = require('readline');
const fs = require('fs');
const os = require('os');

const platform = os.platform();
let flutterEngine;
let isShuttingDown = false;

// --- INTERCEPT CLI HELP COMMAND ---
if (process.argv.includes('--help') || process.argv.includes('-h')) {
    process.stdout.write(`
🚀 API Dash MCP Server (v1.0.1)
===============================
The official Model Context Protocol (MCP) bridge for API Dash.

USAGE:
  npx apidash-mcp

DESCRIPTION:
  This server enables AI assistants to autonomously draft, inspect, and 
  execute HTTP requests directly through the local API Dash native engine.

AVAILABLE MCP TOOLS:
  - apidash_execute_request  : Executes HTTP requests (GET, POST, etc.)
  - apidash_get_results      : Fetches execution payloads for UI hydration
  - apidash_list_history     : Retrieves the historical execution ledger
  - apidash_delete_request   : Deletes a specific history record
  - apidash_launch_workbench : Opens the interactive API Dash Studio UI
  - apidash_btn_send         : Agentic pre-flight sanity check for drafts

GitHub: https://github.com/foss42/apidash
\n`);
    process.exit(0);
}

// 1. Dumb, reliable path resolution
function getEnginePath() {
    // Check 1: Explicit Environment Variable (Most reliable)
    const envPath = process.env.APIDASH_PATH;
    if (envPath && fs.existsSync(envPath)) {
        return envPath;
    }

    // Check 2: System PATH
    try {
        const checkCmd = platform === 'win32' ? 'where apidash' : 'which apidash';
        execSync(checkCmd, { stdio: 'ignore' });
        return 'apidash';
    } catch (e) {}

    // Check 3: Standard Windows AppData location
    const defaultWinPath = `${process.env.LOCALAPPDATA}\\APIDash\\apidash.exe`;
    if (platform === 'win32' && fs.existsSync(defaultWinPath)) {
        return defaultWinPath;
    }

    // If all fail, throw a highly visible error.
    process.stderr.write(`
[FATAL ERROR]: API Dash executable not found.
--------------------------------------------------
The MCP bridge requires the API Dash engine to run natively.

HOW TO FIX:

Option A: Add API Dash to your Global System PATH
  - Windows: Press Win key > search "Environment Variables" > click "Environment Variables..." > edit "Path" under System/User variables > add the folder containing apidash.exe.
  - macOS/Linux: Add 'export PATH="$PATH:/path/to/apidash_folder"' to your ~/.zshrc or ~/.bashrc file, then restart your terminal.

Option B: Set APIDASH_PATH in your MCP client configuration
  1. Open the Command Palette in VS Code (Ctrl+Shift+P or Cmd+Shift+P).
  2. Type and select: "MCP: Open User Configuration".
  3. Add the following complete JSON block, replacing the path with your actual apidash.exe location:

{
  "servers": {
    "apidash-production": {
      "command": "npx",
      "args": [
        "-y",
        "apidash-mcp@latest"
      ],
      "env": {
        "APIDASH_PATH": "C:\\\\Your\\\\Path\\\\To\\\\apidash.exe"
      }
    }
  }
}
--------------------------------------------------\n`);
    process.exit(1);
}

// -----------------------------------------------------------------
// Main Execution Start
// -----------------------------------------------------------------
const EXE_COMMAND = getEnginePath();

flutterEngine = spawn(EXE_COMMAND, ['--mcp-engine'], {
    stdio: ['pipe', 'pipe', 'inherit']
});

process.stdin.pipe(flutterEngine.stdin);

const rl = readline.createInterface({
    input: flutterEngine.stdout,
    terminal: false
});

rl.on('line', (line) => {
    const trimmed = line.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        process.stdout.write(line + '\n');
    } else if (trimmed.length > 0) {
        process.stderr.write(`[Engine Log]: ${line}\n`);
    }
});

flutterEngine.on('exit', (code) => {
    isShuttingDown = true;
    process.exit(code || 0);
});

// -----------------------------------------------------------------
// CRITICAL LIFECYCLE MANAGEMENT: Prevent Orphan Processes
// -----------------------------------------------------------------
const cleanup = () => {
    if (isShuttingDown) return;
    isShuttingDown = true;

    if (flutterEngine && !flutterEngine.killed) {
        if (platform === 'win32') {
            try {
                execSync(`taskkill /pid ${flutterEngine.pid} /T /F`, { stdio: 'ignore' });
            } catch (e) {}
        } else {
            flutterEngine.kill('SIGKILL');
        }
    }
    process.exit(0);
};

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
process.on('SIGHUP', cleanup);
process.on('exit', cleanup);
process.stdin.on('close', cleanup);
process.stdin.on('end', cleanup);
process.stdin.on('error', cleanup);
process.stdout.on('error', cleanup);
process.on('uncaughtException', (err) => {
    process.stderr.write(`[Fatal Bridge Error]: ${err.message}\n`);
    cleanup();
});