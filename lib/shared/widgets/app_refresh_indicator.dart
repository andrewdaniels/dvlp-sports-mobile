import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Standard pull-to-refresh wrapper. Applies our app-consistent
/// colors — `primaryText` spinner + `accent1Tint` blue chip — that
/// Flutter's built-in `ProgressIndicatorThemeData` doesn't fully
/// pipe through to the RefreshIndicator's inner spinner (its color
/// falls back to `colorScheme.primary` unless set at the widget
/// level).
///
/// Same API as `RefreshIndicator` (`onRefresh` + `child`). Use this
/// instead of the raw Flutter widget so callers stay
/// theme-consistent without repeating the color/background props.
class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.primaryText,
      backgroundColor: colors.accent1Tint,
      child: child,
    );
  }
}
