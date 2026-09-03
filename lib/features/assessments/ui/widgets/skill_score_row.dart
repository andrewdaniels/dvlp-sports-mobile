import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_star_rating.dart';

/// One skill row in the quick-feedback detail view.
///
/// Layout:
///   [ Skill name          ] · · · [ ★★★☆☆ ]
///   [ Skill description   ]
///
/// Quick scores are 1–5 (star scale). When the formal detail page
/// lands, either extend this widget with a numeric trailing variant or
/// ship a `NumericSkillScoreRow` sibling — same title/subtitle
/// structure, different trailing indicator.
class SkillScoreRow extends StatelessWidget {
  const SkillScoreRow({
    super.key,
    required this.skillName,
    required this.skillDescription,
    required this.score,
  });

  final String skillName;
  final String? skillDescription;
  final int score;

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
        AppStarRating(value: score),
      ],
    );
  }
}
