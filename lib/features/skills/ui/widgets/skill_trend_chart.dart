import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../generated/api/get_skill_history.dart';
import '../../../../shared/widgets/app_card.dart';

/// Six-month (or N-month) trend chart for a single skill. Reads the
/// response objects from `get-skill-history` directly.
///
/// Feature-scoped for now. Extract to `shared/widgets/` when a second
/// caller wants a line-chart-with-gradient-fill.
///
/// Empty state: if no points have a non-null `weightedAvg`, the chart
/// falls back to a "no data yet" message. Single-point case renders
/// just the dot with no line/fill.
class SkillTrendChart extends StatelessWidget {
  const SkillTrendChart({
    super.key,
    required this.points,
    required this.scoreScale,
  });

  final List<Point> points;
  final ScoreScale scoreScale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final nonNull = points.where((p) => p.weightedAvg != null).toList();
    final firstScore = nonNull.isNotEmpty ? nonNull.first.weightedAvg : null;
    final lastScore = nonNull.isNotEmpty ? nonNull.last.weightedAvg : null;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderRow(
            monthsLabel: '${points.length}-MONTH PROGRESS',
            first: firstScore,
            last: lastScore,
          ),
          const SizedBox(height: AppSpacing.md),
          if (nonNull.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No formal assessments yet at this level.',
                  style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                ),
              ),
            )
          else
            SizedBox(
              // Plot area + x-axis label strip live inside the same
              // paint so month labels can center-anchor on exact
              // dot x-positions (edge months hug the card edges).
              height: 160,
              child: CustomPaint(
                painter: _TrendPainter(
                  points: points,
                  scoreScale: scoreScale,
                  lineColor: colors.secondary,
                  gridColor: colors.alternate,
                  axisLabelColor: colors.secondaryText,
                  textStyle: AppTypography.labelSmall,
                ),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.monthsLabel,
    required this.first,
    required this.last,
  });

  final String monthsLabel;
  final double? first;
  final double? last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            monthsLabel,
            style: AppTypography.labelSmall.copyWith(
              color: colors.secondaryText,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (first != null && last != null && first != last) ...[
          Text(
            _fmt(first!),
            style: AppTypography.titleMedium.copyWith(color: colors.secondaryText),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(Icons.arrow_forward, size: 16, color: colors.secondaryText),
          ),
          Text(
            _fmt(last!),
            style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
          ),
        ] else if (last != null) ...[
          Text(
            _fmt(last!),
            style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
          ),
        ],
      ],
    );
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

