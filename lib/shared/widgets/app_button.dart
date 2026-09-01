import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Standard button.
///
/// Variants:
/// - `primary` — gold gradient CTA (Figma: Primary + Primary state)
/// - `secondary` — solid `brand.secondary` yellow (Figma: Secondary + Primary state)
/// - `outline` — transparent bg + 2px `alternate` border
/// - `text` — no bg or border; for tertiary actions (Skip / Cancel / See All / Learn more)
///
/// Sizes: `xs` (30h), `small` (36h), `medium` (48h), `large` (56h). Padding,
/// radius, icon size, and text style scale automatically.
///
/// Set `onPressed: null` to disable — matches Flutter's `ElevatedButton` idiom.
/// Icons take asset paths from [AppIcons] (nullable). Fires haptic feedback
/// on tap per AGENTS.md rules (medium for primary/secondary, light for outline/text).
///
/// `loading: true` swaps the label/icons for a spinner and blocks taps. Use it
/// while an async action tied to this button is in-flight (e.g., verifying an
/// invite code, submitting a form). Visual stays in the *active* variant — the
/// button reads as "working," not "disabled."
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.leadingIcon,
    this.trailingIcon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final String? leadingIcon;
  final String? trailingIcon;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = !loading && onPressed == null;
    final specs = _specs;
    final contentColor = _contentColor(context, disabled);

    Widget body = Container(
      height: specs.height,
      padding: EdgeInsets.symmetric(
        horizontal: specs.horizontalPadding,
        vertical: specs.verticalPadding,
      ),
      alignment: Alignment.center,
      decoration: _decoration(context, disabled),
      child: loading
          ? SizedBox(
              width: specs.iconSize,
              height: specs.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(contentColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  AppIcon(leadingIcon!, size: specs.iconSize, color: contentColor),
                  SizedBox(width: specs.gap),
                ],
                Text(label, style: specs.textStyle.copyWith(color: contentColor)),
                if (trailingIcon != null) ...[
                  SizedBox(width: specs.gap),
                  AppIcon(trailingIcon!, size: specs.iconSize, color: contentColor),
                ],
              ],
            ),
    );

    if (expand) {
      body = SizedBox(width: double.infinity, child: body);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (disabled || loading)
          ? null
          : () {
              _fireHaptic();
              onPressed!();
            },
      child: body,
    );
  }

  BoxDecoration _decoration(BuildContext context, bool disabled) {
    final colors = context.colors;
    final radius = BorderRadius.circular(_specs.radius);

    if (disabled) {
      switch (variant) {
        case AppButtonVariant.primary:
          return BoxDecoration(color: colors.alternate, borderRadius: radius);
        case AppButtonVariant.secondary:
          return BoxDecoration(color: colors.accent2Tint, borderRadius: radius);
        case AppButtonVariant.outline:
          return BoxDecoration(
            border: Border.all(color: colors.alternate, width: 2),
            borderRadius: radius,
          );
        case AppButtonVariant.text:
          return BoxDecoration(borderRadius: radius);
      }
    }

    switch (variant) {
      case AppButtonVariant.primary:
        // one-off: composite gradient of two tokens (tertiary → secondary).
        // Individual colors ARE tokens; the composite is what's local.
        // Hoist to AppGradients if used by any other surface.
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [colors.tertiary, colors.secondary],
          ),
          borderRadius: radius,
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(color: colors.secondary, borderRadius: radius);
      case AppButtonVariant.outline:
        return BoxDecoration(
          border: Border.all(color: colors.alternate, width: 2),
          borderRadius: radius,
        );
      case AppButtonVariant.text:
        return BoxDecoration(borderRadius: radius);
    }
  }

  Color _contentColor(BuildContext context, bool disabled) {
    final colors = context.colors;
    if (disabled) return colors.secondaryText;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        // Dark text on gold — always dark regardless of mode.
        return colors.persistDark;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return colors.primaryText;
    }
  }

  void _fireHaptic() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
        HapticFeedback.mediumImpact();
        break;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        HapticFeedback.lightImpact();
        break;
    }
  }

  _ButtonSpec get _specs {
    switch (size) {
      case AppButtonSize.xs:
        return _ButtonSpec(
          height: 30,
          horizontalPadding: 12,
          verticalPadding: 0,
          radius: 20,
          gap: 8,
          iconSize: 14,
          textStyle: AppTypography.bodySmall,
        );
      case AppButtonSize.small:
        return _ButtonSpec(
          height: 36,
          horizontalPadding: 16,
          verticalPadding: 0,
          radius: 20,
          gap: 12,
          iconSize: 16,
          textStyle: AppTypography.boldMedium,
        );
      case AppButtonSize.medium:
        return _ButtonSpec(
          height: 48,
          horizontalPadding: 20,
          verticalPadding: 0,
          radius: 40,
          gap: 12,
          iconSize: 20,
          textStyle: AppTypography.boldLarge,
        );
      case AppButtonSize.large:
        return _ButtonSpec(
          height: 56,
          horizontalPadding: 24,
          verticalPadding: 0,
          radius: 40,
          gap: 12,
          iconSize: 20,
          textStyle: AppTypography.titleSmall,
        );
    }
  }
}

enum AppButtonVariant { primary, secondary, outline, text }

enum AppButtonSize { xs, small, medium, large }

class _ButtonSpec {
  const _ButtonSpec({
    this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.radius,
    required this.gap,
    required this.iconSize,
    required this.textStyle,
  });

  final double? height;
  final double horizontalPadding;
  final double verticalPadding;
  final double radius;
  final double gap;
  final double iconSize;
  final TextStyle textStyle;
}
