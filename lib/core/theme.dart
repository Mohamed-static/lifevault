import "package:flutter/material.dart";

class AppColors {
  static const bgLight = Color(0xFFFAFAFA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceLightElevated = Color(0xFFF5F5F7);
  static const borderLight = Color(0xFFE5E5E8);

  static const bgDark = Color(0xFF131316);
  static const surfaceDark = Color(0xFF1C1C21);
  static const surfaceDarkElevated = Color(0xFF26262C);
  static const borderDark = Color(0xFF2E2E35);

  static const primary = Color(0xFF3366FF);
  static const primaryMuted = Color(0xFFE8EDFF);
  static const primaryLight = Color(0xFF3366FF);
  static const accent = Color(0xFF3366FF);
  static const gradientPrimary = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3366FF), Color(0xFF5B85FF)]);

  static const textPrimary = textPrimaryLight;
  static const textSecondary = textSecondaryLight;
  static const textPrimaryLight = Color(0xFF16161A);
  static const textSecondaryLight = Color(0xFF6B6B74);
  static const textPrimaryDark = Color(0xFFF2F2F4);
  static const textSecondaryDark = Color(0xFF9B9BA3);

  static const danger = Color(0xFFE5484D);
  static const dangerMuted = Color(0xFFFCE8E8);
  static const warning = Color(0xFFE5A000);
  static const warningMuted = Color(0xFFFFF4DC);
  static const success = Color(0xFF1A9E6B);
  static const successMuted = Color(0xFFE3F7EE);
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
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(primary: AppColors.primary, secondary: AppColors.primary, surface: AppColors.surfaceLight, error: AppColors.danger),
      fontFamily: "Roboto",
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimaryLight, letterSpacing: -0.3, height: 1.25),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight, letterSpacing: -0.2),
        titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        bodyLarge: TextStyle(fontSize: 15, color: AppColors.textPrimaryLight, height: 1.4),
        bodyMedium: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
        labelSmall: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500, letterSpacing: 0.2),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.bgLight, elevation: 0, scrolledUnderElevation: 0, foregroundColor: AppColors.textPrimaryLight, centerTitle: false, titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)), textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), elevation: 0)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimaryLight, side: const BorderSide(color: AppColors.borderLight), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.surfaceLightElevated, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14), isDense: true),
      cardTheme: CardThemeData(elevation: 0, color: AppColors.surfaceLight, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md), side: const BorderSide(color: AppColors.borderLight, width: 1))),
      dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1, space: 1),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(primary: AppColors.primary, secondary: AppColors.primary, surface: AppColors.surfaceDark, error: AppColors.danger),
      fontFamily: "Roboto",
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark, letterSpacing: -0.3, height: 1.25),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark, letterSpacing: -0.2),
        titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        bodyLarge: TextStyle(fontSize: 15, color: AppColors.textPrimaryDark, height: 1.4),
        bodyMedium: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark, height: 1.4),
        labelSmall: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w500, letterSpacing: 0.2),
      ),
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.bgDark, elevation: 0, scrolledUnderElevation: 0, foregroundColor: AppColors.textPrimaryDark, centerTitle: false, titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)), textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), elevation: 0)),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimaryDark, side: const BorderSide(color: AppColors.borderDark), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.surfaceDarkElevated, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.sm), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14), isDense: true),
      cardTheme: CardThemeData(elevation: 0, color: AppColors.surfaceDark, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md), side: const BorderSide(color: AppColors.borderDark, width: 1))),
      dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 1, space: 1),
    );
  }
}