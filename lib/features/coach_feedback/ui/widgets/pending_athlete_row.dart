import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_coach_feedback_summary.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_chevron_right.dart';

/// Row rendered inside [CadenceHeroCard] for one athlete who still
/// needs a formal assessment this period.
///
/// Bare inline row (no card chrome) — the outer hero card supplies the
/// only chrome, and dividers between rows are added by the parent.
/// This keeps the chevron flush with the same x-position used by the
/// Requests / Completed row chevrons on the page so the eye tracks a
/// clean vertical column of trailing affordances.
///
/// Trailing: yellow "Review" text + standard chevron. Whole row is
/// tappable — the text is an action affordance, not a separate hit
/// target.
class PendingAthleteRow extends StatelessWidget {
  const PendingAthleteRow({
    super.key,
    required this.entry,
    this.onTap,
  });

  final PendingAthlete entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = entry.athlete;
    final name = _formatName(a.firstName, a.lastName);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
              child: Text(
                name,
                style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Review',
              style: AppTypography.boldMedium.copyWith(color: colors.secondary),
            ),
            const SizedBox(width: AppSpacing.sm),
            const AppChevronRight(),
          ],
        ),
      ),
    );
  }

  /// "M. Thompson" — first initial + last name, matching the row style
  /// used elsewhere on the coach side (see RosterRow).
  static String _formatName(String first, String last) {
    final f = first.trim();
    final l = last.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '${f[0].toUpperCase()}. $l';
  }
}
