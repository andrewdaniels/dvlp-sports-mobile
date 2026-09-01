import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(
        brightness: Brightness.light,
        colors: AppColors.light,
      );

  static ThemeData dark() => _base(
        brightness: Brightness.dark,
        colors: AppColors.dark,
      );

  static ThemeData _base({required Brightness brightness, required AppColors colors}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onColor,
      secondary: colors.secondary,
      surface: colors.secondaryBackground,
      onSurface: colors.primaryText,
      error: colors.error,
      onError: colors.onColor,
    );

    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.primaryBackground,
      textTheme: AppTypography.materialTextTheme.apply(
        bodyColor: colors.primaryText,
        displayColor: colors.primaryText,
      ),
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primaryBackground,
        foregroundColor: colors.primaryText,
        elevation: 0,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: colors.primaryText),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.secondaryBackground,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.secondaryText,
        selectedLabelStyle: AppTypography.captionSemibold,
        unselectedLabelStyle: AppTypography.captionMedium,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.secondaryText,
        textColor: colors.primaryText,
      ),
      dividerTheme: DividerThemeData(
        color: colors.primaryText30,
        thickness: 0.5,
      ),
    );
  }
}