/// Painter for the chart body. Draws (bottom-to-top):
///   1. Five horizontal gridlines evenly spaced across the visible
///      y-range (min, 25%, 50%, 75%, max) using the alternate color.
///   2. Y-axis labels — only at min and max — in the left gutter.
///   3. Gradient area fill under the line (lineColor top → transparent
///      bottom).
///   4. Line connecting non-null points.
///   5. Dot markers at each non-null point.
///   6. Month abbreviations in the x-axis strip below the plot.
///
/// X positioning: first point sits at the left edge of the plot,
/// last point at the right edge (index / (n - 1)). This makes the
/// current month hug the right edge of the card as intended.
class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.scoreScale,
    required this.lineColor,
    required this.gridColor,
    required this.axisLabelColor,
    required this.textStyle,
  });

  final List<Point> points;
  final ScoreScale scoreScale;
  final Color lineColor;
  final Color gridColor;
  final Color axisLabelColor;
  final TextStyle textStyle;

  static const double _yAxisGutter = 32;
  static const double _xAxisLabelHeight = 22;
  static const double _dotRadius = 3.5;
  static const int _gridlineCount = 5; // min, 25%, 50%, 75%, max

  @override
  void paint(Canvas canvas, Size size) {
    final nonNull = <MapEntry<int, double>>[];
    for (var i = 0; i < points.length; i++) {
      final v = points[i].weightedAvg;
      if (v != null) nonNull.add(MapEntry(i, v));
    }
    if (nonNull.isEmpty) return;

    // Local y-range: zoom to the series (with headroom) instead of
    // always showing the full sport scale. Matches the design's
    // "6.0 → 7.6" framing.
    final rawMin = nonNull.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final rawMax = nonNull.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final range = rawMax - rawMin;
    final pad = range < 1 ? 0.8 : (range * 0.15);
    final yMin = (rawMin - pad).clamp(scoreScale.min, scoreScale.max);
    final yMax = (rawMax + pad).clamp(scoreScale.min, scoreScale.max);
    final effectiveRange = (yMax - yMin) == 0 ? 1 : (yMax - yMin);

    // Zones inside the canvas.
    final plotLeft = _yAxisGutter;
    final plotRight = size.width;
    final plotWidth = plotRight - plotLeft;
    final plotTop = _dotRadius;
    final plotBottom = size.height - _xAxisLabelHeight - _dotRadius;
    final plotHeight = plotBottom - plotTop;

    // ── Gridlines ──────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < _gridlineCount; i++) {
      final t = i / (_gridlineCount - 1);
      final y = plotBottom - plotHeight * t;
      canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), gridPaint);
    }

    // ── Y-axis labels: only at min and max ─────────────────────────
    _drawText(
      canvas,
      _fmt(yMax),
      Offset(0, plotTop - 6),
      align: _TextAlign.leading,
    );
    _drawText(
      canvas,
      _fmt(yMin),
      Offset(0, plotBottom - 6),
      align: _TextAlign.leading,
    );

    // ── Plot geometry ──────────────────────────────────────────────
    Offset xy(int index, double value) {
      final xFraction = points.length == 1
          ? 0.5
          : index / (points.length - 1);
      final x = plotLeft + plotWidth * xFraction;
      final yFraction = ((value - yMin) / effectiveRange).clamp(0.0, 1.0);
      final y = plotBottom - plotHeight * yFraction;
      return Offset(x, y);
    }

    final positions = nonNull.map((e) => xy(e.key, e.value)).toList();

    // ── Area fill (gradient beneath the line) ──────────────────────
    if (positions.length >= 2) {
      final areaPath = Path()..moveTo(positions.first.dx, plotBottom);
      for (final p in positions) {
        areaPath.lineTo(p.dx, p.dy);
      }
      areaPath
        ..lineTo(positions.last.dx, plotBottom)
        ..close();

      final areaRect = Rect.fromLTRB(
        positions.first.dx,
        plotTop,
        positions.last.dx,
        plotBottom,
      );
      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.35),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(areaRect);
      canvas.drawPath(areaPath, areaPaint);
    }

    // ── Line ───────────────────────────────────────────────────────
    if (positions.length >= 2) {
      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final linePath = Path()..moveTo(positions.first.dx, positions.first.dy);
      for (var i = 1; i < positions.length; i++) {
        linePath.lineTo(positions[i].dx, positions[i].dy);
      }
      canvas.drawPath(linePath, linePaint);
    }

    // ── Dot markers ────────────────────────────────────────────────
    final dotPaint = Paint()..color = lineColor;
    for (final p in positions) {
      canvas.drawCircle(p, _dotRadius, dotPaint);
    }

    // ── X-axis month labels ────────────────────────────────────────
    final labelY = plotBottom + _dotRadius + 6;
    for (var i = 0; i < points.length; i++) {
      final xFraction = points.length == 1 ? 0.5 : i / (points.length - 1);
      final centerX = plotLeft + plotWidth * xFraction;
      final align = i == 0
          ? _TextAlign.leading
          : (i == points.length - 1 ? _TextAlign.trailing : _TextAlign.center);
      final anchorX = align == _TextAlign.leading
          ? centerX
          : align == _TextAlign.trailing
              ? centerX
              : centerX;
      _drawText(canvas, _monthAbbrev(points[i].monthEnd),
          Offset(anchorX, labelY), align: align);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset anchor, {
    required _TextAlign align,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle.copyWith(color: axisLabelColor)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      _TextAlign.leading => anchor.dx,
      _TextAlign.center => anchor.dx - tp.width / 2,
      _TextAlign.trailing => anchor.dx - tp.width,
    };
    tp.paint(canvas, Offset(dx, anchor.dy));
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  static String _monthAbbrev(String isoDate) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final mm = int.tryParse(isoDate.substring(5, 7)) ?? 0;
    return (mm >= 1 && mm <= 12) ? months[mm] : '';
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.points != points ||
      old.scoreScale != scoreScale ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor;
}

enum _TextAlign { leading, center, trailing }
