import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Level band gradients — 5 bands each with:
///  - `scoreGradient` (fill for the large numeric score on the badge)
///  - `labelGradient` (fill for the level name label below the badge)
///
/// Use with `ShaderMask` to fill text with these gradients.
enum LevelBand { beginner, bronze, silver, gold, elite }

class AppGradients {
  AppGradients._();

  /// Representative solid color per band — used for outer glow / boxShadow
  /// where a single color is needed (gradients don't work in shadows).
  static Color glowColor(LevelBand band) {
    switch (band) {
      case LevelBand.beginner:
        return const Color(0xFF3B89FF);
      case LevelBand.bronze:
        return const Color(0xFFD09C83);
      case LevelBand.silver:
        return const Color(0xFFB5BFCF);
      case LevelBand.gold:
        return const Color(0xFFCFA437);
      case LevelBand.elite:
        return const Color(0xFF3ECF8E);
    }
  }

  /// Darker stop color per band — used to tint "carved" text on the badge
  /// so the number carries the band hue instead of reading as neutral grey.
  static Color scoreDarkColor(LevelBand band) {
    switch (band) {
      case LevelBand.beginner:
        return const Color(0xFF3B89FF);
      case LevelBand.bronze:
        return const Color(0xFF8C573E);
      case LevelBand.silver:
        return const Color(0xFF8D9CB3);
      case LevelBand.gold:
        return const Color(0xFF9F7200);
      case LevelBand.elite:
        return const Color(0xFF089757);
    }
  }

  static Gradient scoreGradient(LevelBand band) {
    switch (band) {
      case LevelBand.beginner:
        return _linear(111.95, [
          const _Stop(0.045, Color(0xFF3B89FF)),
          const _Stop(0.5219, Color(0xFF8BB9FF)),
          const _Stop(1.077, Color(0xFF3B89FF)),
        ]);
      case LevelBand.bronze:
        return _linear(137.11, [
          const _Stop(0.021, Color(0xFF8C573E)),
          const _Stop(0.460, Color(0xFFD09C83)),
          const _Stop(0.936, Color(0xFF8C573E)),
        ]);
      case LevelBand.silver:
        return _linear(138.28, [
          const _Stop(0.0, Color(0xFF8D9CB3)),
          const _Stop(0.510, Color(0xFFB5BFCF)),
          const _Stop(1.0, Color(0xFF8D9CB3)),
        ]);
      case LevelBand.gold:
        return _linear(136.98, [
          const _Stop(0.0, Color(0xFF9F7200)),
          const _Stop(0.476, Color(0xFFCFA437)),
          const _Stop(0.980, Color(0xFF9F7200)),
        ]);
      case LevelBand.elite:
        return _linear(138.28, [
          const _Stop(0.005, Color(0xFF089757)),
          const _Stop(0.572, Color(0xFF3ECF8E)),
          const _Stop(1.0, Color(0xFF089757)),
        ]);
    }
  }

  static Gradient labelGradient(LevelBand band) {
    switch (band) {
      case LevelBand.beginner:
        return _linear(90, [
          const _Stop(0.0, Color(0xFF8EBBFF)),
          const _Stop(1.0, Color(0xFF3B89FF)),
        ]);
      case LevelBand.bronze:
        return _linear(90, [
          const _Stop(0.038, Color(0xFFE8B49C)),
          const _Stop(1.0, Color(0xFF9D654A)),
        ]);
      case LevelBand.silver:
        return _linear(90, [
          const _Stop(0.0, Color(0xFFAEB5BF)),
          const _Stop(0.337, Color(0xFFE7ECF4)),
          const _Stop(1.0, Color(0xFF7A8CA7)),
        ]);
      case LevelBand.gold:
        return _linear(90, [
          const _Stop(0.014, Color(0xFFD0A638)),
          const _Stop(0.375, Color(0xFFFFD76D)),
          const _Stop(1.0, Color(0xFF9F7200)),
        ]);
      case LevelBand.elite:
        return _linear(90, [
          const _Stop(0.014, Color(0xFF3ECF8E)),
          const _Stop(0.375, Color(0xFF80FFC6)),
          const _Stop(1.0, Color(0xFF0A9C5A)),
        ]);
    }
  }

  static LinearGradient _linear(double angleDeg, List<_Stop> stops) {
    // Convert CSS-style angle (from top, clockwise) to Flutter's AlignmentGeometry.
    final radians = (angleDeg - 90) * math.pi / 180.0;
    final dx = math.cos(radians);
    final dy = math.sin(radians);
    return LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: stops.map((s) => s.color).toList(),
      stops: stops.map((s) => s.pos.clamp(0.0, 1.0)).toList(),
    );
  }
}

class _Stop {
  const _Stop(this.pos, this.color);
  final double pos;
  final Color color;
}
