import { MCPClient } from "./client.js";
import {
  AssertionResult,
  runAssertion,
  assert,
  assertType,
  assertHasKey,
} from "./assertions.js";

/**
 * MCP Apps conformance tests.
 *
 * These tests validate the MCP Apps extension (SEP-1865) which enables
 * servers to return rich, interactive HTML UIs via structuredContent
 * and declare UI resources alongside standard tools.
 *
 * Tested against: sample-mcp-apps-chatflow (Sales Analytics)
 */
export async function runMcpAppsSuite(client: MCPClient): Promise<AssertionResult[]> {
  const results: AssertionResult[] = [];

  // ── MCP Apps: structuredContent Tests ──

  results.push(
    await runAssertion("get-sales-data returns structuredContent", "MCP Apps", async () => {
      const result = await client.callToolRaw("get-sales-data", {
        states: ["MH"],
        metric: "revenue",
        period: "monthly",
        year: "2024",
      });
      assertHasKey(result, "content", "tool result");
      assertHasKey(result, "structuredContent", "tool result");
      assert(
        result.structuredContent !== null && result.structuredContent !== undefined,
        "structuredContent should not be null/undefined"
      );
    })
  );

  results.push(
    await runAssertion("structuredContent contains valid report structure", "MCP Apps", async () => {
      const result = await client.callToolRaw("get-sales-data", {
        states: ["MH"],
        metric: "revenue",
        period: "monthly",
        year: "2024",
      });
      const sc = result.structuredContent as Record<string, unknown>;
      assertHasKey(sc, "summary", "structuredContent");
      assertHasKey(sc, "periods", "structuredContent");
      assertHasKey(sc, "states", "structuredContent");
      assertHasKey(sc, "stateNames", "structuredContent");

      const summary = sc.summary as Record<string, unknown>;
      assertHasKey(summary, "total", "summary");
      assertHasKey(summary, "totalRaw", "summary");
      assertType(summary.totalRaw, "number", "summary.totalRaw");

      assert(
        Array.isArray(sc.periods),
        "structuredContent.periods should be an array"
      );
      assert(
        (sc.periods as unknown[]).length > 0,
        "structuredContent.periods should not be empty"
      );
    })
  );

  // ── MCP Apps: UI Resources Tests ──

  results.push(
    await runAssertion("resources/list exposes MCP Apps UI resources", "MCP Apps: Resources", async () => {
      const resources = await client.listResources();
      assertType(resources, "array", "resources");
      assert(resources.length > 0, "Server returned 0 resources");
      assert(resources.length === 3, `Expected 3 UI resources, got ${resources.length}`);
    })
  );

  results.push(
    await runAssertion("UI resources use mcp-app MIME type", "MCP Apps: Resources", async () => {
      const resources = await client.listResources();
      for (const resource of resources) {
        assertHasKey(resource, "mimeType", "resource");
        assert(
          resource.mimeType === "text/html;profile=mcp-app",
          `Expected mimeType "text/html;profile=mcp-app", got "${resource.mimeType}"`
        );
      }
    })
  );

  results.push(
    await runAssertion("UI resources use ui:// URI scheme", "MCP Apps: Resources", async () => {
      const resources = await client.listResources();
      for (const resource of resources) {
        assertHasKey(resource, "uri", "resource");
        const uri = resource.uri as string;
        assert(
          uri.startsWith("ui://"),
          `Expected URI to start with "ui://", got "${uri}"`
        );
      }
    })
  );

  // ── MCP Apps: Tool Metadata Tests ──

  results.push(
    await runAssertion("tools declare UI resource bindings via _meta", "MCP Apps: Metadata", async () => {
      const tools = await client.listToolsRaw();
      const toolsWithUi = tools.filter(
        (t) => (t._meta as Record<string, unknown>)?.ui !== undefined
      );
      assert(
        toolsWithUi.length > 0,
        "No tools declare _meta.ui resource bindings"
      );
      for (const tool of toolsWithUi) {
        const ui = (tool._meta as Record<string, unknown>).ui as Record<string, unknown>;
        assertHasKey(ui, "resourceUri", `${tool.name}._meta.ui`);
        const resourceUri = ui.resourceUri as string;
        assert(
          resourceUri.startsWith("ui://"),
          `${tool.name}._meta.ui.resourceUri should use ui:// scheme, got "${resourceUri}"`
        );
      }
    })
  );

  results.push(
    await runAssertion("tools declare visibility levels", "MCP Apps: Metadata", async () => {
      const tools = await client.listToolsRaw();
      const toolsWithUi = tools.filter(
        (t) => (t._meta as Record<string, unknown>)?.ui !== undefined
      );
      for (const tool of toolsWithUi) {
        const ui = (tool._meta as Record<string, unknown>).ui as Record<string, unknown>;
        assertHasKey(ui, "visibility", `${tool.name}._meta.ui`);
        assert(
          Array.isArray(ui.visibility),
          `${tool.name}._meta.ui.visibility should be an array`
        );
        const vis = ui.visibility as string[];
        assert(vis.length > 0, `${tool.name}._meta.ui.visibility is empty`);
        for (const v of vis) {
          assert(
            v === "model" || v === "app",
            `${tool.name}: unexpected visibility "${v}" (expected "model" or "app")`
          );
        }
      }
    })
  );

  // ── MCP Apps: Workflow Test ──

  results.push(
    await runAssertion("tool workflow: select → fetch data pipeline", "MCP Apps: Workflow", async () => {
      // Step 1: select-sales-metric (no args needed)
      const selectResult = await client.callTool("select-sales-metric", {});
      assertHasKey(selectResult, "content", "select result");
      assert(selectResult.content.length > 0, "select returned empty content");

      // Step 2: get-sales-data with valid params
      const dataResult = await client.callToolRaw("get-sales-data", {
        states: ["MH", "TN"],
        metric: "revenue",
        period: "quarterly",
        year: "2024",
      });
      assertHasKey(dataResult, "structuredContent", "data result");
      const sc = dataResult.structuredContent as Record<string, unknown>;
      assertHasKey(sc, "summary", "workflow structuredContent");
      assertHasKey(sc, "periods", "workflow structuredContent");
      assert(
        (sc.states as unknown[]).length === 2,
        `Expected 2 states in report, got ${(sc.states as unknown[]).length}`
      );
    })
  );

  return results;
}
