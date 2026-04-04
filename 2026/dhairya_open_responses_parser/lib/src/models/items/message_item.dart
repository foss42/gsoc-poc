import '../../utils/safe_cast.dart';

/// A single content entry within a message item.
class MessageContent {
  final String type;
  final String text;

  const MessageContent({required this.type, required this.text});

  factory MessageContent.fromMap(Map<String, dynamic> map) {
    return MessageContent(
      type: safeString(map, 'type') ?? '',
      text: safeString(map, 'text') ?? '',
    );
  }

  @override
  String toString() => 'MessageContent(type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageContent && type == other.type && text == other.text;

  @override
  int get hashCode => Object.hash(type, text);
}

/// A message item from the Responses API output.
class MessageItem {
  final String type;
  final String id;
  final String role;
  final List<MessageContent> content;

  const MessageItem({
    required this.type,
    required this.id,
    required this.role,
    required this.content,
  });

  factory MessageItem.fromMap(Map<String, dynamic> map) {
    final rawContent = safeList(map, 'content');
    final content = <MessageContent>[];
    for (final entry in rawContent) {
      if (entry is Map<String, dynamic>) {
        content.add(MessageContent.fromMap(entry));
      }
    }
    return MessageItem(
      type: safeString(map, 'type') ?? 'message',
      id: safeString(map, 'id') ?? '',
      role: safeString(map, 'role') ?? '',
      content: content,
    );
  }

  /// Returns the concatenated text of all content items.
  String get fullText => content.map((c) => c.text).join('\n');

  @override
  String toString() =>
      'MessageItem(id: $id, role: $role, contents: ${content.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageItem &&
          type == other.type &&
          id == other.id &&
          role == other.role &&
          _listEquals(content, other.content);

  @override
  int get hashCode => Object.hash(type, id, role, Object.hashAll(content));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
