import 'package:flutter/widgets.dart';

/// Spacing scale for DVLP Sports.
///
/// Observed in Figma: 0, 12, 20, 24. Extended to typical scale for common use.
class AppSpacing {
  AppSpacing._();

  static const double none = 0;
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
}

/// Standard padding for top-level scrollable page content. Applied at
/// the outermost `ListView` / `SingleChildScrollView` so every page
/// starts and ends at the same position and shares the same horizontal
/// gutter. Sides are declared independently — bottom is usually larger
/// than top to leave breathing room above the bottom nav and signal
/// scroll clearance. Change tokens here to shift the whole app's page
/// framing in one edit.
class AppPageInsets {
  AppPageInsets._();

  /// Horizontal gutter (left/right).
  static const double horizontal = AppSpacing.md; // 16

  /// Top inset of the scrollable column.
  static const double top = AppSpacing.md;        // 16

  /// Bottom inset of the scrollable column. The shell sets `extendBody:
  /// true` so page content renders *behind* the blurred bottom nav —
  /// this inset (2× our largest token) guarantees the last item clears
  /// the nav + safe area and gives a clear "end of scroll" signal.
  static const double bottom = AppSpacing.huge * 3; // 144

  /// Full page inset composed from [horizontal], [top], [bottom]. Use
  /// as `padding: AppPageInsets.padding` on the outermost scroll view.
  static const EdgeInsets padding = EdgeInsets.fromLTRB(
    horizontal, top, horizontal, bottom,
  );
}
