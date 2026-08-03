/// Profile screen — shows real user data, supports edit (basic) + sign out.
///
/// Sign out goes through [AuthProvider] which clears auth state, and the
/// auth wrapper redirects back to login.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            children: [
              // Profile card
              Container(
                padding: const EdgeInsets.all(AppSizes.xxl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.buttonBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.buttonBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.xl),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Learner',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppColors.orangeAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (user?.isAdmin ?? false) ? 'Admin' : 'Learner',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.orangeAccent,
                                ),
                              ),
                              if (user?.nationality.isNotEmpty ?? false) ...[
                                const SizedBox(width: AppSizes.md),
                                Icon(
                                  Icons.public,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    user!.nationality,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xxl),

              // Options
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileOption(
                      icon: Icons.event_available,
                      title: 'My Registrations',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.learnerMyRegistrations,
                      ),
                    ),
                    _ProfileOption(
                      icon: Icons.workspace_premium,
                      title: 'My Certificates',
                      onTap: () =>
                          showAppSnackBar(context, 'Certificates coming soon!'),
                    ),
                    _ProfileOption(
                      icon: Icons.refresh,
                      title: 'Refresh Profile',
                      subtitle: 'Use after admin grants a role',
                      onTap: () async {
                        await auth.refreshUser();
                        if (context.mounted) {
                          showAppSnackBar(context, 'Profile refreshed.');
                        }
                      },
                    ),
                    _ProfileOption(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notification Settings',
                      showDivider: false,
                      onTap: () =>
                          showAppSnackBar(context, 'Settings coming soon!'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xxl),

              // Sign Out
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text(
                        'Are you sure you want to sign out of your account?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    AppSizes.buttonHeight,
                  ),
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentTab: BottomNavTab.profile,
          onTabChanged: (tab) => handleBottomNavTap(context, tab),
        ),
      ), // Scaffold
    ); // PopScope
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    this.showDivider = true,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.buttonBlue),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.deepBlue,
            ),
          ),
          subtitle: subtitle != null
              ? Text(subtitle!, style: const TextStyle(fontSize: 12))
              : null,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(height: 1, indent: 56, endIndent: AppSizes.lg),
      ],
    );
  }
}
