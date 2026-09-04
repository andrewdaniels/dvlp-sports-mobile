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
/// - Uses `titleSmall` typography — smaller than the `headlineMedium`
///   used on section landing pages, matching detail-page hierarchy.
///
/// Trailing [actions] are optional (help icon, more menu, etc). Pass
/// `AppIconButton`s or any widget — this bar just slots them in.
class AppDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppDetailAppBar({
    super.key,
    required this.title,
    this.actions = const [],
  });

  final String title;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppBar(
      // Detail treatment overrides the global AppBarTheme (which is
      // left-aligned + headlineMedium for main-nav pages).
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleTextStyle: AppTypography.titleMedium.copyWith(color: colors.primaryText),
      title: Text(title),
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
