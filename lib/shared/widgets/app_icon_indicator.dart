import 'package:flutter/material.dart';

import 'app_icon.dart';

/// Display-only tinted circular icon container. Used as a decorative badge
/// next to list items (e.g. "2 Formal Assessments due" with a star icon in
/// a red-tinted circle).
///
/// Not interactive. If you need a tappable version, use `AppIconButton` with
/// `variant: tinted`.
///
/// Sizes:
/// - `small`  — 32×32 container, 16px icon (list-row use)
/// - `medium` — 48×48 container, 20px icon (default; feature-row use)
/// - `large`  — 64×64 container, 28px icon (empty-state / hero use)
///
/// Background: `color @ 15%`. Icon: `color`.
class AppIconIndicator extends StatelessWidget {
  const AppIconIndicator({
    super.key,
    required this.icon,
    required this.color,
    this.size = AppIconIndicatorSize.medium,
  });

  final String icon;
  final Color color;
  final AppIconIndicatorSize size;

  @override
  Widget build(BuildContext context) {
    final (dim, iconSize) = switch (size) {
      AppIconIndicatorSize.small => (32.0, 16.0),
      AppIconIndicatorSize.medium => (48.0, 20.0),
      AppIconIndicatorSize.large => (64.0, 28.0),
    };

    return Container(
      width: dim,
      height: dim,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: AppIcon(icon, size: iconSize, color: color),
    );
  }
}

enum AppIconIndicatorSize { small, medium, large }
