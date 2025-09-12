import 'package:flutter/material.dart';
import 'theme_constants.dart';

class AppTheme {
  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: ThemeConstants.primary,
      onPrimary: ThemeConstants.onPrimary,
      secondary: ThemeConstants.secondary,
      onSecondary: ThemeConstants.onSecondary,
      error: ThemeConstants.errorRed,
      onError: ThemeConstants.backgroundWhite,
      surface: ThemeConstants.surfaceGrey,
      onSurface: ThemeConstants.textPrimary,
      tertiary: ThemeConstants.accentYellow,
      onTertiary: ThemeConstants.textPrimary,
      primaryContainer: ThemeConstants.primary.withOpacity(0.12),
      onPrimaryContainer: ThemeConstants.primary,
      secondaryContainer: ThemeConstants.secondary.withOpacity(0.12),
      onSecondaryContainer: ThemeConstants.secondary,
      surfaceContainerHighest: ThemeConstants.backgroundWhite,
      outline: ThemeConstants.textSecondary.withOpacity(0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ThemeConstants.surfaceGrey,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: ThemeConstants.backgroundWhite,
        foregroundColor: ThemeConstants.textPrimary,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: ThemeConstants.backgroundWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
          side: BorderSide(color: ThemeConstants.primary.withOpacity(0.08)),
        ),
        margin: const EdgeInsets.all(ThemeConstants.spacingM),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: ThemeConstants.textSecondary),
        filled: true,
        fillColor: ThemeConstants.backgroundWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingM,
          vertical: ThemeConstants.spacingS,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: BorderSide(color: ThemeConstants.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: BorderSide(color: ThemeConstants.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: const BorderSide(color: ThemeConstants.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: const BorderSide(color: ThemeConstants.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          borderSide: const BorderSide(color: ThemeConstants.errorRed, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ThemeConstants.primaryButtonStyle,
      ),
      textTheme: const TextTheme(
        headlineSmall: ThemeConstants.heading2,
        titleMedium: ThemeConstants.heading3,
        bodyLarge: ThemeConstants.bodyLarge,
        bodyMedium: ThemeConstants.bodyMedium,
        bodySmall: ThemeConstants.bodySmall,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
      ),
    );
  }
}


