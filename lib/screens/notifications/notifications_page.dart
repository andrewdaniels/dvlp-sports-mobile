import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/routing/route_names.dart';
import '../../core/theme/theme.dart';
import '../../features/coach_feedback/controllers/coach_feedback_providers.dart';
import '../../features/notifications/controllers/notifications_providers.dart';
import '../../features/notifications/ui/widgets/notification_row.dart';
import '../../generated/api/get_notifications.dart' as gen;
import '../../shared/widgets/app_detail_app_bar.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../../shared/widgets/app_refresh_indicator.dart';

/// Notifications inbox. Shared route across both athlete + coach
/// shells — pushed on the root navigator so the back button returns
/// to whichever tab the user came from.
///
/// Read state is local for MVP:
///   - Opening this page bumps the stored last-seen timestamp to now.
///   - The bell icon's dot is driven off "any notification.createdAt
///     newer than last-seen" (see hasUnreadNotificationsProvider).
///
/// Tap behavior varies by type:
///   - assessment_submitted_quick  → athlete-side detail (/feedback/quick/:id)
///   - assessment_submitted_formal → athlete-side detail (/feedback/formal/:id)
///   - assessment_requested_quick  → coach quick composer for that
///     request (looked up by request_id in the coach-feedback-summary
///     cache to resolve athlete_id + team_id; falls back to the
///     Feedback tab when the request isn't in the pending list — e.g.,
///     already fulfilled, or cache stale).
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Mark as seen the moment the page mounts. Runs post-frame so we
    // don't schedule state changes during build. Any notification
    // that shipped in AFTER this point will still bump the badge.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(notificationsLastSeenProvider.notifier).markSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: const AppDetailAppBar(title: 'Notifications'),
      body: async.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, _) => _Empty(message: 'Could not load notifications.'),
        data: (data) {
          final items = data?.notifications ?? const <gen.NotificationElement>[];
          if (items.isEmpty) {
            return AppRefreshIndicator(
              onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  _Empty(message: "You're all caught up."),
                ],
              ),
            );
          }
          // Local-only read state: last-seen is loaded async. Treat
          // "still loading" as "no lastSeen known yet" so items don't
          // flash from unread → read as prefs resolves.
          final lastSeen = ref.watch(notificationsLastSeenProvider).value;
          return AppRefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: AppPageInsets.padding,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, i) {
                final n = items[i];
                final createdAt = DateTime.tryParse(n.createdAt) ?? DateTime.now();
                final unread = lastSeen == null || createdAt.isAfter(lastSeen);
                return NotificationRow(
                  type: n.type,
                  title: n.title,
                  subtitle: n.subtitle,
                  createdAt: createdAt,
                  unread: unread,
                  onTap: _onTapFor(context, n),
                );
              },
            ),
          );
        },
      ),
      backgroundColor: colors.primaryBackground,
    );
  }

  /// Returns a tap handler for the row, or null for rows with no
  /// resource id (defensive — every current type has one).
  VoidCallback? _onTapFor(BuildContext context, gen.NotificationElement n) {
    final resourceId = n.resourceId;
    if (resourceId == null) return null;
    switch (n.type) {
      case gen.Type.ASSESSMENT_SUBMITTED_QUICK:
        return () => context.push(RouteNames.feedbackQuickFor(resourceId));
      case gen.Type.ASSESSMENT_SUBMITTED_FORMAL:
        return () => context.push(RouteNames.feedbackFormalFor(resourceId));
      case gen.Type.ASSESSMENT_REQUESTED_QUICK:
        return () => _openQuickRequestComposer(context, resourceId);
      // Guardian link — no deep-link target yet (guardian views ship
      // later). Tap is a no-op for now; the row still renders with
      // title/subtitle so the athlete knows the guardian arrived.
      case gen.Type.GUARDIAN_LINKED:
        return null;
      // Org-decision types are web-only; mobile shouldn't see them
      // in practice. No deep-link target — tap is a no-op.
      case gen.Type.ORGANIZATION_APPROVED:
      case gen.Type.ORGANIZATION_DENIED:
        return null;
    }
  }

  /// Opens the composer for a specific pending request. Resolves the
  /// missing athlete_id + team_id via the coach-feedback-summary
  /// cache (the request row is in `quickFeedbackRequests`). Falls
  /// back to the coach Feedback tab if the request isn't in the
  /// cache — either the summary hasn't loaded yet, or the request
  /// has already been fulfilled and dropped from the pending list.
  void _openQuickRequestComposer(BuildContext context, String requestId) {
    final summary = ref.read(coachFeedbackSummaryProvider).value;
    final match = summary?.quickFeedbackRequests
        .where((r) => r.requestId == requestId)
        .firstOrNull;
    if (match == null) {
      context.push(RouteNames.coachFeedback);
      return;
    }
    context.push(RouteNames.feedbackQuickNewFor(
      athleteId: match.athlete.id,
      teamId: match.teamId,
      requestId: match.requestId,
    ));
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(color: context.colors.secondaryText),
        ),
      ),
    );
  }
}
