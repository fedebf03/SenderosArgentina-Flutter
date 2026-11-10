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
    onSurfaceVariant: Color(0xFF4A5A70),
    outline: Color(0xFF74808F),
    outlineVariant: Color(0xFFD3DEE9),
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

// Modo oscuro: misma paleta azul, aclarada para leerse bien sobre fondo oscuro
final ThemeData temaSenderosOscuro = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF9CC7EE),
    onPrimary: Color(0xFF0B2A4A),
    primaryContainer: Color(0xFF16466F),
    onPrimaryContainer: Color(0xFFD3E4F5),
    secondary: Color(0xFFB4C8DB),
    secondaryContainer: Color(0xFF374B5E),
    onSecondaryContainer: Color(0xFFD9E4EF),
    tertiary: Color(0xFFFFB866),
    surface: Color(0xFF16202C),
    onSurface: Color(0xFFE2E9F1),
    onSurfaceVariant: Color(0xFFB0BCCA),
    outline: Color(0xFF8A96A4),
    outlineVariant: Color(0xFF34424F),
    error: Color(0xFFFFB4AB),
  ),
  scaffoldBackgroundColor: const Color(0xFF0E1620),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0E1620),
    titleTextStyle: TextStyle(
      color: Color(0xFF9CC7EE),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
);
