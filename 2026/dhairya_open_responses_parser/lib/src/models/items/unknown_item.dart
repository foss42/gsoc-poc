/// An unknown or unrecognized item from the Responses API output.
/// Preserves the raw data so nothing is lost.
class UnknownItem {
  final String type;
  final dynamic raw;

  const UnknownItem({required this.type, required this.raw});

  factory UnknownItem.fromRaw(dynamic raw) {
    String itemType = 'unknown';
    if (raw is Map<String, dynamic>) {
      itemType = raw['type']?.toString() ?? 'unknown';
    }
    return UnknownItem(type: itemType, raw: raw);
  }

  @override
  String toString() => 'UnknownItem(type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownItem && type == other.type && raw == other.raw;

  @override
  int get hashCode => Object.hash(type, raw);
}
