import 'package:flutter/material.dart';

/// Color tokens for DVLP Sports.
///
/// Exposed as a [ThemeExtension] so widgets access them via
/// `Theme.of(context).extension<AppColors>()` and they automatically
/// swap between light/dark based on Brightness.
///
/// Source of truth: `design-tokens.json` / `design-system.md`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    // Brand
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.alternate,
    required this.onColor,
    // Utility
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryBgTint,
    required this.link,
    required this.overlay,
    required this.persistDark,
    required this.primaryText30,
    required this.primaryText70,
    // Semantic
    required this.success,
    required this.successTint,
    required this.error,
    required this.errorTint,
    required this.info,
    // Accent
    required this.accent1Tint,
    required this.accent2Tint,
    required this.accent3Tint,
  });

  // Brand
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color alternate;
  final Color onColor;

  // Utility
  final Color primaryText;
  final Color secondaryText;
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color primaryBgTint;
  final Color link;
  final Color overlay;
  final Color persistDark;
  final Color primaryText30;
  final Color primaryText70;

  // Semantic
  final Color success;
  final Color successTint;
  final Color error;
  final Color errorTint;
  final Color info;

  // Accent
  final Color accent1Tint;
  final Color accent2Tint;
  final Color accent3Tint;

  static AppColors light = const AppColors(
    // Brand
    primary: Color(0xFF0C3260),
    secondary: Color(0xFFFFD76D),
    tertiary: Color(0xFF9F7200),
    alternate: Color(0xFFD5DAE7),
    onColor: Color(0xFFFFFFFF),
    // Utility
    primaryText: Color(0xFF020101),
    secondaryText: Color(0xFF5D6174),
    primaryBackground: Color(0xFFF3F4F5),
    secondaryBackground: Color(0xFFFFFFFF),
    primaryBgTint: Color(0xCCF3F4F5), // 80%
    link: Color(0xFF3B89FF),
    overlay: Color(0x80031120), // 50%
    persistDark: Color(0xFF020101),
    primaryText30: Color(0x4D020101), // 30%
    primaryText70: Color(0xB2020101), // 70%
    // Semantic
    success: Color(0xFF00D388),
    successTint: Color(0x1A00D388), // 10%
    error: Color(0xFFE72B40),
    errorTint: Color(0x33E72B40), // 20%
    info: Color(0xFFFFFFFF), // flagged for designer review
    // Accent
    accent1Tint: Color(0x330C3260), // 20%
    accent2Tint: Color(0x33FFD76D), // 20%
    accent3Tint: Color(0x339F7200), // 20%
  );

  static AppColors dark = const AppColors(
    // Brand
    primary: Color(0xFF0C3260),
    secondary: Color(0xFFFFD76D),
    tertiary: Color(0xFF9F7200),
    alternate: Color(0xFF0C3260),
    onColor: Color(0xFFFFFFFF),
    // Utility
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xFF7A8CA7),
    primaryBackground: Color(0xFF031120),
    secondaryBackground: Color(0xFF061932),
    primaryBgTint: Color(0x99031120), // 60%
    link: Color(0xFF3B89FF),
    overlay: Color(0x99031120), // 60%
    persistDark: Color(0xFF020101),
    primaryText30: Color(0x4DFFFFFF), // 30%
    primaryText70: Color(0xB2FFFFFF), // 70%
    // Semantic
    success: Color(0xFF00D388),
    successTint: Color(0x1A00D388), // 10%
    error: Color(0xFFE72B40),
    errorTint: Color(0x4DE72B40), // 30%
    info: Color(0xFFFFFFFF), // flagged for designer review
    // Accent
    accent1Tint: Color(0x4D0C3260), // 30%
    accent2Tint: Color(0x4DFFD76D), // 30%
    accent3Tint: Color(0x4D9F7200), // 30%
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? alternate,
    Color? onColor,
    Color? primaryText,
    Color? secondaryText,
    Color? primaryBackground,
    Color? secondaryBackground,
    Color? primaryBgTint,
    Color? link,
    Color? overlay,
    Color? persistDark,
    Color? primaryText30,
    Color? primaryText70,
    Color? success,
    Color? successTint,
    Color? error,
    Color? errorTint,
    Color? info,
    Color? accent1Tint,
    Color? accent2Tint,
    Color? accent3Tint,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      alternate: alternate ?? this.alternate,
      onColor: onColor ?? this.onColor,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      primaryBgTint: primaryBgTint ?? this.primaryBgTint,
      link: link ?? this.link,
      overlay: overlay ?? this.overlay,
      persistDark: persistDark ?? this.persistDark,
      primaryText30: primaryText30 ?? this.primaryText30,
      primaryText70: primaryText70 ?? this.primaryText70,
      success: success ?? this.success,
      successTint: successTint ?? this.successTint,
      error: error ?? this.error,
      errorTint: errorTint ?? this.errorTint,
      info: info ?? this.info,
      accent1Tint: accent1Tint ?? this.accent1Tint,
      accent2Tint: accent2Tint ?? this.accent2Tint,
      accent3Tint: accent3Tint ?? this.accent3Tint,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      alternate: Color.lerp(alternate, other.alternate, t)!,
      onColor: Color.lerp(onColor, other.onColor, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      primaryBackground: Color.lerp(primaryBackground, other.primaryBackground, t)!,
      secondaryBackground: Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      primaryBgTint: Color.lerp(primaryBgTint, other.primaryBgTint, t)!,
      link: Color.lerp(link, other.link, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      persistDark: Color.lerp(persistDark, other.persistDark, t)!,
      primaryText30: Color.lerp(primaryText30, other.primaryText30, t)!,
      primaryText70: Color.lerp(primaryText70, other.primaryText70, t)!,
      success: Color.lerp(success, other.success, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
      info: Color.lerp(info, other.info, t)!,
      accent1Tint: Color.lerp(accent1Tint, other.accent1Tint, t)!,
      accent2Tint: Color.lerp(accent2Tint, other.accent2Tint, t)!,
      accent3Tint: Color.lerp(accent3Tint, other.accent3Tint, t)!,
    );
  }
}

/// Sugar accessor: `context.colors.primary` instead of
/// `Theme.of(context).extension<AppColors>()!.primary`.
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
