import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color premiumBlue = Color(0xFF4793FF);

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'sanserif',
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        secondary: accentBlue,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFEAEAEA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1A1A1A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'sanserif',
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: premiumBlue,
        onPrimary: Colors.black,
        secondary: premiumBlue,
        onSecondary: Colors.black,
        surface: Color(0xFF16161D),
        onSurface: Color(0xFFF0F0F2),
        background: Color(0xFF0B0B0F),
        onBackground: Color(0xFFF0F0F2),
        error: Color(0xFFCF6679),
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0B0F),
      cardColor: const Color(0xFF16161D),
      dividerColor: const Color(0xFF222228),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0B0F),
        foregroundColor: Color(0xFFF0F0F2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B0B0F),
        selectedItemColor: premiumBlue,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF16161D),
        elevation: 0, // Flat premium look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF222228), width: 1),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF16161D),
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF16161D),
        contentTextStyle: TextStyle(color: Color(0xFFF0F0F2)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: premiumBlue, width: 1.5),
        ),
      ),
    );
  }
}
