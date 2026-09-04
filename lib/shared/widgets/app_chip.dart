import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';

/// Small tappable chip with an on/off selection state. Used for
/// filter groups (e.g., the chapter chips on the My Feedback page).
///
/// Selected: filled with `link` tint, `link` border, primary text.
/// Unselected: transparent, `alternate` border, secondary text.
///
/// Fixed 36dp height — text is centered via `Center` widget (padding
/// alone can leave text visually offset due to font metrics). Add a
/// size enum if we ever need multiple heights.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const double _height = 36;

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = selected ? colors.link : colors.alternate;
    final textColor = selected ? colors.primaryText : colors.secondaryText;
    final bgColor = selected ? colors.link.withValues(alpha: 0.12) : Colors.transparent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: _height,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.boldSmall.copyWith(color: textColor),
        ),
      ),
    );
  }
}
