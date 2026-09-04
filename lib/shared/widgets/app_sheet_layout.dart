import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_sheet_header.dart';

/// Standard body layout for any sheet opened via `showAppSheet`:
/// a fixed [AppSheetHeader] pinned to the top of the sheet surface,
/// and a scrolling body underneath.
///
/// Use this instead of composing `AppSheetHeader` + `SingleChildScrollView`
/// inline in every sheet — the header must stay put while content
/// scrolls, which requires the outer widget to be a bounded Column
/// with the scroll region wrapped in `Expanded`.
///
/// `bodyPadding` defaults to horizontal `AppSpacing.md`. The bottom
/// padding + safe-area inset are handled here so callers don't need
/// their own SafeArea wrappers.
class AppSheetLayout extends StatelessWidget {
  const AppSheetLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetHeader(title: title, subtitle: subtitle),
        Flexible(
          child: SingleChildScrollView(
            padding: bodyPadding.add(
              EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
              ),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}
