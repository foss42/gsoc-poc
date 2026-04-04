# Open Responses Parser

**Typed Dart parser for OpenAI Responses API payloads.**
GSoC 2026 Proof of Concept for [API Dash](https://github.com/foss42/apidash).

## What this is

A standalone pure Dart package that converts a raw OpenAI Responses API
JSON payload into a structured, typed domain model with automatic
call-output correlation.

## Why it matters

OpenAI's Responses API returns heterogeneous payloads with reasoning traces,
function calls, correlated outputs, and messages all mixed in a flat array.
Current tools render this as raw JSON. This parser is the foundation of the
structured rendering pipeline proposed for API Dash's GSoC 2026 project:
"Open Responses and Generative UI Dashboard".

## What it parses

| Item Type             | Dart Class               | Notes                              |
|-----------------------|--------------------------|------------------------------------|
| reasoning             | ReasoningItem            | Summary text, collapsible          |
| function_call         | FunctionCallItem         | Name, call_id, typed arguments     |
| function_call_output  | FunctionCallOutputItem   | Linked via call_id to its call     |
| message               | MessageItem              | Role + content text                |
| unknown/new types     | UnknownItem              | Raw preserved, never lost          |

## Key feature: call-output correlation

function_call and function_call_output items share a call_id.
The parser automatically pairs them into CorrelatedCall objects:

```dart
final parser = OpenResponseParser();
final result = parser.parse(rawJsonMap);

for (final entry in result.correlatedCalls.entries) {
  print('Call: ${entry.value.call.name}');
  print('Complete: ${entry.value.isComplete}');
  if (entry.value.isComplete) {
    print('Output: ${entry.value.output?.parsedOutput}');
  }
}
```

## Setup

```
dart pub get
dart test
```

All 30+ tests should pass. No external dependencies needed.

## Connection to GSoC proposal

This package implements the OpenResponsesParser and typed domain model
described in the proposal. In the full project, this moves into
packages/apidash_core/lib/parsers/ai_responses/ inside the API Dash monorepo
and plugs into the ResponseBodyView via a content-type router.

Author: Dhairya Jangir — GSoC 2026 applicant, API Dash
