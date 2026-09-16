import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../generated/api/get_notifications.dart';
import '../../auth/data/api_result.dart';
import '../data/notifications_repository.dart';
import '../util/notifications_last_seen.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(SupabaseService.client);
});

/// Session-lifetime cache of the current user's notifications, newest
/// first. Invalidate on sign-out from the auth-sync provider; no other
/// invalidation needed for MVP (pull-to-refresh calls `refresh()`).
final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, GetNotificationsData?>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<GetNotificationsData?> {
  @override
  Future<GetNotificationsData?> build() async {
    final session = SupabaseService.client.auth.currentSession;
    if (session == null) return null;

    final result = await ref.read(notificationsRepositoryProvider).getNotifications();
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(notificationsRepositoryProvider).getNotifications();
      return switch (result) {
        Success(:final data) => data,
        Failure(:final message) => throw Exception(message),
      };
    });
  }
}

/// Last-seen timestamp for the notifications inbox — loaded from
/// SharedPreferences on first read, scoped per user. Null before the
/// user has ever opened the page.
final notificationsLastSeenProvider =
    AsyncNotifierProvider<NotificationsLastSeenNotifier, DateTime?>(
  NotificationsLastSeenNotifier.new,
);

class NotificationsLastSeenNotifier extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return null;
    return NotificationsLastSeen.read(userId);
  }

  /// Called when the user opens the notifications page — bumps the
  /// stored timestamp to now, which clears the unread badge on next
  /// bell render.
  Future<void> markSeen() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) return;
    await NotificationsLastSeen.writeNow(userId);
    // Invalidate to trigger a re-read; simpler than surgically setting
    // state and keeps the async source of truth in prefs.
    ref.invalidateSelf();
  }
}

/// Derived: how many notifications are newer than the last-seen
/// timestamp? Zero means all-read (or nothing loaded yet); positive
/// values drive the pill count on the bell icon.
///
/// Semantics:
///   - notifications not yet loaded → 0 (avoids flash on app-launch
///     before the fetch resolves)
///   - no notifications at all → 0
///   - last-seen null (user has never opened the page) → all
///     notifications count as unread
///   - otherwise → count of notifications whose created_at > last-seen
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(notificationsProvider);
  final lastSeenAsync = ref.watch(notificationsLastSeenProvider);

  final notifs = notifsAsync.value?.notifications;
  if (notifs == null || notifs.isEmpty) return 0;

  final lastSeen = lastSeenAsync.value;
  if (lastSeen == null) return notifs.length;

  var count = 0;
  for (final n in notifs) {
    final createdAt = DateTime.tryParse(n.createdAt);
    if (createdAt != null && createdAt.isAfter(lastSeen)) count++;
  }
  return count;
});

/// Convenience wrapper for callers that only need "is there anything
/// unread" without the number. Derived off the count provider so both
/// stay in sync.
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadNotificationCountProvider) > 0;
});
