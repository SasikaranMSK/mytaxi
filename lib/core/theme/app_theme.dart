import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF4CAF50);
  static const _surface = Color(0xFF1E2A32);
  static const _outline = Color(0xFF2C5364);

  static ThemeData get darkTheme {
    final scheme = const ColorScheme.dark(
      primary: _primary,
      surface: _surface,
      outline: _outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final scheme = const ColorScheme.light(
      primary: _primary,
      surface: Colors.white,
      outline: _outline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
