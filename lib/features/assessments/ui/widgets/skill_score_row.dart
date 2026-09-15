import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_star_rating.dart';

/// One skill row in the quick-feedback views.
///
/// Layout:
///   [ Skill name          ] · · · [ ★★★☆☆ ]
///   [ Skill description   ]
///
/// Quick scores are 1–5 (star scale). Read-only when [onScoreChanged]
/// is null; interactive when a callback is passed (composer / edit
/// mode) — taps forward through to [AppStarRating.onChanged].
class SkillScoreRow extends StatelessWidget {
  const SkillScoreRow({
    super.key,
    required this.skillName,
    required this.skillDescription,
    required this.score,
    this.onScoreChanged,
  });

  final String skillName;
  final String? skillDescription;
  final int score;

  /// When non-null, the star rating becomes interactive. Value passed
  /// through unchanged from AppStarRating (respects its tap-same-star
  /// = clear semantics).
  final ValueChanged<int>? onScoreChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDescription = (skillDescription ?? '').trim().isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                skillName,
                style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
              ),
              if (hasDescription) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  skillDescription!,
                  style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        AppStarRating(value: score, onChanged: onScoreChanged),
      ],
    );
  }
}
