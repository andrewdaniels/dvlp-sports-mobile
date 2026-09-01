import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';
import 'app_icon_button.dart';

/// Standard header for sheets shown via `showAppSheet`.
///
/// - `title` (required) — rendered as `titleLarge`
/// - `subtitle` (optional) — rendered as `bodyMedium`; hidden if null/empty
/// - Close button on the far right — **large** ghost `AppIconButton` with
///   the `close` icon. Always pops the current route.
class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(color: colors.primaryText),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMedium.copyWith(color: colors.secondaryText),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconButton(
            icon: AppIcons.close,
            onPressed: () => Navigator.of(context).pop(),
            size: AppIconButtonSize.large,
          ),
        ],
      ),
    );
  }
}
