import '../../utils/safe_cast.dart';

/// A single summary entry within a reasoning item.
class ReasoningSummary {
  final String type;
  final String text;

  const ReasoningSummary({required this.type, required this.text});

  factory ReasoningSummary.fromMap(Map<String, dynamic> map) {
    return ReasoningSummary(
      type: safeString(map, 'type') ?? '',
      text: safeString(map, 'text') ?? '',
    );
  }

  @override
  String toString() => 'ReasoningSummary(type: $type, text: $text)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummary && type == other.type && text == other.text;

  @override
  int get hashCode => Object.hash(type, text);
}

/// A reasoning item from the Responses API output.
class ReasoningItem {
  final String type;
  final String id;
  final List<ReasoningSummary> summary;

  const ReasoningItem({
    required this.type,
    required this.id,
    required this.summary,
  });

  factory ReasoningItem.fromMap(Map<String, dynamic> map) {
    final rawSummary = safeList(map, 'summary');
    final summary = <ReasoningSummary>[];
    for (final entry in rawSummary) {
      if (entry is Map<String, dynamic>) {
        summary.add(ReasoningSummary.fromMap(entry));
      }
    }
    return ReasoningItem(
      type: safeString(map, 'type') ?? 'reasoning',
      id: safeString(map, 'id') ?? '',
      summary: summary,
    );
  }

  @override
  String toString() => 'ReasoningItem(id: $id, summaries: ${summary.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningItem &&
          type == other.type &&
          id == other.id &&
          _listEquals(summary, other.summary);

  @override
  int get hashCode => Object.hash(type, id, Object.hashAll(summary));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
