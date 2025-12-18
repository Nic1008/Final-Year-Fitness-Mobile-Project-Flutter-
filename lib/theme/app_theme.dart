import 'package:flutter/material.dart';

class AppTheme {
  // ---------------- LIGHT THEME ----------------
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 100, 97, 91), // main accent
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F5F9),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0.4,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
    dividerColor: Color(0xFFE0E3E7),
  );

  // ---------------- DARK THEME ----------------
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF050509),
    cardColor: const Color(0xFF15161A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF15161A),
      foregroundColor: Colors.white,
      elevation: 0.4,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white60),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    dividerColor: Color(0xFF2D3138),
  );
}
