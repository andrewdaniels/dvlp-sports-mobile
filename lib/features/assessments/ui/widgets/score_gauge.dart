import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_score_bar.dart';

/// Numeric score visualization for the formal assessment detail view.
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
/// Feature-scoped (assessments). If a coach-side edit variant lands,
/// extend this widget with an `editable` prop that swaps the display
/// badge for a tap-to-rate action.
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    super.key,
    required this.title,
    this.description,
    required this.score,
    required this.maxScore,
    this.previousScore,
  });

  final String title;
  final String? description;
  final double score;
  final double maxScore;
  final double? previousScore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pct = (score / maxScore).clamp(0.0, 1.0);
    final band = _bandForPct(pct);
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
            _ScoreBadge(score: score, color: badgeColor),
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

  /// Band thresholds per the design spec:
  ///   Beginner  <40%
  ///   Bronze    40–59%
  ///   Silver    60–74%
  ///   Gold      75–89%
  ///   Elite     ≥90%
  /// Percentage-based so it works for any [maxScore] (10, 20, whatever
  /// the sport configures). Hoist to a shared util fed by
  /// `level_band_thresholds` when the aggregate scoring system needs
  /// authoritative bands.
  static LevelBand _bandForPct(double pct) {
    if (pct < 0.40) return LevelBand.beginner;
    if (pct < 0.60) return LevelBand.bronze;
    if (pct < 0.75) return LevelBand.silver;
    if (pct < 0.90) return LevelBand.gold;
    return LevelBand.elite;
  }

  static String _formatScore(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

/// Colored pill showing the score. Fill is a subtle same-color linear
/// gradient (light → deeper) so it reads dimensional. Text is dark
/// (`persistDark`) for consistent contrast across themes.
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score, required this.color});

  final double score;
  final Color color;

  /// AppSizes only exposes small(36)/medium(48)/large(60), and no
  /// spacing token maps here either. 32 is the minimum comfortable tap
  /// target for the coach-side edit variant of this badge. Raw for now
  /// — hoist to a sizing token when a second element needs the same
  /// height (breaks the +12 rhythm of the current scale if added
  /// prematurely).
  static const double _height = 32;
  static const double _minWidth = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hsl = HSLColor.fromColor(color);
    final light = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
    final dark = hsl.withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0)).toColor();
    return Container(
      height: _height,
      constraints: const BoxConstraints(minWidth: _minWidth),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [dark, light],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: Text(
        ScoreGauge._formatScore(score),
        style: AppTypography.titleMedium.copyWith(color: colors.persistDark),
      ),
    );
  }
}

