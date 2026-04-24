import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Neon Premium (Basada en Capturas)
  static const Color primaryColor = Color(0xFF00F2FE); // Cyan Eléctrico
  static const Color primaryLight = Color(0xFF4FACFE); // Azul Cyan
  static const Color secondaryColor = Color(0xFFF7127C); // Rosa/Fucsia (Isolate logs/charts)
  static const Color accentColor = Color(0xFFFF9D42); // Naranja (Isolate charts)
  
  static const Color backgroundColor = Color(0xFF08090D); // Fondo casi negro
  static const Color surfaceColor = Color(0xFF13151D); // Fondo de tarjetas
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E92A3);
  
  static const Color errorColor = Color(0xFFFF4B2B);
  static const Color successColor = Color(0xFF00E676);
  static const Color skeletonBase = Color(0xFF1A1D26);
  static const Color skeletonHighlight = Color(0xFF2A2E3D);

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double cardRadius = 24.0;
  static const double buttonRadius = 14.0;

  static ThemeData get lightTheme => darkTheme; // Forzamos estética oscura como en capturas

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: const Color(0xFF08090D),
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2438),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: Color(0xFF2C334C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: const Color(0xFF08090D),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Color(0xFF08090D),
      ),
    );
  }
}
