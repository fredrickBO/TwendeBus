// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryColor = Color.fromARGB(
    255,
    32,
    159,
    239,
  ); // Main Teal/Green
  static const Color secondaryColor = Color.fromARGB(
    255,
    2,
    85,
    13,
  ); // Lighter Blue/Teal for buttons
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Color(0xFF1E1E1E);
  static const Color subtleTextColor = Color.fromARGB(255, 130, 149, 165);
  static const Color cardColor = Color.fromARGB(
    255,
    214,
    222,
    231,
  ); // Light grey for cards/inputs
  static const Color errorColor = Color(0xFFDC3545);

  static var accentColor;
}

class AppTextStyles {
  static final TextStyle headline1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static final TextStyle headline2 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textColor,
  );

  static final TextStyle bodyText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor,
  );

  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle labelText = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.subtleTextColor,
  );
}

ThemeData getAppThemeData() {
  return ThemeData(
    primaryColor: const Color.fromARGB(255, 32, 159, 239),
    scaffoldBackgroundColor: AppColors.backgroundColor,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color.fromARGB(255, 2, 85, 13),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 32, 159, 239),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 32, 159, 232),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      labelStyle: AppTextStyles.labelText,
      hintStyle: AppTextStyles.labelText,
    ),

    //textfield border outline
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textColor),
      titleTextStyle: AppTextStyles.headline2.copyWith(fontSize: 20),
    ),
  );
}
