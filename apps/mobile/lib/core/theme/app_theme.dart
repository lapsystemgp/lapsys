import 'package:flutter/material.dart';

// TesTly brand palette (ported from apps/frontend/src/app/globals.css)
abstract final class AppColors {
  // Brand
  static const brand = Color(0xFF2563EB);
  static const brandStrong = Color(0xFF1D4ED8);

  // Neutrals
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF3F4F6);
  static const foreground = Color(0xFF111827);
  static const mutedForeground = Color(0xFF6B7280);
  static const lineSubtle = Color(0xFFE5E7EB);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFF0FDF4);
  static const warning = Color(0xFFFACC15);
  static const destructive = Color(0xFFDC2626);

  // Chart palette
  static const chart1 = Color(0xFFF97316);
  static const chart2 = Color(0xFF06B6D4);
  static const chart3 = Color(0xFF1E40AF);
  static const chart4 = Color(0xFFEAB308);

  // Dark mode equivalents
  static const backgroundDark = Color(0xFF111827);
  static const surfaceDark = Color(0xFF1F2937);
  static const surfaceMutedDark = Color(0xFF374151);
  static const foregroundDark = Color(0xFFF9FAFB);
  static const lineSubtleDark = Color(0xFF374151);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: Brightness.light,
          primary: AppColors.brand,
          onPrimary: Colors.white,
          secondary: AppColors.brandStrong,
          surface: AppColors.surface,
          onSurface: AppColors.foreground,
          error: AppColors.destructive,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surface,
        dividerColor: AppColors.lineSubtle,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.foreground,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.brand,
          unselectedItemColor: AppColors.mutedForeground,
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brand,
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: AppColors.brand),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.brand, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.destructive),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.lineSubtle),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: Brightness.dark,
          primary: AppColors.brand,
          onPrimary: Colors.white,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.foregroundDark,
          error: AppColors.destructive,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        cardColor: AppColors.surfaceDark,
        dividerColor: AppColors.lineSubtleDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.foregroundDark,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.brand,
          unselectedItemColor: AppColors.mutedForeground,
          type: BottomNavigationBarType.fixed,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceMutedDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.brand, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.destructive),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.lineSubtleDark),
          ),
        ),
      );
}
