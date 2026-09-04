import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/theme.dart';
import 'app_chevron_right.dart';
import 'app_icon.dart';

/// Tappable "drill-in" row for menus, settings lists, and any surface
/// where the user is being invited to navigate deeper. Renders:
///
///   [leadingIcon?]  [label]                                 [›]
///                   [description?]
///
/// Composes cleanly inside an `AppCard(padding: EdgeInsets.zero, ...)`
/// with `AppDivider` between rows, or standalone on a page.
///
/// Hit-target behavior (baked in — callers don't need to worry):
///   • `HitTestBehavior.opaque` so the row's full internal padding is
///     tappable, not just the icon/text pixels.
///   • Stretches to the parent's max width so the whole row-width
///     receives taps.
///   • Minimum 56dp height (matches Material list-tile floor; exceeds
///     Apple's 44pt guideline) so a title-only row still has a
///     generous vertical hit area.
///
/// The leading icon is auto-sized to 24px and colored `link` — same
/// treatment across every call site. If a future variant needs a
/// different tint (destructive, warning, etc.), add a `leadingIconColor`
/// override then.
class AppLinkRow extends StatelessWidget {
  const AppLinkRow({
    super.key,
    required this.label,
    required this.onTap,
    this.description,
    this.leadingIcon,
  });

  /// Primary text — `bodyLarge` in `primaryText`.
  final String label;

  /// Secondary line under the label — `captionMedium` in
  /// `secondaryText`. Hidden entirely when null or empty.
  final String? description;

  /// AppIcons SVG path. Rendered at 24px in `colors.link`. Hidden
  /// entirely when null.
  final String? leadingIcon;

  /// Required — every AppLinkRow navigates or performs an action.
  /// A row that doesn't do anything on tap isn't a link row (use a
  /// display row primitive instead).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDescription = (description ?? '').trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  AppIcon(leadingIcon!, size: 24, color: colors.link),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTypography.bodyLarge.copyWith(color: colors.primaryText),
                      ),
                      if (hasDescription) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          description!,
                          style: AppTypography.captionMedium.copyWith(color: colors.secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const AppChevronRight(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
