/// Root [MaterialApp] for Excelerate Next.
///
/// All named routes live here so navigation is declared in one place.
/// The initial route is [AppRoutes.splash], which then hands off to the
/// [AuthWrapper] gate (see [SplashScreen]).
import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/announcement_composer_screen.dart';
import 'screens/admin/create_program_screen.dart';
import 'screens/admin/feedback_dashboard_screen.dart';
import 'screens/admin/manage_programs_screen.dart';
import 'screens/admin/participants_tracker_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/learner/feedback_screen.dart';
import 'screens/learner/home_screen.dart';
import 'screens/learner/my_registrations_screen.dart';
import 'screens/learner/profile_screen.dart';
import 'screens/learner/programs/program_details_screen.dart';
import 'screens/learner/programs/program_listing_screen.dart';
import 'screens/learner/updates_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/wrapper.dart';
import 'utils/theme.dart';

class ExcelerateApp extends StatelessWidget {
  const ExcelerateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate Next',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(context),
      // Splash → AuthWrapper decides the next route based on auth state.
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        // Auth gate — used by splash to route to login / role-based home.
        AppRoutes.auth: (_) => const AuthWrapper(),
        // Auth screens
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.emailVerification: (_) => const EmailVerificationScreen(),
        // Learner screens
        AppRoutes.learnerHome: (_) => const HomeScreen(),
        AppRoutes.learnerPrograms: (_) => const ProgramListingScreen(),
        AppRoutes.learnerProgramDetails: (_) => const ProgramDetailsScreen(),
        AppRoutes.learnerMyRegistrations: (_) => const MyRegistrationsScreen(),
        AppRoutes.learnerFeedback: (_) => const FeedbackScreen(),
        AppRoutes.learnerUpdates: (_) => const UpdatesScreen(),
        AppRoutes.learnerProfile: (_) => const ProfileScreen(),
        // Admin screens
        AppRoutes.adminHome: (_) => const AdminHomeScreen(),
        AppRoutes.adminManagePrograms: (_) => const ManageProgramsScreen(),
        AppRoutes.adminCreateProgram: (_) => const CreateProgramScreen(),
        AppRoutes.adminComposer: (_) => const AnnouncementComposerScreen(),
        AppRoutes.adminParticipants: (_) => const ParticipantsTrackerScreen(),
        AppRoutes.adminFeedbackDashboard: (_) =>
            const FeedbackDashboardScreen(),
      },
    );
  }
}
