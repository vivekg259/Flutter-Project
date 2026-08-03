/// App-wide [ThemeData] extracted from the original main.dart.
///
/// Centralizing the theme lets screens rely on `Theme.of(context)` instead
/// of repeating literal colors, and keeps the visual identity consistent.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

/// Builds the global Material 3 theme for Excelerate Next.
ThemeData buildAppTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    // Branding: Poppins font globally applied
    textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.deepBlue,
      primary: AppColors.buttonBlue,
      secondary: AppColors.orangeAccent,
    ),
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.deepBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.scaffoldBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
