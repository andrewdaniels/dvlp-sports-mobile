import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import 'app_icon.dart';
import 'app_icon_button.dart';

/// App bar for detail / drill-down screens.
///
/// Different from the main-nav app bar in three ways:
/// - Back button leading (ghost [AppIconButton]) — pops the route.
/// - Title is CENTERED (main-nav pages left-align via [AppTheme]).
/// - Uses `titleMedium` typography — smaller than the `headlineMedium`
///   used on section landing pages, matching detail-page hierarchy.
///
/// Pass an optional [subtitle] to render a small secondary line beneath
/// the title (e.g., date + location for a game detail). The bar grows
/// taller when a subtitle is present so both lines fit cleanly.
///
/// Trailing [actions] are optional (help icon, more menu, etc). Pass
/// `AppIconButton`s or any widget — this bar just slots them in.
class AppDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppDetailAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;

  /// Optional secondary line below the title. Rendered in
  /// [AppTypography.labelSmall] + `secondaryText` color. When null,
  /// the bar stays at [kToolbarHeight]; when non-null, grows by
  /// [_subtitleExtra] to accommodate the extra line.
  final String? subtitle;

  final List<Widget> actions;

  /// Extra vertical space added to [kToolbarHeight] when [subtitle]
  /// is set. Sized to hold labelSmall + a small gap without cramping
  /// the vertical rhythm of the icon buttons.
  static const double _subtitleExtra = 16;

  @override
  Size get preferredSize => Size.fromHeight(
        subtitle == null ? kToolbarHeight : kToolbarHeight + _subtitleExtra,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    // When a subtitle is present, we render the title as a Column so
    // AppBar centers both lines as a single unit. titleTextStyle is
    // still set for the title Text; the subtitle styles inline.
    final titleWidget = hasSubtitle
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle!,
                style: AppTypography.labelSmall.copyWith(color: colors.secondaryText),
              ),
            ],
          )
        : Text(title);

    return AppBar(
      // Detail treatment overrides the global AppBarTheme (which is
      // left-aligned + headlineMedium for main-nav pages).
      centerTitle: true,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleTextStyle: AppTypography.titleMedium.copyWith(color: colors.primaryText),
      title: titleWidget,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AppIconButton(
            icon: AppIcons.chevronLeft,
            size: AppIconButtonSize.large,
            onPressed: () {
              HapticFeedback.lightImpact();
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
        ),
      ),
      actions: [
        ...actions,
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
