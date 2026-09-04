import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_sheet_header.dart';

/// Standard body layout for any sheet opened via `showAppSheet`:
/// a fixed [AppSheetHeader] pinned to the top of the sheet surface,
/// a scrolling body in the middle, and an optional fixed [footer]
/// pinned to the bottom.
///
/// Use this instead of composing `AppSheetHeader` + a scroll region
/// inline in every sheet — the header (and footer, when present)
/// must stay put while content scrolls, which requires the outer
/// widget to be a bounded Column with the scroll region wrapped in
/// `Expanded`.
///
/// `bodyPadding` defaults to horizontal `AppSpacing.md`. Safe-area
/// bottom padding is applied on the footer when present, otherwise
/// on the scrolling body.
class AppSheetLayout extends StatelessWidget {
  const AppSheetLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.bodyPadding = AppSheetInsets.padding,
  });

  final String title;
  final String? subtitle;

  /// Scrolling body content.
  final Widget child;

  /// Optional fixed footer pinned to the bottom of the sheet.
  /// Typically an `AppScreenFooter` with primary/secondary CTAs, but
  /// any widget works — this widget doesn't care about the shape.
  final Widget? footer;

  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;
    // Keyboard height. When > 0, an input is focused. We hide the
    // fixed footer in that state to give the athlete more room to
    // read the field they're editing. Return-key dismissal or
    // tap-outside brings the footer back.
    final keyboardVisible = media.viewInsets.bottom > 0;
    final showFooter = footer != null && !keyboardVisible;
    final bodyBottomPad = showFooter ? AppSpacing.md : safeBottom + AppSpacing.xl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetHeader(title: title, subtitle: subtitle),
        Flexible(
          child: SingleChildScrollView(
            padding: bodyPadding.add(EdgeInsets.only(bottom: bodyBottomPad)),
            child: child,
          ),
        ),
        if (footer != null)
          // AnimatedSize smoothly collapses / expands the footer's
          // height when the keyboard rises or dismisses. Duration +
          // curve tuned to match iOS's keyboard animation so the
          // two transitions feel continuous instead of racing.
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: showFooter
                ? Padding(
                    // Horizontal matches the body's bodyPadding so
                    // buttons line up under text; vertical passes
                    // through the safe-area inset.
                    padding: bodyPadding.add(EdgeInsets.only(bottom: safeBottom)),
                    child: footer!,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
