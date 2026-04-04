import 'dart:convert';

import '../../utils/safe_cast.dart';

/// A function_call item from the Responses API output.
class FunctionCallItem {
  final String type;
  final String id;
  final String callId;
  final String name;
  final String arguments;
  final String status;

  const FunctionCallItem({
    required this.type,
    required this.id,
    required this.callId,
    required this.name,
    required this.arguments,
    required this.status,
  });

  factory FunctionCallItem.fromMap(Map<String, dynamic> map) {
    return FunctionCallItem(
      type: safeString(map, 'type') ?? 'function_call',
      id: safeString(map, 'id') ?? '',
      callId: safeString(map, 'call_id') ?? '',
      name: safeString(map, 'name') ?? '',
      arguments: safeString(map, 'arguments') ?? '',
      status: safeString(map, 'status') ?? 'unknown',
    );
  }

  /// Attempts to parse arguments as a Map. Returns null if parsing fails.
  Map<String, dynamic>? get parsedArguments {
    try {
      if (arguments.isEmpty) return null;
      final decoded = json.decode(arguments);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() =>
      'FunctionCallItem(id: $id, callId: $callId, name: $name, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallItem &&
          type == other.type &&
          id == other.id &&
          callId == other.callId &&
          name == other.name &&
          arguments == other.arguments &&
          status == other.status;

  @override
  int get hashCode => Object.hash(type, id, callId, name, arguments, status);
}
