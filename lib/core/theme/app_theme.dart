import 'package:flutter/material.dart';

class AppTheme {
  static const Color gold = Color(0xFFE59D2C);
  static const Color lightGold = Color(0xFFF3D58D);
  static const Color cream = Color(0xFFEBDDC5);
  static const Color navy = Color(0xFF2E4365);
  static const Color darkBrown = Color(0xFF8A3B08);

  static ThemeData theme = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: gold,
      secondary: navy,
      surface: cream,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: gold,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: Colors.white,
      ),
    ),
  );
}