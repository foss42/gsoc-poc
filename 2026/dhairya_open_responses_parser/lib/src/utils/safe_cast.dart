/// Returns value as String or null. Never throws.
String? safeString(Map<String, dynamic> map, String key) {
  try {
    final value = map[key];
    if (value is String) return value;
    return null;
  } catch (_) {
    return null;
  }
}

/// Returns value as int or null. Never throws.
int? safeInt(Map<String, dynamic> map, String key) {
  try {
    final value = map[key];
    if (value is int) return value;
    return null;
  } catch (_) {
    return null;
  }
}

/// Returns value as List<dynamic> or empty list. Never throws.
List<dynamic> safeList(Map<String, dynamic> map, String key) {
  try {
    final value = map[key];
    if (value is List<dynamic>) return value;
    return [];
  } catch (_) {
    return [];
  }
}

/// Returns value as Map<String, dynamic> or null. Never throws.
Map<String, dynamic>? safeMap(Map<String, dynamic> map, String key) {
  try {
    final value = map[key];
    if (value is Map<String, dynamic>) return value;
    return null;
  } catch (_) {
    return null;
  }
}
