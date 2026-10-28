import 'package:flutter/material.dart';

final ThemeData temaSenderos = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF1F5A8C),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD3E4F5),
    onPrimaryContainer: Color(0xFF0B2A4A),
    secondary: Color(0xFF4F6478),
    secondaryContainer: Color(0xFFD9E4EF),
    onSecondaryContainer: Color(0xFF0B1D2E),
    tertiary: Color(0xFFB86E00),
    surface: Colors.white,
    onSurface: Color(0xFF14213D),
    outline: Color(0xFF74808F),
    error: Color(0xFFBA1A1A),
  ),
  scaffoldBackgroundColor: const Color(0xFFF2F6FA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF2F6FA),
    titleTextStyle: TextStyle(
      color: Color(0xFF1F5A8C),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
);
