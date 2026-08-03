/// Splash screen — shows the brand logo for 3 seconds, then hands off
/// to the auth wrapper (which itself decides login vs. home).
import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppDurations.splash, () {
      // The wrapper figures out the right destination based on auth state.
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.auth);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Logo Placement 1: Splash Screen
        child: Image.asset('assets/logo.png', width: AppSizes.logoSplash),
      ),
    );
  }
}
