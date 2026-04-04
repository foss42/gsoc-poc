import 'dart:convert';

import '../models/open_response.dart';
import '../models/items/reasoning_item.dart';
import '../models/items/function_call_item.dart';
import '../models/items/function_call_output_item.dart';
import '../models/items/message_item.dart';
import '../models/items/unknown_item.dart';
import '../models/correlated_call.dart';
import '../utils/safe_cast.dart';

/// Parses a raw decoded JSON map into a [ParsedOpenResponse].
///
/// Design principles:
/// - NEVER throws. All errors degrade gracefully to fallback values.
/// - Unknown item types produce [UnknownOutput], never a crash.
/// - Malformed required fields produce empty string fallbacks.
/// - Missing output array produces empty items list.
/// - call_id correlation is done in two passes for correctness.
class OpenResponseParser {
  /// Parse a raw Map<String, dynamic> (from json.decode) into a
  /// [ParsedOpenResponse]. Returns a safe empty response on total failure.
  ParsedOpenResponse parse(Map<String, dynamic> raw) {
    try {
      return _parseInternal(raw);
    } catch (e) {
      return const ParsedOpenResponse(
        id: 'parse_error',
        status: 'error',
        model: 'unknown',
        items: [],
        correlatedCalls: {},
        usage: null,
      );
    }
  }

  ParsedOpenResponse _parseInternal(Map<String, dynamic> raw) {
    final id = safeString(raw, 'id') ?? 'unknown';
    final status = safeString(raw, 'status') ?? 'unknown';
    final model = safeString(raw, 'model') ?? 'unknown';

    final outputList = safeList(raw, 'output');
    final items = <OpenResponsesItem>[];

    for (final rawItem in outputList) {
      if (rawItem is! Map<String, dynamic>) {
        items.add(UnknownOutput(UnknownItem.fromRaw(rawItem)));
        continue;
      }
      final itemType = safeString(rawItem, 'type');
      switch (itemType) {
        case 'reasoning':
          items.add(ReasoningOutput(ReasoningItem.fromMap(rawItem)));
        case 'function_call':
          items.add(FunctionCallOutput(FunctionCallItem.fromMap(rawItem)));
        case 'function_call_output':
          items.add(
              FunctionCallOutputResult(FunctionCallOutputItem.fromMap(rawItem)));
        case 'message':
          items.add(MessageOutput(MessageItem.fromMap(rawItem)));
        default:
          items.add(UnknownOutput(UnknownItem.fromRaw(rawItem)));
      }
    }

    // Pass 1: index all function_call items by call_id
    final callMap = <String, FunctionCallItem>{};
    for (final item in items) {
      if (item is FunctionCallOutput) {
        callMap[item.item.callId] = item.item;
      }
    }

    // Pass 2: match function_call_output items to their calls
    final outputMap = <String, FunctionCallOutputItem>{};
    for (final item in items) {
      if (item is FunctionCallOutputResult) {
        outputMap[item.item.callId] = item.item;
      }
    }

    // Build correlatedCalls
    final correlatedCalls = <String, CorrelatedCall>{};
    for (final entry in callMap.entries) {
      correlatedCalls[entry.key] = CorrelatedCall(
        call: entry.value,
        output: outputMap[entry.key],
      );
    }

    // Parse usage if present
    ResponseUsage? usage;
    final usageMap = safeMap(raw, 'usage');
    if (usageMap != null) {
      usage = ResponseUsage.fromMap(usageMap);
    }

    return ParsedOpenResponse(
      id: id,
      status: status,
      model: model,
      items: items,
      correlatedCalls: correlatedCalls,
      usage: usage,
    );
  }

  /// Convenience method: parse from a raw JSON string.
  ParsedOpenResponse parseJsonString(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return parse(decoded);
      }
      return _emptyResponse();
    } catch (_) {
      return _emptyResponse();
    }
  }

  ParsedOpenResponse _emptyResponse() {
    return const ParsedOpenResponse(
      id: 'invalid',
      status: 'error',
      model: 'unknown',
      items: [],
      correlatedCalls: {},
      usage: null,
    );
  }
}
