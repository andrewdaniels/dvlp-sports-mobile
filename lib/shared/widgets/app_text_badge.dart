import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Small pill-shaped badge with an uppercase text label. Same visual
/// formula as [AppGameResultBadge] (color-tinted fill + colored outline
/// + colored text) but takes primitive props (color + label) so it can
/// stand in for arbitrary categorical/status markers — WIN / LOSS /
/// TIE, NEW, LIVE, VERIFIED, whatever.
///
/// - Background: `color @ 15%`
/// - 1px border in [color]
/// - Uppercase [label] in `boldSmall`, colored [color]
///
/// [size] controls vertical padding only — the label typography stays
/// the same across sizes.
///
/// Display-only. If you need it tappable, wrap in a `GestureDetector`
/// at the call site.
class AppTextBadge extends StatelessWidget {
  const AppTextBadge({
    super.key,
    required this.label,
    required this.color,
    this.size = AppTextBadgeSize.small,
  });

  final String label;
  final Color color;
  final AppTextBadgeSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.boldSmall.copyWith(
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  double get _verticalPadding => switch (size) {
        AppTextBadgeSize.small => AppSpacing.xxs, // ~24 total height
        AppTextBadgeSize.medium => AppSpacing.xs, // ~32 total height
      };
}

enum AppTextBadgeSize { small, medium }
