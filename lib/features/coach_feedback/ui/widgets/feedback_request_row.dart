import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_coach_feedback_summary.dart';
import '../../../../shared/util/time_ago.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';

/// One row on the coach Feedback page's Requests section.
///
///   ┌───────────────────────────────────────────────┐
///   │ (avatar)  Name                            ›   │
///   │           Requested 1d ago                    │
///   └───────────────────────────────────────────────┘
///
/// Subtitle is yellow (colors.secondary) for a normal pending request.
/// If the request has been sitting >30 days, subtitle flips to error
/// color with an "Overdue • Requested Xd ago" treatment so the coach
/// can spot stale asks at a glance.
///
/// All requests are quick feedback (only quick is athlete-requestable);
/// no type badge needed.
class FeedbackRequestRow extends StatelessWidget {
  const FeedbackRequestRow({
    super.key,
    required this.entry,
    this.onTap,
  });

  final QuickFeedbackRequest entry;
  final VoidCallback? onTap;

  /// Threshold that flips a request into the overdue treatment. Kept
  /// as a compile-time constant so the boundary is unambiguous —
  /// server doesn't compute this; it's a purely visual client rule.
  static const Duration overdueAfter = Duration(days: 30);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = entry.athlete;
    final name = _formatName(a.firstName, a.lastName);

    final requestedAt = DateTime.tryParse(entry.requestedAt);
    final isOverdue = requestedAt != null &&
        DateTime.now().difference(requestedAt.toLocal()) > overdueAfter;

    final subtitleText = isOverdue
        ? 'Overdue • Requested ${formatTimeAgo(entry.requestedAt)}'
        : 'Requested ${formatTimeAgo(entry.requestedAt)}';
    final subtitleColor = isOverdue ? colors.error : colors.secondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppAvatar(
              imageUrl: a.avatarUrl,
              firstName: a.firstName,
              lastName: a.lastName,
              size: AppAvatarSize.small,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitleText,
                    style: AppTypography.labelSmall.copyWith(color: subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }

  static String _formatName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '${f[0].toUpperCase()}. $l';
  }
}
