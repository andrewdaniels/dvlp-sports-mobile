import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Shows a bottom sheet using our standard presentation:
/// - Light scrim (dimmed root page) via `overlay` color
/// - Frosted glass sheet: `BackdropFilter` blur behind a semi-transparent
///   `primaryBackground` — root content visible through the sheet
/// - Rounded top corners, custom drag handle
/// - Drag-to-dismiss + tap-outside dismiss enabled
/// - SafeArea + keyboard inset handled automatically
///
/// Compose the sheet body from [AppSheetHeader] + your content. Use this
/// instead of Flutter's `showModalBottomSheet` directly.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final colors = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    // Use root navigator so the sheet covers the shell's bottom nav —
    // otherwise a sheet opened inside a StatefulShellBranch lands above
    // the nav bar and looks cut off.
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: barrierDismissible,
    enableDrag: true,
    showDragHandle: false, // rendered inside the blur below
    useSafeArea: true,
    backgroundColor: Colors.transparent, // we render our own surface
    barrierColor: colors.overlay,
    builder: (context) => _AppSheetSurface(builder: builder),
  );
}

class _AppSheetSurface extends StatelessWidget {
  const _AppSheetSurface({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Frosted-glass (blur + transparent surface) only reads well
    // in dark mode. In light mode it feels washed out — fall back
    // to a solid surface with no blur.
    final surface = Container(
      decoration: BoxDecoration(
        color: isDark
            ? colors.primaryBackground.withValues(alpha: 0.4)
            : colors.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        border: Border.all(color: colors.primaryText30, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle — 4px pill, tight to the header
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xxs),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.primaryText30,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          Flexible(child: builder(context)),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        child: isDark
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: surface,
              )
            : surface,
      ),
    );
  }
}
