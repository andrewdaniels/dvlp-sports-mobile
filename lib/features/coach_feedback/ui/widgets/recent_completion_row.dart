import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_coach_feedback_summary.dart';
import '../../../../shared/util/time_ago.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';

/// One row on the coach Feedback page's Completed section — a recent
/// coach-authored submission (formal or quick).
///
///   ┌───────────────────────────────────────────────┐
///   │ (avatar)  Name                            ›   │
///   │           Completed 1d ago                    │
///   └───────────────────────────────────────────────┘
///
/// Consumes one entry from get-coach-feedback-summary's
/// `recent_completed` array. Coach info is redundant (it's always the
/// caller's own work) so the subtitle is just the completion time.
/// The `assessment_type` on the entry drives which detail route the
/// caller opens on tap.
///
/// Trailing "View" text is success-green to signal "this is done" —
/// visually distinct from the yellow "Review" that marks pending work.
class RecentCompletionRow extends StatelessWidget {
  const RecentCompletionRow({
    super.key,
    required this.entry,
    this.onTap,
  });

  final RecentCompleted entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = entry.athlete;
    final name = _formatName(a.firstName, a.lastName);
    final subtitle = 'Completed ${formatTimeAgo(entry.submittedAt)}';

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
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
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
