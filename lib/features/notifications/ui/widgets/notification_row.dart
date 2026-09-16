import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_notifications.dart' as gen;
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_icon_indicator.dart';
import '../../util/notification_appearance.dart';

/// One row in the notifications inbox. Layout mirrors TodoRow but
/// carries a trailing timestamp instead of a chevron, and can render
/// an unread visual state.
///
///   ┌───────────────────────────────────────────────────────┐
///   │ (●)  Title                                     2m ago │
///   │      Subtitle                                         │
///   └───────────────────────────────────────────────────────┘
///
/// Icon + tint come from `appearanceFor(type)` — one visual per
/// notification type. Unread state is a boolean the page passes in
/// (page-level compare: notification.createdAt > lastSeen).
class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.unread,
    this.onTap,
  });

  final gen.Type type;
  final String title;
  final String? subtitle;
  final DateTime createdAt;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final appearance = appearanceFor(type, context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: AppCard(
        // Unread rows keep the default card fill; read rows dim
        // slightly so the eye anchors on unread first. Kept subtle —
        // MVP visual language, refine when the design surfaces this
        // properly.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIconIndicator(
              icon: appearance.icon,
              color: appearance.color,
              size: AppIconIndicatorSize.medium,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.boldLarge.copyWith(
                      color: unread ? colors.primaryText : colors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Subtitle line: "<subtitle> · <time>", or just the
                  // time when subtitle is null. Combining them here
                  // keeps the trailing edge clean (chevron only) and
                  // matches the pattern used by inbox rows in Slack /
                  // Discord / GitHub.
                  Text(
                    _composeMeta(subtitle, createdAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Chevron for affordance parity with TodoRow / feedback
            // rows — reads as "tap to open detail" even for types we
            // haven't wired deep-links for yet (assessment_requested_
            // quick). When the third notification type gets a real tap
            // target, no widget change needed.
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }
}

/// Merges the subtitle and relative time into one meta line:
/// "Florida Surf U15 · 2m" or "2m" when there's no subtitle.
String _composeMeta(String? subtitle, DateTime createdAt) {
  final rel = _formatRelative(createdAt);
  final sub = subtitle?.trim();
  if (sub == null || sub.isEmpty) return rel;
  return '$sub · $rel';
}

/// "23m ago", "2h ago", "3d ago". Abbreviated unit, spelled-out
/// "ago" — reads naturally inline with the subtitle without eating
/// too much of the row width.
String _formatRelative(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final wks = (diff.inDays / 7).floor();
  if (wks < 5) return '${wks}w ago';
  final mos = (diff.inDays / 30).floor();
  if (mos < 12) return '${mos}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}
