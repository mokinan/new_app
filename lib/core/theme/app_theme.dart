import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_app/core/theme/app_colors.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.bgLight,
    textTheme: _buildTextTheme(isDark: false),
    appBarTheme: _appBarTheme(isDark: false),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    textButtonTheme: _textButtonTheme(),
    inputDecorationTheme: _inputDecorationTheme(isDark: false),
    cardTheme: _cardTheme(isDark: false),
    dividerTheme: const DividerThemeData(color: AppColors.dividerLight, thickness: 1),
    iconTheme: const IconThemeData(color: AppColors.textPrimaryLight, size: AppDimensions.iconMd),
  );

  // ─── Dark Theme ───────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.white,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    textTheme: _buildTextTheme(isDark: true),
    appBarTheme: _appBarTheme(isDark: true),
    elevatedButtonTheme: _elevatedButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),
    textButtonTheme: _textButtonTheme(),
    inputDecorationTheme: _inputDecorationTheme(isDark: true),
    cardTheme: _cardTheme(isDark: true),
    dividerTheme: const DividerThemeData(color: AppColors.dividerDark, thickness: 1),
    iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: AppDimensions.iconMd),
  );

  // ─── Private Builders ─────────────────────────────────────
  static TextTheme _buildTextTheme({required bool isDark}) {
    final color = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: color),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: color),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: color),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: color),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: color),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: color),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: color),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: color),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: color),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: color),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: color),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: color),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: color),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: color),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: color),
    );
  }

  static AppBarTheme _appBarTheme({required bool isDark}) => AppBarTheme(
    elevation: AppDimensions.appBarElevation,
    centerTitle: true,
    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    titleTextStyle: AppTextStyles.titleLarge.copyWith(
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    ),
    systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
  );

  static ElevatedButtonThemeData _elevatedButtonTheme() => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius)),
      textStyle: AppTextStyles.button,
      elevation: 0,
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonTheme() => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius)),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: AppTextStyles.button,
    ),
  );

  static TextButtonThemeData _textButtonTheme() => TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: AppTextStyles.button),
  );

  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) => InputDecorationTheme(
    filled: true,
    fillColor: isDark ? AppColors.cardDark : AppColors.grey100,
    contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.md),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    hintStyle: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textHintDark : AppColors.textHintLight),
  );

  static CardThemeData _cardTheme({required bool isDark}) => CardThemeData(
    elevation: AppDimensions.cardElevation,
    color: isDark ? AppColors.cardDark : AppColors.cardLight,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius)),
    margin: EdgeInsets.zero,
  );
}
