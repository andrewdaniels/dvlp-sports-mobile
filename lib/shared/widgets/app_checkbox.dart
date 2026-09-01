import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Checkbox with a label to the right.
///
/// - Label: `bodyLarge`, `primaryText` (enabled) / `secondaryText` (disabled)
/// - Checked: filled `secondary` (yellow) box with `persistDark` check icon
/// - Unchecked: `secondaryText` outlined box
/// - Set `onChanged: null` to disable
/// - Light haptic on tap
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  static const double _box = 22;
  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onChanged == null;
    final labelColor = disabled ? colors.secondaryText : colors.primaryText;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              onChanged!(!value);
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _box,
            height: _box,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value ? colors.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: value
                  ? null
                  : Border.all(
                      color: disabled ? colors.secondaryText : colors.primaryText70,
                      width: 1.5,
                    ),
            ),
            child: value
                ? AppIcon(AppIcons.check, size: _iconSize, color: colors.persistDark)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(color: labelColor),
            ),
          ),
        ],
      ),
    );
  }
}
