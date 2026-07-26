import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'program_listing_screen.dart';
import 'program_details_screen.dart';
import 'feedback_screen.dart';
import 'updates_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const ExcelerateNextApp());
}

class ExcelerateNextApp extends StatelessWidget {
  const ExcelerateNextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate Next',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Branding: Poppins Font globally applied
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366), // Deep Blue
          primary: const Color(0xFF0056D2), // Blue for buttons
          secondary: const Color(0xFFFF6D00), // Orange for Accent/Highlights
        ),
        scaffoldBackgroundColor: const Color(
          0xFFF5F7FA,
        ), // Light Gray/White Background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366), // Deep Blue App Bar
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0056D2),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 12px Border Radius
            ),
          ),
        ),
      ),
      // App now starts from Splash Screen
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/programs': (context) => const ProgramListingScreen(),
        '/details': (context) => const ProgramDetailsScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/updates': (context) => const UpdatesScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
