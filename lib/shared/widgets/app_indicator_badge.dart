import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Corner where the badge attaches to the child.
enum AppIndicatorPlacement { topRight, topLeft, bottomRight, bottomLeft }

/// A red badge overlaid on any child widget. Two display modes:
///
///   - **Dot** — small filled circle. Use for "there's something new"
///     without conveying quantity. Pass `count` = null.
///   - **Count** — pill with a number ("3", "12", "99+"). Use when
///     quantity matters. Pass `count` >= 1.
///
/// Both modes are hidden when `show` is false OR (in count mode) when
/// `count` is null/0.
///
/// Placement + offset let callers fine-tune position per host icon.
/// The default is top-right with a subtle inset that works for
/// AppIconButton (the primary consumer).
///
/// Example — bell icon with unread dot:
/// ```dart
/// AppIndicatorBadge(
///   show: hasUnread,
///   child: AppIconButton(icon: AppIcons.bell, onPressed: ...),
/// )
/// ```
///
/// Example — count badge on a filter icon:
/// ```dart
/// AppIndicatorBadge(
///   show: activeFilters > 0,
///   count: activeFilters,
///   placement: AppIndicatorPlacement.topLeft,
///   child: AppIconButton(icon: AppIcons.filter, onPressed: ...),
/// )
/// ```
class AppIndicatorBadge extends StatelessWidget {
  const AppIndicatorBadge({
    super.key,
    required this.child,
    required this.show,
    this.count,
    this.placement = AppIndicatorPlacement.topRight,
    this.offset = const Offset(6, 6),
    this.maxCount = 99,
  });

  final Widget child;

  /// Master visibility switch. When false, the badge is not rendered
  /// regardless of `count`. Keeps callers explicit about visibility
  /// (e.g., "hide badge for guest users" or "hide until data loads").
  final bool show;

  /// When null → dot mode. When non-null and > 0 → count mode
  /// ("3", "99+"). Count of 0 renders nothing regardless of `show`.
  final int? count;

  final AppIndicatorPlacement placement;

  /// Distance from the corner. Positive values pull toward the child's
  /// center; negative values push outside its bounds. Default keeps a
  /// dot nicely inset on a 44pt icon button.
  final Offset offset;

  /// Numeric ceiling for count mode. Renders "99+" beyond this.
  final int maxCount;

  static const double _dotSize = 8.0;

  @override
  Widget build(BuildContext context) {
    final resolvedCount = count;
    final visible = show && (resolvedCount == null || resolvedCount > 0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (visible)
          _positioned(
            placement: placement,
            offset: offset,
            child: IgnorePointer(
              child: resolvedCount == null
                  ? _Dot(size: _dotSize)
                  : _Count(value: resolvedCount, max: maxCount),
            ),
          ),
      ],
    );
  }

  static Widget _positioned({
    required AppIndicatorPlacement placement,
    required Offset offset,
    required Widget child,
  }) {
    switch (placement) {
      case AppIndicatorPlacement.topRight:
        return Positioned(top: offset.dy, right: offset.dx, child: child);
      case AppIndicatorPlacement.topLeft:
        return Positioned(top: offset.dy, left: offset.dx, child: child);
      case AppIndicatorPlacement.bottomRight:
        return Positioned(bottom: offset.dy, right: offset.dx, child: child);
      case AppIndicatorPlacement.bottomLeft:
        return Positioned(bottom: offset.dy, left: offset.dx, child: child);
    }
  }
}

/// Pure dot badge. Bordered with the background color to punch through
/// the child cleanly.
class _Dot extends StatelessWidget {
  const _Dot({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.error,
        shape: BoxShape.circle,
        border: Border.all(color: colors.primaryBackground, width: 1.5),
      ),
    );
  }
}

/// Pill count badge — "3", "12", "99+".
///
/// Brand-yellow fill (colors.secondary) with a fixed-dark label —
/// yellow is already the app's "attention" hue (bottom-nav active
/// state, star CTAs, level tags), so the badge ties in visually
/// rather than jumping out as a red foreign object. persistDark keeps
/// the number legible on the yellow across both themes.
class _Count extends StatelessWidget {
  const _Count({required this.value, required this.max});
  final int value;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final display = value > max ? '$max+' : '$value';
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        display,
        style: AppTypography.labelSmall.copyWith(
          color: colors.persistDark,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}
