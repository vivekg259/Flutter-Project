/// Centralized route name constants.
///
/// Avoids magic strings scattered across `Navigator.pushNamed` calls.
/// Keeping them here lets refactors happen in one place.
class AppRoutes {
  AppRoutes._();

  // Auth flow
  static const String splash = '/splash';
  static const String auth = '/auth'; // AuthWrapper gate
  static const String login = '/login';
  static const String signup = '/signup';
  static const String emailVerification = '/verify-email';

  // Learner main tabs
  static const String learnerHome = '/learner/home';
  static const String learnerPrograms = '/learner/programs';
  static const String learnerProgramDetails = '/learner/program-details';
  static const String learnerMyRegistrations = '/learner/my-registrations';
  static const String learnerFeedback = '/learner/feedback';
  static const String learnerUpdates = '/learner/updates';
  static const String learnerProfile = '/learner/profile';

  // Admin screens
  static const String adminHome = '/admin/home';
  static const String adminManagePrograms = '/admin/manage-programs';
  static const String adminCreateProgram = '/admin/create-program';
  static const String adminComposer = '/admin/announcement-composer';
  static const String adminParticipants = '/admin/participants';
  static const String adminFeedbackDashboard = '/admin/feedback-dashboard';

  /// All routes registered in `app.dart`.
  /// Kept here so [buildAppRoutes] stays the single source of truth.
  static Map<String, dynamic> get all => const {
    splash: 'SplashScreen',
    auth: 'AuthWrapper',
    login: 'LoginScreen',
    signup: 'SignupScreen',
    learnerHome: 'HomeScreen',
    learnerPrograms: 'ProgramListingScreen',
    learnerProgramDetails: 'ProgramDetailsScreen',
    learnerMyRegistrations: 'MyRegistrationsScreen',
    learnerFeedback: 'FeedbackScreen',
    learnerUpdates: 'UpdatesScreen',
    learnerProfile: 'ProfileScreen',
    adminHome: 'AdminHomeScreen',
    adminManagePrograms: 'ManageProgramsScreen',
    adminCreateProgram: 'CreateProgramScreen',
    adminComposer: 'AnnouncementComposerScreen',
    adminParticipants: 'ParticipantsTrackerScreen',
    adminFeedbackDashboard: 'FeedbackDashboardScreen',
  };
}
