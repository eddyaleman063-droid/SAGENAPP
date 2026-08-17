/// Extracts up to 2 initials from a display name.
///
/// Returns the first character of the first two words (uppercased).
/// Falls back to `'?'` when the name is empty or blank.
String userInitials(String displayName) {
  final parts = displayName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.every((p) => p.isEmpty)) return '?';
  if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
}
