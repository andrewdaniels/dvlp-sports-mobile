import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_icon_indicator.dart';

/// Centered focal message: tinted icon indicator + title + optional
/// subtitle. Same layout serves two use cases:
///
/// - **Empty state** — "No entries yet", "You haven't been assessed",
///   etc. (icon in a muted tone; subtitle explains what would fill it).
/// - **Informational state / success confirmation** — "Request Sent
///   Successfully" (icon in `success` green; subtitle confirms the
///   effect).
///
/// Composed on top of [AppIconIndicator]; typography follows
/// `titleMedium` (primary) + `bodyMedium` (secondary).
///
/// If a call-to-action button is ever needed inside the block, extend
/// with an optional `action: Widget?` prop rather than embedding
/// button logic here — keeps this widget structural.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    this.subtitle,
    this.iconSize = AppIconIndicatorSize.large,
  });

  /// SVG path from `AppIcons`.
  final String icon;
  final String title;
  final String? subtitle;

  /// The tint color for the icon indicator — use `colors.success` for
  /// confirmation, `colors.secondaryText` for empty states, etc.
  final Color iconColor;

  /// Defaults to `large` (64dp container) for the focal use case;
  /// callers can drop to `medium` for compact inline uses.
  final AppIconIndicatorSize iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasSubtitle = (subtitle ?? '').trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppIconIndicator(icon: icon, color: iconColor, size: iconSize),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.titleLarge.copyWith(color: colors.primaryText),
        ),
        if (hasSubtitle) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
          ),
        ],
      ],
    );
  }
}
