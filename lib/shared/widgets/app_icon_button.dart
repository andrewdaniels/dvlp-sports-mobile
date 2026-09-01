import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';

/// Icon-only button. Circular tap target, sized per [size].
///
/// Variants:
/// - `primary` — gold gradient (matches AppButton primary)
/// - `secondary` — solid `brand.secondary` yellow
/// - `outline` — transparent bg + 2px `alternate` border
/// - `ghost` — no bg, no border; just the icon in a tap target. Default.
/// - `tinted` — 2px `tintColor` border + `tintColor @ 20%` fill + `primaryText`
///    icon (adapts per mode). Use for semantic accent buttons (secondaryText,
///    error, etc). `tintColor` defaults to `secondaryText` when null.
///
/// Sizes: `xs` (30), `small` (36), `medium` (48), `large` (56) — matches
/// AppButton so icon buttons align cleanly next to text buttons.
///
/// `onPressed: null` → disabled. Haptic: medium for primary/secondary,
/// light for outline/ghost/tinted.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.size = AppIconButtonSize.medium,
    this.tintColor,
  });

  final String icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppIconButtonSize size;

  /// Only used when `variant == AppIconButtonVariant.tinted`. Falls back to
  /// `context.colors.secondaryText` when null.
  final Color? tintColor;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final specs = _specs;
    final iconColor = _iconColor(context, disabled);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled
          ? null
          : () {
              _fireHaptic();
              onPressed!();
            },
      child: Container(
        width: specs.dimension,
        height: specs.dimension,
        alignment: Alignment.center,
        decoration: _decoration(context, disabled),
        child: AppIcon(icon, size: specs.iconSize, color: iconColor),
      ),
    );
  }

  BoxDecoration _decoration(BuildContext context, bool disabled) {
    final colors = context.colors;

    if (disabled) {
      switch (variant) {
        case AppIconButtonVariant.primary:
          return BoxDecoration(color: colors.alternate, shape: BoxShape.circle);
        case AppIconButtonVariant.secondary:
          return BoxDecoration(color: colors.accent2Tint, shape: BoxShape.circle);
        case AppIconButtonVariant.outline:
        case AppIconButtonVariant.tinted:
          return BoxDecoration(
            border: Border.all(color: colors.alternate, width: 2),
            shape: BoxShape.circle,
          );
        case AppIconButtonVariant.ghost:
          return const BoxDecoration(shape: BoxShape.circle);
      }
    }

    switch (variant) {
      case AppIconButtonVariant.primary:
        // one-off: composite gradient of two tokens (tertiary → secondary).
        // Individual colors ARE tokens; the composite is what's local.
        // Same gradient as AppButton primary — hoist to AppGradients if
        // a third surface adopts it.
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [colors.tertiary, colors.secondary],
          ),
          shape: BoxShape.circle,
        );
      case AppIconButtonVariant.secondary:
        return BoxDecoration(color: colors.secondary, shape: BoxShape.circle);
      case AppIconButtonVariant.outline:
        return BoxDecoration(
          border: Border.all(color: colors.alternate, width: 2),
          shape: BoxShape.circle,
        );
      case AppIconButtonVariant.ghost:
        return const BoxDecoration(shape: BoxShape.circle);
      case AppIconButtonVariant.tinted:
        final tint = tintColor ?? colors.secondaryText;
        return BoxDecoration(
          color: tint.withValues(alpha: 0.20),
          border: Border.all(color: tint, width: 2),
          shape: BoxShape.circle,
        );
    }
  }

  Color _iconColor(BuildContext context, bool disabled) {
    final colors = context.colors;
    if (disabled) return colors.secondaryText;
    switch (variant) {
      case AppIconButtonVariant.primary:
      case AppIconButtonVariant.secondary:
        return colors.persistDark;
      case AppIconButtonVariant.outline:
      case AppIconButtonVariant.ghost:
        return colors.primaryText;
      case AppIconButtonVariant.tinted:
        // `primaryText` adapts per mode (white in dark, near-black in light)
        // so the icon has proper contrast on tinted fills in both themes.
        return colors.primaryText;
    }
  }

  void _fireHaptic() {
    switch (variant) {
      case AppIconButtonVariant.primary:
      case AppIconButtonVariant.secondary:
        HapticFeedback.mediumImpact();
        break;
      case AppIconButtonVariant.outline:
      case AppIconButtonVariant.ghost:
      case AppIconButtonVariant.tinted:
        HapticFeedback.lightImpact();
        break;
    }
  }

  _IconButtonSpec get _specs {
    switch (size) {
      case AppIconButtonSize.xs:
        return const _IconButtonSpec(dimension: 30, iconSize: 14);
      case AppIconButtonSize.small:
        return const _IconButtonSpec(dimension: 36, iconSize: 16);
      case AppIconButtonSize.medium:
        return const _IconButtonSpec(dimension: 48, iconSize: 20);
      case AppIconButtonSize.large:
        return const _IconButtonSpec(dimension: 56, iconSize: 24);
    }
  }
}

enum AppIconButtonVariant { primary, secondary, outline, ghost, tinted }

enum AppIconButtonSize { xs, small, medium, large }

class _IconButtonSpec {
  const _IconButtonSpec({required this.dimension, required this.iconSize});
  final double dimension;
  final double iconSize;
}
