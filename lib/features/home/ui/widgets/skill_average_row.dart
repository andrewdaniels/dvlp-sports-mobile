import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_level_badge.dart';
import '../../../../shared/widgets/app_score_bar.dart';

/// One row in the coach Home "Team Skill Levels" section.
///
/// Layout:
///   Skill name                          (coin) [ 7.3]
///   ├─·─·─·─·─·─·─·─·─·─┤ band gradient with pointer
///
/// Coin color follows the band the average falls into (same
/// `levelBandForPct` mapping the ScoreGauge and score selector sheet
/// use). Score bar uses AppScoreBar in band-fill mode with pointer —
/// same visual as the per-athlete ScoreGauge, just without the badge
/// treatment.
///
/// The trailing coin + score cluster is right-anchored via a
/// fixed-width score slot. This keeps every row's coin at the same
/// x-position regardless of score digit count ("5" vs "10" vs "7.4"),
/// matching the same treatment on SkillRow so the whole app reads
/// consistently.
///
/// When [avgScore] is null (no athlete has scored this skill yet on
/// this team), the row renders "-" and hides the pointer.
class SkillAverageRow extends StatelessWidget {
  const SkillAverageRow({
    super.key,
    required this.skillName,
    required this.avgScore,
    required this.maxScore,
  });

  final String skillName;
  final double? avgScore;
  final double maxScore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pct = avgScore == null ? 0.0 : (avgScore! / maxScore).clamp(0.0, 1.0);
    final band = avgScore == null ? null : levelBandForPct(pct);
    final tickCount = (maxScore.round() - 1).clamp(0, 1 << 30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                skillName,
                style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Fixed-width coin slot so a missing coin (null avg)
            // leaves the same footprint — score column doesn't shift.
            SizedBox(
              width: AppLevelCoinSize.xsmall.dim,
              height: AppLevelCoinSize.xsmall.dim,
              child: band == null
                  ? null
                  : AppLevelCoin(
                      band: band,
                      subLevel: 1,
                      size: AppLevelCoinSize.xsmall,
                    ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // Fixed-width right-aligned score slot. Anchors the coin
            // + score cluster at the row's right edge regardless of
            // digit count so every row's coin lands at the same x.
            SizedBox(
              width: _scoreSlotWidth,
              child: Text(
                avgScore == null ? '-' : _formatScore(avgScore!),
                textAlign: TextAlign.end,
                style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppScoreBar(
          fraction: pct,
          tickCount: tickCount,
          fill: AppScoreBarFill.band,
          showPointer: avgScore != null,
          height: 8,
        ),
      ],
    );
  }

  /// Wide enough for the largest expected value at titleMedium (18/w600):
  /// "10" plus a hair of headroom. Values below 10 always render as
  /// "N.N" (4 chars max via `_formatScore`), which fits comfortably.
  static const double _scoreSlotWidth = 32;

  static String _formatScore(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}
