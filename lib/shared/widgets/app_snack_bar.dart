import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Toast semantics — informs styling (colored accent bar on the left)
/// but not layout. All variants use the same dark surface + primary
/// text so brand identity stays consistent across states.
enum AppSnackBarVariant {
  /// Neutral confirmation / info. Yellow accent (brand).
  info,

  /// Positive action outcome (created, saved, added).
  success,

  /// Recoverable error / warning ("Couldn't reach the network").
  /// Distinct from a full failure screen — snackbars are for transient
  /// messages the user can retry.
  error,
}

/// Brand-themed replacement for raw `ScaffoldMessenger.showSnackBar`.
/// Every toast in the app should go through [AppSnackBar.show] so the
/// styling (surface, radius, spacing, motion) stays consistent as we
/// add more transient messaging surfaces.
///
/// Behavior:
///   - Clears any in-flight snack before showing (avoids stacking).
///   - Auto-hides on a 3s duration for info/success; 5s for error
///     (users need more time to read failure copy).
///   - Floating behavior + rounded corners + horizontal margin so it
///     reads as an overlay chip rather than a full-bleed bar. Anchors
///     to the top of the bottom nav on shelled screens automatically
///     via `ScaffoldMessenger`'s existing safe-area handling.
///
/// Use:
///   `AppSnackBar.show(context, message: 'Athlete added')`
///   `AppSnackBar.show(context, message: '...', variant: AppSnackBarVariant.error)`
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarVariant variant = AppSnackBarVariant.info,
  }) {
    final colors = context.colors;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final accent = switch (variant) {
      AppSnackBarVariant.info => colors.secondary,
      AppSnackBarVariant.success => colors.success,
      AppSnackBarVariant.error => colors.error,
    };

    // Duration: give errors a longer read window; info/success are
    // action confirmations that the user already expects, so a short
    // dismiss is fine.
    final duration = variant == AppSnackBarVariant.error
        ? const Duration(seconds: 5)
        : const Duration(seconds: 3);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Left accent bar — 3px wide, full row height. Sits inside
            // the toast (rather than a border on the outer container)
            // so it can't be clipped by any parent theme.
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.secondaryBackground,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation: 6,
        duration: duration,
      ),
    );
  }
}
