import 'package:flutter/material.dart';
import 'theme_constants.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: ThemeConstants.fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: ThemeConstants.primaryBlue,
        secondary: ThemeConstants.accentYellow,
        surface: ThemeConstants.primaryWhite,
        background: ThemeConstants.grey50,
        error: ThemeConstants.error,
        onPrimary: ThemeConstants.primaryWhite,
        onSecondary: ThemeConstants.primaryBlue,
        onSurface: ThemeConstants.grey900,
        onBackground: ThemeConstants.grey900,
        onError: ThemeConstants.primaryWhite,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConstants.primaryBlue,
        foregroundColor: ThemeConstants.primaryWhite,
        elevation: ThemeConstants.elevationMedium,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ThemeConstants.primaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: ThemeConstants.fontFamily,
        ),
        iconTheme: IconThemeData(
          color: ThemeConstants.primaryWhite,
          size: ThemeConstants.iconMedium,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: ThemeConstants.primaryWhite,
        elevation: ThemeConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        ),
        margin: const EdgeInsets.all(ThemeConstants.spacing8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryBlue,
          foregroundColor: ThemeConstants.primaryWhite,
          elevation: ThemeConstants.elevationLow,
          minimumSize: const Size(double.infinity, ThemeConstants.buttonHeightMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: ThemeConstants.fontFamily,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeConstants.primaryBlue,
          minimumSize: const Size(double.infinity, ThemeConstants.buttonHeightMedium),
          side: const BorderSide(color: ThemeConstants.primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: ThemeConstants.fontFamily,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeConstants.primaryBlue,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: ThemeConstants.fontFamily,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ThemeConstants.accentYellow,
        foregroundColor: ThemeConstants.primaryBlue,
        elevation: ThemeConstants.elevationMedium,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConstants.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
          borderSide: const BorderSide(color: ThemeConstants.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacing16,
          vertical: ThemeConstants.spacing12,
        ),
        labelStyle: const TextStyle(
          color: ThemeConstants.grey600,
          fontSize: 16,
          fontFamily: ThemeConstants.fontFamily,
        ),
        hintStyle: const TextStyle(
          color: ThemeConstants.grey500,
          fontSize: 16,
          fontFamily: ThemeConstants.fontFamily,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey900,
          fontFamily: ThemeConstants.fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: ThemeConstants.grey800,
          fontFamily: ThemeConstants.fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: ThemeConstants.grey800,
          fontFamily: ThemeConstants.fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: ThemeConstants.grey600,
          fontFamily: ThemeConstants.fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey700,
          fontFamily: ThemeConstants.fontFamily,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey700,
          fontFamily: ThemeConstants.fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: ThemeConstants.grey600,
          fontFamily: ThemeConstants.fontFamily,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: ThemeConstants.grey700,
        size: ThemeConstants.iconMedium,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: ThemeConstants.grey300,
        thickness: 1,
        space: 1,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: ThemeConstants.grey200,
        selectedColor: ThemeConstants.primaryBlue,
        labelStyle: const TextStyle(
          color: ThemeConstants.grey800,
          fontFamily: ThemeConstants.fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
        ),
      ),
    );
  }
}
