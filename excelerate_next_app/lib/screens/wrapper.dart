/// Auth gate — watches AuthProvider.status:
///   initializing → spinner
///   authenticated → learner or admin home
///   unauthenticated → login screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String target;
    if (auth.status == AuthStatus.authenticated) {
      target = auth.isAdmin ? AppRoutes.adminHome : AppRoutes.learnerHome;
    } else {
      target = AppRoutes.login;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(target, (route) => false);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
