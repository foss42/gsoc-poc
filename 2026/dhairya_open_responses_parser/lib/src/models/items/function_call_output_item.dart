import 'dart:convert';

import '../../utils/safe_cast.dart';

/// A function_call_output item from the Responses API output.
class FunctionCallOutputItem {
  final String type;
  final String id;
  final String callId;
  final String output;

  const FunctionCallOutputItem({
    required this.type,
    required this.id,
    required this.callId,
    required this.output,
  });

  factory FunctionCallOutputItem.fromMap(Map<String, dynamic> map) {
    return FunctionCallOutputItem(
      type: safeString(map, 'type') ?? 'function_call_output',
      id: safeString(map, 'id') ?? '',
      callId: safeString(map, 'call_id') ?? '',
      output: safeString(map, 'output') ?? '',
    );
  }

  /// Attempts to parse output as a Map. Returns null if parsing fails.
  Map<String, dynamic>? get parsedOutput {
    try {
      if (output.isEmpty) return null;
      final decoded = json.decode(output);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'FunctionCallOutputItem(id: $id, callId: $callId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputItem &&
          type == other.type &&
          id == other.id &&
          callId == other.callId &&
          output == other.output;

  @override
  int get hashCode => Object.hash(type, id, callId, output);
}
