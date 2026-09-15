import 'package:flutter/material.dart';
import 'design_tokens.dart';

abstract final class MediKioskTheme {
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: DesignTokens.primary700,
      onPrimary: DesignTokens.white,
      primaryContainer: DesignTokens.primary100,
      onPrimaryContainer: DesignTokens.primary900,
      secondary: DesignTokens.primary500,
      onSecondary: DesignTokens.white,
      secondaryContainer: DesignTokens.primary50,
      onSecondaryContainer: DesignTokens.primary900,
      tertiary: DesignTokens.info500,
      onTertiary: DesignTokens.white,
      tertiaryContainer: DesignTokens.info100,
      onTertiaryContainer: DesignTokens.info700,
      error: DesignTokens.critical500,
      onError: DesignTokens.white,
      errorContainer: DesignTokens.critical100,
      onErrorContainer: DesignTokens.critical700,
      surface: DesignTokens.white,
      onSurface: DesignTokens.neutral950,
      onSurfaceVariant: DesignTokens.neutral700,
      outline: DesignTokens.neutral300,
      outlineVariant: DesignTokens.neutral200,
      shadow: DesignTokens.neutral950,
      surfaceContainerHighest: DesignTokens.neutral100,
      surfaceContainerLow: DesignTokens.neutral50,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DesignTokens.neutral50,
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.primary900,
        foregroundColor: DesignTokens.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: body.copyWith(
          color: DesignTokens.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: DesignTokens.white,
        elevation: DesignTokens.elevationCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMD,
          vertical: DesignTokens.spacingSM,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(DesignTokens.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.buttonHorizontalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          ),
          textStyle: buttonText.copyWith(color: DesignTokens.white),
          backgroundColor: DesignTokens.primary700,
          foregroundColor: DesignTokens.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(DesignTokens.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.buttonHorizontalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          ),
          textStyle: buttonText.copyWith(color: DesignTokens.primary700),
          side: const BorderSide(color: DesignTokens.primary700, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMD,
          vertical: DesignTokens.spacingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
          borderSide: const BorderSide(color: DesignTokens.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
          borderSide: const BorderSide(color: DesignTokens.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
          borderSide: const BorderSide(
            color: DesignTokens.primary500,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
          borderSide: const BorderSide(color: DesignTokens.critical500),
        ),
        hintStyle: body.copyWith(color: DesignTokens.neutral500),
      ),
      dividerTheme: const DividerThemeData(
        color: DesignTokens.neutral200,
        thickness: 1,
        space: 1,
      ),
    );
  }
}