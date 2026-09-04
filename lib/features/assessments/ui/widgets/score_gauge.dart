import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

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
        _GaugeBar(
          fraction: pct,
          // One dot per whole-number step (interior only). For max=10:
          // 1..9 → 9 dots. Scales cleanly for max=20 (19 dots) too.
          tickCount: (maxScore.round() - 1).clamp(0, 1 << 30),
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

/// Band gradient bar (aligned to band boundaries) with small dot ticks
/// at each whole-number step, and a downward triangle at [fraction].
class _GaugeBar extends StatelessWidget {
  const _GaugeBar({required this.fraction, required this.tickCount});
  final double fraction;
  final int tickCount;

  static const double _barHeight = 8;
  static const double _pointerHeight = 8;
  static const double _pointerWidth = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pointerX = (width * fraction - _pointerWidth / 2)
            .clamp(0.0, width - _pointerWidth);
        return SizedBox(
          height: _barHeight + _pointerHeight + 2,
          child: Stack(
            children: [
              Positioned(
                left: pointerX,
                top: 0,
                child: CustomPaint(
                  size: const Size(_pointerWidth, _pointerHeight),
                  painter: _DownTrianglePainter(color: Colors.white),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: _barHeight,
                  child: CustomPaint(
                    painter: _GaugeBarPainter(tickCount: tickCount),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DownTrianglePainter extends CustomPainter {
  const _DownTrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DownTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Paints the band gradient bar + small dark inset-dot ticks.
///
/// Gradient uses smooth even-stop blending (default LinearGradient
/// behavior) — soft transitions across bands, not hard segments.
/// Ticks are small dark low-opacity dots at each whole-number step in
/// the interior — reads as recessed holes rather than paint marks.
class _GaugeBarPainter extends CustomPainter {
  const _GaugeBarPainter({required this.tickCount});
  final int tickCount;

  // Band regions with ~13% blend zones straddling each boundary
  // (~6.5% each side). Solid color anchors each band's core (blue
  // 0–33, bronze 46–54, silver 67–68, gold 82–83, elite 97–100) and
  // the transition sweeps across the boundary. Silver + gold cores
  // are 1–2% since those bands are only 15% wide — this is about as
  // soft as the blend can get before silver/gold lose their anchor
  // entirely and read as pure gradient.
  static const _stops = <double>[
    0.0, 0.33, 0.46, 0.54, 0.67, 0.68, 0.82, 0.83, 0.97, 1.0,
  ];
  static const _colors = <Color>[
    Color(0xFF3B89FF), Color(0xFF3B89FF), // beginner  0..33 → blend to 46
    Color(0xFFB0754F), Color(0xFFB0754F), // bronze    46..54 → blend to 67
    Color(0xFFB5BFCF), Color(0xFFB5BFCF), // silver    67..68 → blend to 82
    Color(0xFFCFA437), Color(0xFFCFA437), // gold      82..83 → blend to 97
    Color(0xFF3ECF8E), Color(0xFF3ECF8E), // elite     97..100
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    final shader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: _colors,
      stops: _stops,
    ).createShader(rrect.outerRect);
    canvas.drawRRect(rrect, Paint()..shader = shader);

    // Dot ticks — interior only, one per whole-number step. Dark +
    // low opacity so they read as recessed pinholes rather than
    // painted marks. Position of tick i (1-indexed) inside a span of
    // (tickCount + 1) steps is i / (tickCount + 1).
    if (tickCount <= 0) return;
    final holePaint = Paint()..color = Colors.black.withValues(alpha: 0.32);
    final dotRadius = size.height * 0.18;
    final segments = tickCount + 1;
    for (var i = 1; i <= tickCount; i++) {
      final x = size.width * (i / segments);
      canvas.drawCircle(Offset(x, size.height / 2), dotRadius, holePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeBarPainter oldDelegate) =>
      oldDelegate.tickCount != tickCount;
}
