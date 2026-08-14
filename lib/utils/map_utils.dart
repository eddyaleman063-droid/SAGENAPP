Map<String, int> parseStringMap(String raw) {
  final map = <String, int>{};
  if (raw.isEmpty) return map;
  for (final entry in raw.split(',')) {
    final parts = entry.split(':');
    if (parts.length == 2) {
      map[parts[0]] = int.tryParse(parts[1]) ?? 0;
    }
  }
  return map;
}

String encodeStringMap(Map<String, int> map) {
  return map.entries.map((e) => '${e.key}:${e.value}').join(',');
}

/// Clave de día (YYYY-MM-DD) anclada en UTC, coherente con los topes
/// diarios del servidor (Cloud Functions usan UTC).
String utcDayKey([DateTime? now]) {
  final dt = (now ?? DateTime.now()).toUtc();
  return dt.toIso8601String().substring(0, 10);
}
