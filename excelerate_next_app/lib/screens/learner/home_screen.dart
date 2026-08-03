/// Learner Home dashboard — combines a personalized greeting, live stats,
/// real-time announcements, upcoming programs, and quick links.
///
/// On first mount, calls [RegistrationProvider.bind] so the Firestore
/// registration stream starts listening for this user's registrations.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/program_provider.dart';
import '../../providers/registration_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/program_card.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didBind = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didBind) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _didBind = true;
      context.read<RegistrationProvider>().bind(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final announcements = context.watch<AnnouncementProvider>();
    final programs = context.watch<ProgramProvider>();
    final registrations = context.watch<RegistrationProvider>();
    final user = auth.currentUser;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && context.mounted) {
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Image.asset('assets/logo.png', height: AppSizes.logoAppBar),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Hello, ${user?.firstName ?? 'Learner'} 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.buttonBlue.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        user?.initials ?? '?',
                        style: const TextStyle(
                          color: AppColors.buttonBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xl),

                // Stat cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '${registrations.visible.length}',
                        label: 'My\nApplications',
                        icon: Icons.event_available,
                      ),
                    ),
                    const SizedBox(width: AppSizes.lg),
                    Expanded(
                      child: StatCard(
                        value: '${programs.publishedPrograms.length}',
                        label: 'Programs\nAvailable',
                        icon: Icons.menu_book,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),

                // Announcements section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Announcements',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                      ),
                    ),
                    if (announcements.announcements.isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.learnerUpdates,
                        ),
                        child: const Text('See all'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                if (announcements.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: AppColors.orangeAccent,
                      ),
                    ),
                  )
                else if (announcements.announcements.isEmpty)
                  const EmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'No announcements yet',
                    subtitle:
                        'New updates from your program admins will appear here.',
                  )
                else
                  // Show the 3 latest announcements
                  ...announcements.announcements
                      .take(3)
                      .map((a) => AnnouncementCard(announcement: a)),

                const SizedBox(height: AppSizes.xxl),

                // Upcoming programs section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Upcoming Programs',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.learnerPrograms,
                      ),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                if (programs.publishedPrograms.isEmpty)
                  const EmptyState(
                    icon: Icons.school_outlined,
                    title: 'No programs yet',
                    subtitle:
                        'Check back soon for new programs to register for.',
                  )
                else
                  // Show the 2 most recent published programs
                  ...programs.publishedPrograms
                      .take(2)
                      .map(
                        (p) => ProgramCard(
                          program: p,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.learnerProgramDetails,
                            arguments: p,
                          ),
                        ),
                      ),

                const SizedBox(height: AppSizes.xxl),

                // Quick Links
                const Text(
                  'Quick Links',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _QuickLink(
                        icon: Icons.event,
                        label: 'My Events',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.learnerMyRegistrations,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _QuickLink(
                        icon: Icons.rate_review,
                        label: 'Feedback',
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.learnerFeedback,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _QuickLink(
                        icon: Icons.help_outline,
                        label: 'Support',
                        onTap: () =>
                            showAppSnackBar(context, 'Support coming soon!'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentTab: BottomNavTab.home,
          onTabChanged: (tab) => handleBottomNavTap(context, tab),
        ),
      ), // Scaffold
    ); // PopScope
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, color: AppColors.buttonBlue, size: 28),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
