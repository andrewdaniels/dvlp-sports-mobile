import 'package:shared_preferences/shared_preferences.dart';

/// Local (device-only) last-seen timestamp for the notifications inbox.
/// Keyed by user id so multiple accounts on the same device don't
/// share seen-state.
///
/// This is the MVP unread mechanism: the badge on the bell icon shows
/// when the newest notification's created_at is later than the stored
/// last-seen. Opening the notifications page updates last-seen to
/// `DateTime.now()`. When the read-tracking table lands server-side,
/// swap this out and remove.
class NotificationsLastSeen {
  static String _key(String userId) => 'notifications_last_seen_at:$userId';

  /// Returns null the first time — before the user has opened the page.
  /// A null last-seen means "everything is unread" (matches most
  /// notification apps' first-launch behavior).
  static Future<DateTime?> read(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_key(userId));
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  static Future<void> writeNow(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), DateTime.now().toUtc().toIso8601String());
  }
}
