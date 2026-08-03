/// App entry point.
///
/// Initializes Firebase (only if real config is present), wires up all
/// [ChangeNotifier] providers, and runs the [ExcelerateApp].
///
/// While Firebase is not yet configured ([DefaultFirebaseOptions.isConfigured]
/// is false), the app still boots — screens will show friendly errors when
/// they try to reach Firestore, but the UI shell is fully usable.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/announcement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/program_provider.dart';
import 'providers/registration_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only when real config is available.
  // The placeholder config (isConfigured == false) lets the app compile
  // and run the UI without a backend — see FIREBASE_SETUP.md.
  if (DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ProgramProvider>(
          create: (_) => ProgramProvider(),
        ),
        ChangeNotifierProvider<AnnouncementProvider>(
          create: (_) => AnnouncementProvider(),
        ),
        ChangeNotifierProvider<RegistrationProvider>(
          create: (_) => RegistrationProvider(),
        ),
      ],
      child: const ExcelerateApp(),
    ),
  );
}
