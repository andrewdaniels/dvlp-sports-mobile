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
    this.footerStaysWithKeyboard = false,
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

  /// Set to true when the sheet's footer uses
  /// `AppScreenFooter(hideOnKeyboard: false)`. Skips the extra
  /// keyboard-up body padding (which is meant to compensate for a
  /// hidden footer) so the last input sits close to the persistent
  /// footer instead of being separated by a large gap.
  final bool footerStaysWithKeyboard;

  @override
  Widget build(BuildContext context) {
    // Bottom body padding accounts for keyboard visibility so the last
    // input isn't hidden under it when the footer is present (footer
    // collapses on keyboard-up, so body needs its own bottom breathing
    // room in that state). Footer owns its own SafeArea + keyboard-hide.
    //
    // When the footer opts out of the hide behavior
    // (footerStaysWithKeyboard), skip the extra padding — the footer
    // is still there taking up space, so doubling up creates a huge
    // gap between the last field and the CTA.
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;
    final keyboardVisible = media.viewInsets.bottom > 0;
    final footerVisibleAtBottom =
        footer != null && (!keyboardVisible || footerStaysWithKeyboard);
    final bodyBottomPad = footerVisibleAtBottom
        ? AppSpacing.md
        : safeBottom + AppSpacing.xl;

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
        // Footer owns its own horizontal padding, SafeArea, and
        // keyboard-hide (see AppScreenFooter). Just render it.
        ?footer,
      ],
    );
  }
}
