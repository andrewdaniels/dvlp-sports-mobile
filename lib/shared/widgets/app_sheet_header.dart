import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';
import 'app_icon_button.dart';

/// Standard header for sheets shown via `showAppSheet`.
///
/// - `title` (required) — rendered as `titleLarge`
/// - `subtitle` (optional) — rendered as `bodyMedium`; hidden if null/empty
/// - Close button on the far right — **large** ghost, top-aligned
///   with the title so the subtitle stays tight beneath the title
///   without a gap.
///
/// Layout:
///   Row(crossAxis: start, [
///     Expanded(Column([ title, subtitle? ])),
///     [X] large, top-aligned
///   ])
///
/// The subtitle lives inside the column next to the title, so it
/// wraps within the column's width and never runs under the close
/// button.
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
      // Top `md` gives consistent breathing room between the drag
      // handle and the title, regardless of subtitle length.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      // Stack (not Row) so the close button doesn't inflate the
      // header's layout height. In a Row, the button's 56dp box
      // would dominate a title-only header (~28dp text) and leave
      // ~28dp of empty space below the title before the body starts.
      // With a Stack, the Column of title + optional subtitle
      // determines the header's height; the close floats over the
      // top-right of that column.
      child: Stack(
        children: [
          // Right-padded so long titles don't run under the close.
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xxl),
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
          // Close pulled up 16dp so the icon (centered in its 56dp
          // box) aligns vertically with the title text's cap height.
          Positioned(
            top: -16,
            right: 0,
            child: AppIconButton(
              icon: AppIcons.close,
              onPressed: () => Navigator.of(context).pop(),
              size: AppIconButtonSize.large,
            ),
          ),
        ],
      ),
    );
  }
}
