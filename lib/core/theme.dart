import "package:flutter/material.dart";

class AppColors {
  static const bgDark = Color(0xFF0A0E1A);
  static const bgDarkSecondary = Color(0xFF12172B);
  static const surfaceDark = Color(0xFF1A2038);
  static const surfaceDarkElevated = Color(0xFF212845);

  static const bgLight = Color(0xFFF4F6FB);
  static const surfaceLight = Color(0xFFFFFFFF);

  static const primary = Color(0xFF6C5CE7);
  static const primaryLight = Color(0xFF8A7CF0);
  static const accent = Color(0xFF00D9C0);

  static const textPrimaryDark = Color(0xFFF2F3F8);
  static const textSecondaryDark = Color(0xFF8B93B0);
  static const textPrimaryLight = Color(0xFF161A2C);
  static const textSecondaryLight = Color(0xFF5D6480);

  static const danger = Color(0xFFFF5C7A);
  static const warning = Color(0xFFFFB238);
  static const success = Color(0xFF2ED9A3);

  static const borderDark = Color(0x1FFFFFFF);
  static const borderLight = Color(0x14161A2C);

  static const textPrimary = textPrimaryDark;
  static const textSecondary = textSecondaryDark;
  static const gradientPrimary = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6C5CE7), Color(0xFF00D9C0)]);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(primary: AppColors.primary, secondary: AppColors.accent, surface: AppColors.surfaceDark, error: AppColors.danger),
      fontFamily: "Roboto",
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark, letterSpacing: -0.3),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
        labelSmall: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.textPrimaryDark, centerTitle: false),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), elevation: 0)),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.surfaceDarkElevated, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderDark)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderDark)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), labelStyle: const TextStyle(color: AppColors.textSecondaryDark)),
      cardTheme: CardThemeData(elevation: 0, color: AppColors.surfaceDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg), side: const BorderSide(color: AppColors.borderDark))),
    );
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(primary: AppColors.primary, secondary: AppColors.accent, surface: AppColors.surfaceLight, error: AppColors.danger),
      fontFamily: "Roboto",
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight, letterSpacing: -0.3),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimaryLight),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
        labelSmall: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.textPrimaryLight, centerTitle: false),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), elevation: 0)),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.surfaceLight, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderLight)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderLight)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), labelStyle: const TextStyle(color: AppColors.textSecondaryLight)),
      cardTheme: CardThemeData(elevation: 0, color: AppColors.surfaceLight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg), side: const BorderSide(color: AppColors.borderLight))),
    );
  }
}

