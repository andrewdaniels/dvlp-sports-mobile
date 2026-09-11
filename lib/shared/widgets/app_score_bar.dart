import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Which fill treatment the bar draws under the track:
///   - [flat] — a single color across the filled portion. Used to
///     express "raw progress" without band semantics (e.g. simple
///     completion meters). Defaults to `colors.secondary` when no
///     explicit `flatFillColor` is passed.
///   - [band] — the full band gradient (beginner → bronze → silver →
///     gold → elite) across the entire track. Used to express "where
///     does this score fall on the athlete's rating band?" The fraction
///     itself doesn't color the fill — it's implicit in where the
///     pointer/badge falls along the gradient.
enum AppScoreBarFill { flat, band }

/// Score-visualization bar shared between the skills list (DVLP) and
/// the formal-assessment ScoreGauge.
///
/// Layout:
///   ┌─(optional pointer)─┐
///   │        ▽           │
///   ├──────────track──────┤   ← dot notches at each whole-number step
///
/// The two visual language differences we support are:
///   1. [fill]      — flat single tone vs full band gradient.
///   2. [showPointer] — whether to render a small downward triangle
///                      above the track at [fraction] (used by
///                      ScoreGauge to mark the athlete's exact score
///                      on the band).
///
/// Everything else (dot ticks, rounded caps, height mapping) is shared
/// so a single visual system covers both contexts. Add new fill modes
/// here (e.g. `dualTone`) rather than forking the widget.
class AppScoreBar extends StatelessWidget {
  const AppScoreBar({
    super.key,
    required this.fraction,
    required this.tickCount,
    this.fill = AppScoreBarFill.flat,
    this.showPointer = false,
    this.height = 6,
    this.flatFillColor,
  });

  /// 0..1 progress ratio. Clamped internally.
  final double fraction;

  /// Number of interior whole-number tick dots (skip 0 + max — they sit
  /// under the rounded ends). For max=10: pass 9.
  final int tickCount;

  /// Fill treatment. Defaults to flat.
  final AppScoreBarFill fill;

  /// When true, draws a small downward triangle above the track at
  /// [fraction]. Used by the assessment score gauge; skills list rows
  /// leave it off.
  final bool showPointer;

  /// Track height in logical pixels. 6 for compact list rows, 8 for
  /// the gauge context. Pointer height is fixed at 8 above the track.
  final double height;

  /// Fill color when [fill] is [AppScoreBarFill.flat]. Ignored for
  /// [AppScoreBarFill.band]. Defaults to `colors.secondary`.
  final Color? flatFillColor;

  static const double _pointerHeight = 8;
  static const double _pointerWidth = 12;
  static const double _pointerGap = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final f = fraction.clamp(0.0, 1.0);
    final resolvedFlatFill = flatFillColor ?? colors.secondary;

    // When there's no pointer, we don't need the LayoutBuilder — just
    // a fixed-height CustomPaint at the caller's width. Cheaper and
    // avoids an extra Stack layer for list rows that render many bars.
    if (!showPointer) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: CustomPaint(
          painter: _ScoreBarPainter(
            fraction: f,
            tickCount: tickCount,
            fill: fill,
            flatFillColor: resolvedFlatFill,
            trackColor: colors.alternate,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pointerX = (width * f - _pointerWidth / 2)
            .clamp(0.0, width - _pointerWidth);
        return SizedBox(
          height: height + _pointerHeight + _pointerGap,
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
                  height: height,
                  child: CustomPaint(
                    painter: _ScoreBarPainter(
                      fraction: f,
                      tickCount: tickCount,
                      fill: fill,
                      flatFillColor: resolvedFlatFill,
                      trackColor: colors.alternate,
                    ),
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

class _ScoreBarPainter extends CustomPainter {
  const _ScoreBarPainter({
    required this.fraction,
    required this.tickCount,
    required this.fill,
    required this.flatFillColor,
    required this.trackColor,
  });

  final double fraction;
  final int tickCount;
  final AppScoreBarFill fill;
  final Color flatFillColor;
  final Color trackColor;

  // Band gradient: soft transitions between core color anchors so the
  // bar reads as a continuous rating scale, not stacked bars. Anchors:
  // beginner blue 0–33, bronze 46–54, silver 67–68, gold 82–83, elite
  // 97–100. Silver + gold anchors are narrow because those bands
  // themselves are only 15% wide.
  //
  // FIXME (multi-sport): these stops are hard-coded to hockey's
  // level_band_thresholds. A second sport with different boundaries
  // would visually misalign. When we add sport #2, surface the sport's
  // bands to the client (via get-profile or a get-sport-config
  // endpoint) and compute stops dynamically from them. See the
  // in-session task "Make AppScoreBar band gradient sport-dynamic".
  static const _bandStops = <double>[
    0.0, 0.33, 0.46, 0.54, 0.67, 0.68, 0.82, 0.83, 0.97, 1.0,
  ];
  static const _bandColors = <Color>[
    Color(0xFF3B89FF), Color(0xFF3B89FF), // beginner
    Color(0xFFB0754F), Color(0xFFB0754F), // bronze
    Color(0xFFB5BFCF), Color(0xFFB5BFCF), // silver
    Color(0xFFCFA437), Color(0xFFCFA437), // gold
    Color(0xFF3ECF8E), Color(0xFF3ECF8E), // elite
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackRect = RRect.fromRectAndRadius(Offset.zero & size, radius);

    switch (fill) {
      case AppScoreBarFill.band:
        // Band fills the whole track; the athlete's position on the
        // scale is conveyed by the caller's pointer / badge / adjacent
        // score readout, not by fill length.
        final shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _bandColors,
          stops: _bandStops,
        ).createShader(trackRect.outerRect);
        canvas.drawRRect(trackRect, Paint()..shader = shader);
      case AppScoreBarFill.flat:
        canvas.drawRRect(trackRect, Paint()..color = trackColor);
        if (fraction > 0) {
          final fillWidth = size.width * fraction;
          final fillRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, fillWidth, size.height),
            radius,
          );
          canvas.drawRRect(fillRect, Paint()..color = flatFillColor);
        }
    }

    // Interior whole-number tick dots. Dark low-opacity so they read
    // as recessed pinholes rather than painted marks. Skip when the
    // caller passes 0 (or negative, defensively).
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
  bool shouldRepaint(covariant _ScoreBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.tickCount != tickCount ||
      oldDelegate.fill != fill ||
      oldDelegate.flatFillColor != flatFillColor ||
      oldDelegate.trackColor != trackColor;
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
