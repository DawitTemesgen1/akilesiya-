import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Light Theme Colors ---
  static const Color primary = Color(0xFF0D253C);
  static const Color primaryLight = Color.fromARGB(255, 242, 243, 245);
  static const Color accent = Color(0xFFFFD700);
  static const Color background = Color(0xFFF4F7FC);
  static const Color surface = Color.fromARGB(255, 219, 213, 213);
  static const Color onSurface = Color.fromARGB(255, 2, 26, 49);

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF1A1A2E); // Deep Navy Blue
  static const Color darkSurface = Color(0xFF2A2A3E); // Elevated surface
  static const Color darkOnSurface = Color(0xFFEAEAF1); // Soft off-white text
  static const Color darkPrimary =
      Color(0xFF1E3A5F); // Lighter navy for dark mode
  static const Color darkAccent = Color(0xFFFFD700); // Gold accent (same)

  // --- Text Colors (Light) ---
  static const Color textPrimary = Color.fromARGB(255, 250, 250, 255);
  static const Color textSecondary = Color.fromARGB(255, 251, 251, 255);
  static const Color textLight = Colors.white;

  // --- Text Colors (Dark) ---
  static const Color darkTextPrimary = Color(0xFFEAEAF1);
  static const Color darkTextSecondary = Color(0xFFB0B0C0);

  // --- Semantic Colors ---
  static const Color success = Color(0xFF28A745);
  static const Color danger = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // --- Text Styles for Light Theme ---
  static final TextStyle headline1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color.fromARGB(255, 245, 245, 250),
  );

  static final TextStyle headline2 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: const Color.fromARGB(255, 243, 243, 248),
  );

  static final TextStyle bodyText = GoogleFonts.lato(
    fontSize: 14,
    color: const Color.fromARGB(255, 253, 253, 253),
    height: 1.5,
  );

  static final TextStyle chipText = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: const Color.fromARGB(255, 255, 255, 255),
  );

  // --- Text Styles for Dark Theme ---
  static final TextStyle darkHeadline1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkTextPrimary,
  );

  static final TextStyle darkHeadline2 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: darkTextPrimary,
  );

  static final TextStyle darkBodyText = GoogleFonts.lato(
    fontSize: 14,
    color: darkTextSecondary,
    height: 1.5,
  );
}
