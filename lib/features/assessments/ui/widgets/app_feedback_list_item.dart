import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_assessments.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_icon_indicator.dart';

/// List row for an assessment / feedback item.
///
/// Layout (top to bottom):
/// - Row 1: coach avatar · coach name + role stack · time-ago
/// - Row 2: small icon indicator · optional "NEW" tag · body text · chevron
///
/// Accepts the full [Assessment] model — this widget lives inside the
/// assessments feature so coupling to the model is expected. The
/// display mappings (coach role label, body copy, indicator icon, etc.)
/// live here so the passport / feedback-list screens don't repeat them.
///
/// [unread] is passed in because the source-of-truth isn't in the
/// [Assessment] shape yet (see the `athlete_read` column that's coming
/// with `get-assessment-detail`). Once that lands, callers stop passing
/// it and the widget reads `assessment.athleteRead`.
///
/// Fires light haptic on tap.
class AppFeedbackListItem extends StatelessWidget {
  const AppFeedbackListItem({
    super.key,
    required this.assessment,
    this.unread = false,
    this.onTap,
  });

  final Assessment assessment;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final coachName = 'Coach ${assessment.coach.firstName}';
    final coachRole = _coachRoleLine(assessment);
    final timeAgo = _timeAgo(assessment.submittedAt);
    final isQuick = assessment.assessmentType == AssessmentType.QUICK;
    final indicatorIcon = isQuick ? AppIcons.star : AppIcons.award;
    final indicatorColor = isQuick ? colors.secondary : colors.success;
    final body = isQuick ? 'Quick Feedback Submitted' : 'Formal Assessment Completed';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: AppCard(
        variant: unread ? AppCardVariant.unread : AppCardVariant.plain,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: avatar + [ (name + time) / role ]
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppAvatar(
                  imageUrl: assessment.coach.avatarUrl,
                  firstName: assessment.coach.firstName,
                  lastName: assessment.coach.lastName,
                  size: AppAvatarSize.small,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              coachName,
                              style: AppTypography.boldMedium.copyWith(color: colors.primaryText),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            timeAgo,
                            style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        coachRole,
                        style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Row 2: indicator + optional NEW + body + chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIconIndicator(
                  icon: indicatorIcon,
                  color: indicatorColor,
                  size: AppIconIndicatorSize.small,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        if (unread) ...[
                          TextSpan(
                            text: 'NEW',
                            style: AppTypography.boldMedium.copyWith(color: colors.link),
                          ),
                          // Explicit gap so "NEW" doesn't crowd the body copy.
                          const WidgetSpan(child: SizedBox(width: AppSpacing.xxs)),
                        ],
                        TextSpan(
                          text: body,
                          style: AppTypography.bodyMedium.copyWith(color: colors.primaryText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const AppChevronRight(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _coachRoleLine(Assessment a) {
    final role = switch (a.weightedRole) {
      WeightedRole.HEAD_COACH => 'Head Coach',
      WeightedRole.ASSISTANT_COACH => 'Assistant Coach',
      WeightedRole.SKILLS_COACH => 'Skills Coach',
      WeightedRole.OFFSEASON_COACH => 'Offseason Coach',
    };
    // External assessments were slotted under the athlete's active team
    // for season context, but the coach isn't actually on that team's
    // staff. Mirror the Request Feedback picker: show "External" as the
    // suffix instead of the team name so the athlete isn't misled into
    // thinking the coach coaches their team.
    final suffix = a.accessScope == AccessScope.EXTERNAL
        ? 'External'
        : [
            a.team.name.trim(),
            (a.team.ageGroup ?? '').trim(),
            (a.team.levelClassification?.name ?? '').trim(),
          ].where((s) => s.isNotEmpty).join(' ');
    return suffix.isEmpty ? role : '$role · $suffix';
  }

  /// Coarse relative time ("just now" / "5m ago" / "3d ago" / ...) —
  /// good enough for a feed row.
  static String _timeAgo(String iso) {
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
}
