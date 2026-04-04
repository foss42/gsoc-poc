import 'items/reasoning_item.dart';
import 'items/function_call_item.dart';
import 'items/function_call_output_item.dart';
import 'items/message_item.dart';
import 'items/unknown_item.dart';
import 'correlated_call.dart';

/// Sealed union type for all possible output items.
sealed class OpenResponsesItem {
  const OpenResponsesItem();
}

class ReasoningOutput extends OpenResponsesItem {
  final ReasoningItem item;
  const ReasoningOutput(this.item);
}

class FunctionCallOutput extends OpenResponsesItem {
  final FunctionCallItem item;
  const FunctionCallOutput(this.item);
}

class FunctionCallOutputResult extends OpenResponsesItem {
  final FunctionCallOutputItem item;
  const FunctionCallOutputResult(this.item);
}

class MessageOutput extends OpenResponsesItem {
  final MessageItem item;
  const MessageOutput(this.item);
}

class UnknownOutput extends OpenResponsesItem {
  final UnknownItem item;
  const UnknownOutput(this.item);
}

/// Usage statistics from the response.
class ResponseUsage {
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;

  const ResponseUsage({
    required this.inputTokens,
    required this.outputTokens,
  }) : totalTokens = inputTokens + outputTokens;

  factory ResponseUsage.fromMap(Map<String, dynamic> map) {
    return ResponseUsage(
      inputTokens: (map['input_tokens'] as int?) ?? 0,
      outputTokens: (map['output_tokens'] as int?) ?? 0,
    );
  }

  @override
  String toString() =>
      'ResponseUsage(input: $inputTokens, output: $outputTokens, total: $totalTokens)';
}

/// The fully parsed and correlated Open Response.
class ParsedOpenResponse {
  final String id;
  final String status;
  final String model;
  final List<OpenResponsesItem> items;

  /// Correlated calls: key is call_id, value is the paired call+output.
  final Map<String, CorrelatedCall> correlatedCalls;

  final ResponseUsage? usage;

  const ParsedOpenResponse({
    required this.id,
    required this.status,
    required this.model,
    required this.items,
    required this.correlatedCalls,
    this.usage,
  });

  /// Convenience getters
  List<ReasoningItem> get reasoningItems =>
      items.whereType<ReasoningOutput>().map((o) => o.item).toList();

  List<FunctionCallItem> get functionCalls =>
      items.whereType<FunctionCallOutput>().map((o) => o.item).toList();

  List<FunctionCallOutputItem> get functionCallOutputs =>
      items.whereType<FunctionCallOutputResult>().map((o) => o.item).toList();

  List<MessageItem> get messages =>
      items.whereType<MessageOutput>().map((o) => o.item).toList();

  List<UnknownItem> get unknownItems =>
      items.whereType<UnknownOutput>().map((o) => o.item).toList();

  int get totalItems => items.length;

  @override
  String toString() =>
      'ParsedOpenResponse(id: $id, status: $status, model: $model, '
      'items: $totalItems, correlatedCalls: ${correlatedCalls.length})';
}
