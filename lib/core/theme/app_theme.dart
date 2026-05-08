import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F1A),
    primaryColor: const Color(0xFF6B4EE6),
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF161625),
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: const Color(0xFF1E1B2E),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B4EE6),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1B2E),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6B4EE6),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF161625),
      selectedItemColor: Color(0xFF6B4EE6),
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5FA),
    primaryColor: const Color(0xFF6B4EE6),
    useMaterial3: true,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
      displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
      displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87),
      headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.black87),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.black87),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
    ),
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B4EE6),
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6B4EE6),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF6B4EE6),
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
