import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'app_button.dart';

/// Fixed-bottom footer that holds the primary action(s) of a screen.
///
/// Owns the standard spacing above the buttons (`md`) plus a small
/// `md` gap below so the buttons never touch the keyboard when the
/// system keyboard is up (SafeArea's bottom inset collapses to 0 in
/// that state). When the keyboard is down, this `md` stacks on top
/// of the home-indicator SafeArea inset — a bit taller than a bare
/// footer but consistent across keyboard-open and keyboard-closed.
///
/// Pick the factory that matches the CTA shape:
///  - [single]  — one full-width button
///  - [row]     — two buttons side-by-side, equal width. Primary sits on
///                the right, secondary on the left (iOS convention:
///                destructive/back is outboard).
///  - [stacked] — two full-width buttons in a column. Primary on top,
///                secondary below (matches iOS vertical alert order).
///
/// Callers always pass [AppButton] instances so the CTA type is
/// enforced. Buttons don't need `expand: true`; the footer forces
/// full-width layout for [single] and [stacked], and `Expanded` handles
/// it for [row].
class AppScreenFooter extends StatelessWidget {
  const AppScreenFooter._({required this.child});

  factory AppScreenFooter.single({required AppButton primary}) {
    return AppScreenFooter._(
      child: SizedBox(width: double.infinity, child: primary),
    );
  }

  factory AppScreenFooter.row({
    required AppButton primary,
    required AppButton secondary,
  }) {
    return AppScreenFooter._(
      child: Row(
        children: [
          Expanded(child: secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: primary),
        ],
      ),
    );
  }

  factory AppScreenFooter.stacked({
    required AppButton primary,
    required AppButton secondary,
  }) {
    return AppScreenFooter._(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: double.infinity, child: primary),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(width: double.infinity, child: secondary),
        ],
      ),
    );
  }

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: child,
    );
  }
}
