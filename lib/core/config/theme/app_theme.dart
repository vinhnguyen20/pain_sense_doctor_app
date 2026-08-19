import 'package:flutter/material.dart';
import 'package:app_doctor/core/config/theme/app_typography.dart';
import 'package:app_doctor/core/config/theme/color_system.dart';
import 'package:app_doctor/core/config/theme/design_tokens.dart';

class AppTheme {
  // ===== LIGHT THEME COLORS =====
  static const lightPrimary = AppLightColors.primary;
  static const lightSecondary = AppLightColors.secondary;
  static const lightBackground = AppLightColors.background;
  static const lightSurface = AppLightColors.surface;
  static const lightError = AppLightColors.error;
  static const lightBorder = AppLightColors.border;

  // ===== DARK THEME COLORS =====
  static const darkPrimary = AppDarkColors.primary;
  static const darkSecondary = AppDarkColors.secondary;
  static const darkBackground = AppDarkColors.background;
  static const darkSurface = AppDarkColors.surface;
  static const darkError = AppDarkColors.error;
  static const darkBorder = AppDarkColors.border;

  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),

    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),

    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),

    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),

    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
  );
  static final RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppButtonRadius.md),
  );

  static const TextStyle _buttonLabelStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static ButtonStyle _filledButtonStyle(ColorScheme cs) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(double.minPositive, AppButtonSize.md),
      ),
      padding: const WidgetStatePropertyAll(AppButtonInset.md),
      textStyle: const WidgetStatePropertyAll(_buttonLabelStyle),
      shape: WidgetStatePropertyAll(_buttonShape),
      elevation: const WidgetStatePropertyAll(0),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withValues(alpha: 0.38);
        }
        return cs.onPrimary;
      }),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withValues(alpha: 0.12);
        }
        return cs.primary;
      }),
      overlayColor: WidgetStatePropertyAll(
        cs.onPrimary.withValues(alpha: 0.08),
      ),
    );
  }

  static ButtonStyle _outlinedButtonStyle(ColorScheme cs) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(double.minPositive, AppButtonSize.md),
      ),
      padding: const WidgetStatePropertyAll(AppButtonInset.md),
      textStyle: const WidgetStatePropertyAll(_buttonLabelStyle),
      shape: WidgetStatePropertyAll(_buttonShape),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withValues(alpha: 0.38);
        }
        return cs.onSurface;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: cs.outline.withValues(alpha: 0.35));
        }
        return BorderSide(color: cs.outline.withValues(alpha: 0.75));
      }),
      overlayColor: WidgetStatePropertyAll(cs.primary.withValues(alpha: 0.06)),
    );
  }

  static ButtonStyle _textButtonStyle(ColorScheme cs) {
    return ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, AppButtonSize.sm)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s8,
        ),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppButtonRadius.sm),
        ),
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return cs.onSurface.withValues(alpha: 0.38);
        }
        return cs.primary;
      }),
      overlayColor: WidgetStatePropertyAll(cs.primary.withValues(alpha: 0.08)),
    );
  }

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: lightPrimary,
    secondary: lightSecondary,
    surface: lightSurface,
    error: lightError,
    onPrimary: AppPalette.white,
    onSecondary: AppPalette.black,
    onSurface: AppPalette.black,
    onError: AppPalette.white,
    outline: lightBorder,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: darkPrimary,
    secondary: darkSecondary,
    surface: darkSurface,
    error: darkError,
    onPrimary: AppPalette.black,
    onSecondary: AppPalette.black,
    onSurface: AppPalette.white,
    onError: AppPalette.black,
    outline: darkBorder,
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,

    colorScheme: _lightColorScheme,
    extensions: const [AppSemanticColors.light],

    textTheme: textTheme,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: lightBackground,
      surfaceTintColor: lightBackground,
      foregroundColor: AppPalette.black,
      iconTheme: IconThemeData(color: AppPalette.black),
      toolbarHeight: AppSize.appBarHeight,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppPalette.black,
      ),
    ),

    cardTheme: const CardThemeData(
      elevation: 2,
      color: lightSurface,
      shape: RoundedRectangleBorder(borderRadius: AppCorners.r12),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _filledButtonStyle(_lightColorScheme),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _filledButtonStyle(_lightColorScheme),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _outlinedButtonStyle(_lightColorScheme),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _textButtonStyle(_lightColorScheme),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(borderRadius: AppCorners.r12),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: lightPrimary, width: AppBorder.strong),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: lightError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: lightError, width: AppBorder.strong),
      ),
      contentPadding: AppInsets.inputContent,
      hintStyle: TextStyle(fontSize: 14),
      isDense: true,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,

    colorScheme: _darkColorScheme,
    extensions: const [AppSemanticColors.dark],

    textTheme: textTheme,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: darkBackground,
      surfaceTintColor: darkBackground,
      foregroundColor: AppPalette.white,
      iconTheme: IconThemeData(color: AppPalette.white),
      toolbarHeight: AppSize.appBarHeight,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppPalette.white,
      ),
    ),

    cardTheme: const CardThemeData(
      elevation: 2,
      color: darkSurface,
      shape: RoundedRectangleBorder(borderRadius: AppCorners.r12),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _filledButtonStyle(_darkColorScheme),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _filledButtonStyle(_darkColorScheme),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _outlinedButtonStyle(_darkColorScheme),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _textButtonStyle(_darkColorScheme),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(borderRadius: AppCorners.r12),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: darkPrimary, width: AppBorder.strong),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: darkError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppCorners.r12,
        borderSide: BorderSide(color: darkError, width: AppBorder.strong),
      ),
      contentPadding: AppInsets.inputContent,
      hintStyle: TextStyle(fontSize: 14),
      isDense: true,
    ),
  );
}
