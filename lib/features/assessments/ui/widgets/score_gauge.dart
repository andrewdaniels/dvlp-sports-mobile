import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_score_bar.dart';

/// Numeric score visualization for the formal assessment views.
///
/// Layout:
///   ┌─────────────────────────────────┬────────┐
///   │ Skill title                     │        │
///   │ Skill description               │  7.5   │  ← score badge (centered)
///   └─────────────────────────────────┴────────┘
///   ├─·─·─·─·─·─·─·─·─·─┤ band gradient with a dot per whole-number step
///   Last rating: 4
///
/// [maxScore] must come from the sport's `assessment_max` (fetched with
/// the assessment detail response). Everything about the gauge —
/// pointer position, band mapping, tick count — is derived as a
/// percentage of [maxScore], so bumping the scale up (e.g. a sport
/// with max=20) works with no widget changes.
///
/// Editable mode: pass `onTap` (and any composer callback that opens
/// a picker sheet). The badge becomes a tappable button. When `score`
/// is null, the badge label reads "Select" — signaling an unset value.
/// The score bar stays visible in editable mode with the pointer at
/// zero when unset, so the coach still sees the band ladder they're
/// filling in against.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    super.key,
    required this.title,
    this.description,
    required this.score,
    required this.maxScore,
    this.previousScore,
    this.onTap,
  });

  final String title;
  final String? description;
  final double? score;
  final double maxScore;
  final double? previousScore;

  /// When non-null, the badge becomes tappable and the caller can open
  /// the score selector sheet. Read-only when null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Null score renders as an empty gauge (pointer at 0, badge shows
    // "Select"). Non-null uses the actual value for band/pointer.
    final effectiveScore = score ?? 0.0;
    final pct = (effectiveScore / maxScore).clamp(0.0, 1.0);
    final band = levelBandForPct(pct);
    final badgeColor = band.color;
    final hasDescription = (description ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.boldLarge.copyWith(color: colors.primaryText),
                  ),
                  if (hasDescription) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description!,
                      style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _ScoreBadge(
              score: score,
              color: badgeColor,
              onTap: onTap,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppScoreBar(
          fraction: pct,
          // One dot per whole-number step (interior only). For max=10:
          // 1..9 → 9 dots. Scales cleanly for max=20 (19 dots) too.
          tickCount: (maxScore.round() - 1).clamp(0, 1 << 30),
          fill: AppScoreBarFill.band,
          showPointer: true,
          height: 8,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          // Always render the line; the value falls back to "-" until
          // we surface previous-formal-per-skill via an aggregate query.
          'Last rating: ${previousScore == null ? '-' : _formatScore(previousScore!)}',
          style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
        ),
      ],
    );
  }

  static String _formatScore(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

/// Colored pill showing the score. In read mode the fill is a subtle
/// same-color linear gradient (light → deeper). In edit mode (onTap
/// provided) the badge remains the same size but reacts to taps and
/// swaps its label to "Select" when [score] is null.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.score,
    required this.color,
    required this.onTap,
  });

  final double? score;
  final Color color;
  final VoidCallback? onTap;

  /// AppSizes only exposes small(36)/medium(48)/large(60), and no
  /// spacing token maps here either. 32 is the minimum comfortable tap
  /// target for the coach-side edit variant of this badge.
  static const double _height = 32;
  static const double _minWidth = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasScore = score != null;
    final label = hasScore ? ScoreGauge._formatScore(score!) : 'Select';

    // Empty state ("Select") uses a neutral bordered treatment so a
    // low-band color (blue for beginner) doesn't imply the coach
    // already scored the skill in the beginner range.
    final decoration = hasScore
        ? _filledGradient(color)
        : BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: colors.alternate, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          );

    final textColor = hasScore ? colors.persistDark : colors.secondaryText;

    final badge = Container(
      height: _height,
      constraints: const BoxConstraints(minWidth: _minWidth),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: decoration,
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.titleMedium.copyWith(color: textColor),
      ),
    );

    if (onTap == null) return badge;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap!();
      },
      child: badge,
    );
  }

  static BoxDecoration _filledGradient(Color color) {
    final hsl = HSLColor.fromColor(color);
    final light = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
    final dark = hsl.withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0)).toColor();
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [dark, light],
      ),
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
  }
}
