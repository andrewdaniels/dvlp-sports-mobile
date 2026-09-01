import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Tappable "select" trigger — looks like an input, opens something on tap
/// (typically a sheet or menu). Chevron-down on the trailing edge signals
/// the affordance.
///
/// Same visual formula as [AppTextField] (height, padding, border colors)
/// so the two align cleanly when stacked in a form.
///
/// - Optional [label] above (color adapts per state)
/// - Optional [leadingIcon] on the left
/// - Trailing chevron-down always shown
/// - [value], if provided, renders in primary text; otherwise placeholder
/// - [onTap] null → disabled
/// - [errorText], if non-null, triggers error styling + renders below
class AppSelectTrigger extends StatelessWidget {
  const AppSelectTrigger({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.leadingIcon,
    this.errorText,
    required this.onTap,
  });

  final String? label;
  final String? placeholder;
  final String? value;
  final String? leadingIcon;
  final String? errorText;
  final VoidCallback? onTap;

  bool get _enabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = _resolveBorderColor(colors, hasError: hasError);
    final labelColor = _resolveLabelColor(colors, hasError: hasError);
    final hasValue = value != null && value!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.labelSmall.copyWith(color: labelColor)),
          const SizedBox(height: AppSpacing.xxs),
        ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.secondaryBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  AppIcon(leadingIcon!, size: 20, color: colors.secondaryText),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    hasValue ? value! : (placeholder ?? ''),
                    style: AppTypography.bodyMedium.copyWith(
                      color: hasValue ? colors.primaryText : colors.secondaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppIcon(AppIcons.chevronDown, size: 20, color: colors.secondaryText),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            errorText!,
            style: AppTypography.labelSmall.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }

  Color _resolveBorderColor(AppColors colors, {required bool hasError}) {
    if (hasError) return colors.error;
    if (!_enabled) return colors.alternate.withValues(alpha: 0.5);
    return colors.alternate;
  }

  Color _resolveLabelColor(AppColors colors, {required bool hasError}) {
    if (hasError) return colors.error;
    if (!_enabled) return colors.secondaryText.withValues(alpha: 0.6);
    return colors.secondaryText;
  }
}
