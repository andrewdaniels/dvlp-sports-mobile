import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens for DVLP Sports.
///
/// Two font families:
///  - Instrument Sans (primary — all UI text)
///  - Anybody (display — badge scores and level labels, ExtraBold Italic only)
///
/// Line height set to 1.0 to match Figma's 100% setting. Adjust per usage
/// if it reads tight.
///
/// Source of truth: `design-tokens.json` / `design-system.md`.
class AppTypography {
  AppTypography._();

  static TextStyle _instrumentSans({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
  }) {
    return GoogleFonts.instrumentSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.0,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle anybody({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w800, // ExtraBold
    FontStyle fontStyle = FontStyle.italic,
    Color? color,
  }) {
    return GoogleFonts.anybody(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: 1.0,
      letterSpacing: 0,
      color: color,
    );
  }

  // Display
  static TextStyle get displayLarge => _instrumentSans(fontSize: 64, fontWeight: FontWeight.w700);
  static TextStyle get displayMedium => _instrumentSans(fontSize: 44, fontWeight: FontWeight.w700);
  static TextStyle get displaySmall => _instrumentSans(fontSize: 40, fontWeight: FontWeight.w700);

  // Headline
  static TextStyle get headlineLarge => _instrumentSans(fontSize: 36, fontWeight: FontWeight.w700);
  static TextStyle get headlineMedium => _instrumentSans(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle get headlineSmall => _instrumentSans(fontSize: 24, fontWeight: FontWeight.w700);

  // Title
  static TextStyle get titleXLarge => _instrumentSans(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle get titleLarge => _instrumentSans(fontSize: 20, fontWeight: FontWeight.w700);
  static TextStyle get titleMedium => _instrumentSans(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get titleSmall => _instrumentSans(fontSize: 16, fontWeight: FontWeight.w600);

  // Label
  static TextStyle get labelLarge => _instrumentSans(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle get labelMedium => _instrumentSans(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get labelSmall => _instrumentSans(fontSize: 12, fontWeight: FontWeight.w400);

  // Body
  static TextStyle get bodyLarge => _instrumentSans(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get bodyMedium => _instrumentSans(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get bodySmall => _instrumentSans(fontSize: 12, fontWeight: FontWeight.w500);

  // Bold (emphasis text at Label sizes)
  static TextStyle get boldLarge => _instrumentSans(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get boldMedium => _instrumentSans(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get boldSmall => _instrumentSans(fontSize: 12, fontWeight: FontWeight.w600);

  // Caption
  static TextStyle get captionMedium => _instrumentSans(fontSize: 10, fontWeight: FontWeight.w500);
  static TextStyle get captionSemibold => _instrumentSans(fontSize: 10, fontWeight: FontWeight.w600);

  /// Compose into Material TextTheme so Material widgets pick these up
  /// automatically. Widgets that need a specific project-defined style
  /// (e.g. `bold.large`, `caption.semibold`) should reference the
  /// getters directly.
  static TextTheme materialTextTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );
}
