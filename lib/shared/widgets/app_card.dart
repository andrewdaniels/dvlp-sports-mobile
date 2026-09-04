import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Container-style card used across passport / team / profile headers
/// and content blocks.
///
/// Three variants + a `prominent` bool that controls border weight.
/// Visual weight comes from border **color** (variant) and **thickness**
/// (`prominent`).
///
/// - `plain` (default) — `alternate` border, `secondaryBackground` fill.
///    Subtle presence.
/// - `unread` — `link` (blue) border, `secondaryBackground` fill.
///    Mid-prominence, used for unread feedback / attention states.
/// - `featured` — `secondary` (gold) border + mode-adaptive diagonal
///    blue-tinted background. Most prominent styling; pair with
///    `prominent: true` when the card is the visual anchor of the screen.
///
/// `prominent`:
/// - `false` (default) — **1px border**. Right for list items, toggle
///    groups, inline card usage. Cards don't shift by 1px when toggling
///    variants.
/// - `true` — **2px border**. Reserve for standalone hero cards.
///
/// Corner radius is auto-picked from variant/prominent:
/// - `featured + prominent` → `AppRadius.xxl` (20) — hero cards
/// - everything else → `AppRadius.lg` (12) — standard cards
/// Pass [radiusOverride] to opt out of the auto pick.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.plain,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.prominent = false,
    this.radiusOverride,
  });

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final bool prominent;

  /// Force a specific corner radius. Leave `null` to accept the auto
  /// pick (see class doc).
  final double? radiusOverride;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFeatured = variant == AppCardVariant.featured;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = _effectiveRadius;
    final borderWidth = prominent ? 2.0 : 1.0;

    // Gradient is dark-mode only — in light mode it reads as a
    // muddy wash. Featured cards in light mode use the plain
    // secondaryBackground fill and rely on the gold border alone
    // to signal prominence.
    final useGradient = isFeatured && isDark;

    return Container(
      decoration: BoxDecoration(
        gradient: useGradient ? _featuredGradientDark() : null,
        color: useGradient ? null : colors.secondaryBackground,
        border: Border.all(color: _borderColor(colors), width: borderWidth),
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: padding,
      child: child,
    );
  }

  double get _effectiveRadius {
    if (radiusOverride != null) return radiusOverride!;
    if (variant == AppCardVariant.featured && prominent) return AppRadius.xxl;
    return AppRadius.lg;
  }

  Color _borderColor(AppColors colors) {
    switch (variant) {
      case AppCardVariant.plain:
        return colors.alternate;
      case AppCardVariant.unread:
        return colors.link;
      case AppCardVariant.featured:
        return colors.secondary;
    }
  }

  /// Diagonal (~top-left → bottom-right) blue tint for featured
  /// cards in dark mode only. Light mode falls back to the plain
  /// card fill — see [build].
  ///
  /// Hardcoded `#13437E` (lighter variant of `primary`) →
  /// `secondaryBackground` dark, both @ 40%. One-off; hoist to
  /// AppColors if any other surface needs it.
  LinearGradient _featuredGradientDark() {
    return const LinearGradient(
      begin: Alignment(-0.75, -0.66),
      end: Alignment(0.75, 0.66),
      colors: [
        Color(0x6613437E),
        Color(0x66061932),
      ],
      stops: [0.045, 0.963],
    );
  }
}

enum AppCardVariant { plain, unread, featured }
