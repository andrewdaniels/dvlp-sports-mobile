import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_skill_progress.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_chevron_right.dart';
import '../../../../shared/widgets/app_score_bar.dart';

/// One skill row for the DVLP list.
///
/// Layout:
///   ┌────────────────────────────────────────────────┐
///   │ Skill title                    +0.4 · 7.6 · ›  │  ← trailing centered
///   │ Skill description                              │
///   │ ├─band gradient · · · · · · · · · · · · · · ┤  │  ← thin score bar
///   └────────────────────────────────────────────────┘
///
/// Reads a single [Skill] response object + [ScoreScale] for the max.
/// Delta sign drives color: positive → success, negative → error,
/// zero/null → secondaryText.
///
/// The score bar is the shared [AppScoreBar] with band-gradient fill
/// + pointer — same visual language as the ScoreGauge on the
/// assessment detail page. The pointer gives an at-a-glance "where
/// you are on the ladder" read; the numeric score to the right is the
/// exact value. Bar height stays at the default (6px) to keep the row
/// compact vs. the taller gauge on the hero view.
class SkillRow extends StatelessWidget {
  const SkillRow({
    super.key,
    required this.skill,
    required this.scoreScale,
    this.onTap,
  });

  final Skill skill;
  final ScoreScale scoreScale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDescription = (skill.skillDescription ?? '').trim().isNotEmpty;
    final fraction = (skill.currentScore / scoreScale.max).clamp(0.0, 1.0);
    // One dot per interior whole-number step (skip 0 + max — they sit
    // under the pill's rounded ends).
    final tickCount = (scoreScale.max.round() - 1).clamp(0, 1 << 30);

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
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              // Center the delta / score / chevron cluster against the
              // title + description column.
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill.skillName,
                        style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                      ),
                      if (hasDescription) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          skill.skillDescription!,
                          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _DeltaLabel(delta: skill.delta),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatScore(skill.currentScore),
                  style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
                ),
                const SizedBox(width: AppSpacing.xs),
                const AppChevronRight(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppScoreBar(
              fraction: fraction,
              tickCount: tickCount,
              fill: AppScoreBarFill.band,
              showPointer: true,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatScore(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

class _DeltaLabel extends StatelessWidget {
  const _DeltaLabel({required this.delta});
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (delta == null) {
      return Text(
        '—',
        style: AppTypography.boldSmall.copyWith(color: colors.secondaryText),
      );
    }
    final positive = delta! > 0;
    final negative = delta! < 0;
    final color = positive
        ? colors.success
        : negative
            ? colors.error
            : colors.secondaryText;
    final sign = positive ? '+' : '';
    return Text(
      '$sign${delta!.toStringAsFixed(1)}',
      style: AppTypography.boldSmall.copyWith(color: color),
    );
  }
}

