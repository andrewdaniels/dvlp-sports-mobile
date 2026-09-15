/// Coarse relative time ("just now" / "5m ago" / "3d ago" / …) —
/// good enough for feed rows and summary lists.
///
/// Takes an ISO 8601 string (what all our endpoints emit); returns an
/// empty string on parse failure so the caller can render a blank
/// slot rather than a spurious "just now".
String formatTimeAgo(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7}w ago';
  if (diff.inDays < 365) return '${diff.inDays ~/ 30}mo ago';
  return '${diff.inDays ~/ 365}y ago';
}
