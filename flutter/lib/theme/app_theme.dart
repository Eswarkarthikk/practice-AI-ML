import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const darkBg = Color(0xFF0D0F14);
  static const darkCard = Color(0xFF1E2130);
  static const darkBorder = Color(0xFF2A2D3E);
  static const textPrimary = Color(0xFFF4F7FF);
  static const textSecondary = Color(0xFF9AA4C8);
  static const purple = Color(0xFF6F63FF);
  static const purpleLight = Color(0xFF8E84FF);
  static const blue = Color(0xFF38BDF8);
  static const green = Color(0xFF2FE49B);
  static const orange = Color(0xFFFF9F0A);
  static const red = Color(0xFFFF3B30);

  static const lightBg = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFEEF2FF);
  static const lightBorder = Color(0xFFD8E0F2);
  static const lightTextPrimary = Color(0xFF16213F);
  static const lightTextSecondary = Color(0xFF5F6C8F);
  static const lightPurple = Color(0xFF5B4CE6);
}

class AppTheme {
  static ThemeData dark([BuildContext? context]) {
    final isTablet = context != null && MediaQuery.of(context).size.width >= 600;
    final scale = isTablet ? 1.35 : 1.0;

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.blue,
        surface: AppColors.darkCard,
        error: AppColors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 16 * scale),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13 * scale),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14 * scale)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
          borderSide: const BorderSide(color: AppColors.purple),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.darkCard,
          minimumSize: Size.fromHeight(50 * scale),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
          textStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 14 * scale),
        ),
      ),
    );

    final soraTextTheme = GoogleFonts.soraTextTheme(base.textTheme);
    final scaledTextTheme = soraTextTheme.copyWith(
      displayLarge: soraTextTheme.displayLarge?.copyWith(fontSize: (soraTextTheme.displayLarge?.fontSize ?? 57) * scale),
      displayMedium: soraTextTheme.displayMedium?.copyWith(fontSize: (soraTextTheme.displayMedium?.fontSize ?? 45) * scale),
      displaySmall: soraTextTheme.displaySmall?.copyWith(fontSize: (soraTextTheme.displaySmall?.fontSize ?? 36) * scale),
      headlineLarge: soraTextTheme.headlineLarge?.copyWith(fontSize: (soraTextTheme.headlineLarge?.fontSize ?? 32) * scale),
      headlineMedium: soraTextTheme.headlineMedium?.copyWith(fontSize: (soraTextTheme.headlineMedium?.fontSize ?? 28) * scale),
      headlineSmall: soraTextTheme.headlineSmall?.copyWith(fontSize: (soraTextTheme.headlineSmall?.fontSize ?? 24) * scale),
      titleLarge: soraTextTheme.titleLarge?.copyWith(fontSize: (soraTextTheme.titleLarge?.fontSize ?? 22) * scale),
      titleMedium: soraTextTheme.titleMedium?.copyWith(fontSize: (soraTextTheme.titleMedium?.fontSize ?? 16) * scale),
      titleSmall: soraTextTheme.titleSmall?.copyWith(fontSize: (soraTextTheme.titleSmall?.fontSize ?? 14) * scale),
      bodyLarge: soraTextTheme.bodyLarge?.copyWith(fontSize: (soraTextTheme.bodyLarge?.fontSize ?? 16) * scale),
      bodyMedium: soraTextTheme.bodyMedium?.copyWith(fontSize: (soraTextTheme.bodyMedium?.fontSize ?? 14) * scale),
      bodySmall: soraTextTheme.bodySmall?.copyWith(fontSize: (soraTextTheme.bodySmall?.fontSize ?? 12) * scale),
      labelLarge: soraTextTheme.labelLarge?.copyWith(fontSize: (soraTextTheme.labelLarge?.fontSize ?? 14) * scale),
      labelMedium: soraTextTheme.labelMedium?.copyWith(fontSize: (soraTextTheme.labelMedium?.fontSize ?? 12) * scale),
      labelSmall: soraTextTheme.labelSmall?.copyWith(fontSize: (soraTextTheme.labelSmall?.fontSize ?? 11) * scale),
    );

    return base.copyWith(
      textTheme: scaledTextTheme,
    );
  }

  static ThemeData light([BuildContext? context]) {
    final isTablet = context != null && MediaQuery.of(context).size.width >= 600;
    final scale = isTablet ? 1.35 : 1.0;

    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final theme = base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple),
      scaffoldBackgroundColor: AppColors.lightBg,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24 * scale),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 16 * scale),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14 * scale)),
      ),
    );

    final soraTextTheme = GoogleFonts.soraTextTheme(theme.textTheme);
    final scaledTextTheme = soraTextTheme.copyWith(
      displayLarge: soraTextTheme.displayLarge?.copyWith(fontSize: (soraTextTheme.displayLarge?.fontSize ?? 57) * scale),
      displayMedium: soraTextTheme.displayMedium?.copyWith(fontSize: (soraTextTheme.displayMedium?.fontSize ?? 45) * scale),
      displaySmall: soraTextTheme.displaySmall?.copyWith(fontSize: (soraTextTheme.displaySmall?.fontSize ?? 36) * scale),
      headlineLarge: soraTextTheme.headlineLarge?.copyWith(fontSize: (soraTextTheme.headlineLarge?.fontSize ?? 32) * scale),
      headlineMedium: soraTextTheme.headlineMedium?.copyWith(fontSize: (soraTextTheme.headlineMedium?.fontSize ?? 28) * scale),
      headlineSmall: soraTextTheme.headlineSmall?.copyWith(fontSize: (soraTextTheme.headlineSmall?.fontSize ?? 24) * scale),
      titleLarge: soraTextTheme.titleLarge?.copyWith(fontSize: (soraTextTheme.titleLarge?.fontSize ?? 22) * scale),
      titleMedium: soraTextTheme.titleMedium?.copyWith(fontSize: (soraTextTheme.titleMedium?.fontSize ?? 16) * scale),
      titleSmall: soraTextTheme.titleSmall?.copyWith(fontSize: (soraTextTheme.titleSmall?.fontSize ?? 14) * scale),
      bodyLarge: soraTextTheme.bodyLarge?.copyWith(fontSize: (soraTextTheme.bodyLarge?.fontSize ?? 16) * scale),
      bodyMedium: soraTextTheme.bodyMedium?.copyWith(fontSize: (soraTextTheme.bodyMedium?.fontSize ?? 14) * scale),
      bodySmall: soraTextTheme.bodySmall?.copyWith(fontSize: (soraTextTheme.bodySmall?.fontSize ?? 12) * scale),
      labelLarge: soraTextTheme.labelLarge?.copyWith(fontSize: (soraTextTheme.labelLarge?.fontSize ?? 14) * scale),
      labelMedium: soraTextTheme.labelMedium?.copyWith(fontSize: (soraTextTheme.labelMedium?.fontSize ?? 12) * scale),
      labelSmall: soraTextTheme.labelSmall?.copyWith(fontSize: (soraTextTheme.labelSmall?.fontSize ?? 11) * scale),
    );

    return theme.copyWith(
      textTheme: scaledTextTheme,
    );
  }
}
