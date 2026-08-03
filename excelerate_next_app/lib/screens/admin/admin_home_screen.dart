/// Admin home dashboard — live stats, quick actions, and management links.
///
/// All data flows through [FirestoreService], not raw Firebase calls,
/// keeping the admin screen within the service layer architecture.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/program_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/stat_card.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirestoreService _firestore = FirestoreService();
  StreamSubscription<int>? _learnerSub;
  StreamSubscription<int>? _registrationSub;

  int _learnerCount = 0;
  int _registrationCount = 0;

  @override
  void initState() {
    super.initState();
    _learnerSub = _firestore.watchLearnerCount().listen((c) {
      if (mounted) setState(() => _learnerCount = c);
    });
    _registrationSub = _firestore.watchRegistrationCount().listen((c) {
      if (mounted) setState(() => _registrationCount = c);
    });
  }

  @override
  void dispose() {
    _learnerSub?.cancel();
    _registrationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final programs = context.watch<ProgramProvider>();

    final ratedPrograms = programs.programs
        .where((p) => p.reviewsCount > 0)
        .toList();
    final avgRating = ratedPrograms.isEmpty
        ? 0.0
        : ratedPrograms.map((p) => p.rating).reduce((a, b) => a + b) /
              ratedPrograms.length;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Welcome, ${auth.currentUser?.firstName ?? "Admin"} 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Role: Administrator',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: AppSizes.xxl),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: '${programs.programs.length}',
                    label: 'Total\nPrograms',
                    icon: Icons.menu_book,
                  ),
                ),
                const SizedBox(width: AppSizes.lg),
                Expanded(
                  child: StatCard(
                    value: '$_learnerCount',
                    label: 'Total\nLearners',
                    icon: Icons.people,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: '$_registrationCount',
                    label: 'Total\nRegistrations',
                    icon: Icons.event_available,
                  ),
                ),
                const SizedBox(width: AppSizes.lg),
                Expanded(
                  child: StatCard(
                    value: ratedPrograms.isEmpty
                        ? '—'
                        : avgRating.toStringAsFixed(1),
                    label: 'Average\nRating',
                    icon: Icons.star,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xxl),

            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlue,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            _buildActionTile(
              context,
              icon: Icons.add_circle_outline,
              title: 'Create Program',
              subtitle: 'Publish a new program or event',
              route: AppRoutes.adminCreateProgram,
            ),
            _buildActionTile(
              context,
              icon: Icons.edit_calendar,
              title: 'Manage Programs',
              subtitle: 'Edit, close or delete existing programs',
              route: AppRoutes.adminManagePrograms,
            ),
            _buildActionTile(
              context,
              icon: Icons.campaign,
              title: 'Compose Announcement',
              subtitle: 'Push updates to all learners',
              route: AppRoutes.adminComposer,
            ),
            _buildActionTile(
              context,
              icon: Icons.people_outline,
              title: 'Participants Tracker',
              subtitle: 'View registered learners per program',
              route: AppRoutes.adminParticipants,
            ),
            _buildActionTile(
              context,
              icon: Icons.analytics,
              title: 'Feedback Dashboard',
              subtitle: 'Aggregate ratings and review submissions',
              route: AppRoutes.adminFeedbackDashboard,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.buttonBlue.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.buttonBlue),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
