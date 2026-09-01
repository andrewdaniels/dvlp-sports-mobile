import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

/// 5-star rating.
///
/// - Filled: `brand.secondary` (yellow)
/// - Unfilled: `brand.alternate` (muted per mode)
/// - Read-only when `onChanged` is null
/// - Stars are custom-painted (Untitled UI's free set doesn't have a filled
///   variant, so we draw directly for full control)
/// - Light haptic on interactive tap
class AppStarRating extends StatelessWidget {
  const AppStarRating({
    super.key,
    required this.value,
    this.onChanged,
  });

  final int value;
  final ValueChanged<int>? onChanged;

  static const int _max = 5;
  static const double _star = 24;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final readOnly = onChanged == null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= _max; i++) ...[
          if (i > 1) const SizedBox(width: _gap),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: readOnly
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    // Tap same star at value → toggles it off (down to i-1);
                    // otherwise sets rating to i.
                    onChanged!(value == i ? i - 1 : i);
                  },
            child: CustomPaint(
              size: const Size(_star, _star),
              painter: _StarPainter(
                filled: i <= value,
                fillColor: colors.secondary,
                emptyColor: colors.alternate,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter({required this.filled, required this.fillColor, required this.emptyColor});

  final bool filled;
  final Color fillColor;
  final Color emptyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _starPath(size);
    final color = filled ? fillColor : emptyColor;
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  Path _starPath(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rOuter = size.width / 2;
    final rInner = rOuter * 0.45;
    const points = 5;

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? rOuter : rInner;
      final angle = -math.pi / 2 + (i * math.pi / points);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_StarPainter old) {
    return old.filled != filled || old.fillColor != fillColor || old.emptyColor != emptyColor;
  }
}
