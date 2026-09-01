import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Result of a played game. Domain enum — lives inline here for now; move
/// to `lib/core/domain/enums.dart` when the games feature lands and the
/// backend model needs the same type.
enum GameResult { win, loss, tie }

/// Circular win/loss/tie badge shown next to game list items.
///
/// - 48×48 circle
/// - Background: `color @ 15%`
/// - 2px border in the semantic color
/// - Bold single-letter (W / L / T) in the semantic color
///
/// Color mapping:
/// - `win` → `success` (green)
/// - `loss` → `error` (red)
/// - `tie` → `link` (blue)
class AppGameResultBadge extends StatelessWidget {
  const AppGameResultBadge({super.key, required this.result});

  final GameResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (letter, color) = switch (result) {
      GameResult.win => ('W', colors.success),
      GameResult.loss => ('L', colors.error),
      GameResult.tie => ('T', colors.link),
    };

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: AppTypography.titleMedium.copyWith(color: color),
      ),
    );
  }
}
