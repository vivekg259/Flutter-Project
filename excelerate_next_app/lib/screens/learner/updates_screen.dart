/// Updates / Notifications screen — live announcements from admins.
///
/// Replaces the old hardcoded list with a real-time Firestore stream.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/announcement.dart';
import '../../providers/announcement_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = context.watch<AnnouncementProvider>();

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
        body: announcements.isLoading
            ? const LoadingOverlay(message: 'Loading updates...')
            : announcements.announcements.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications yet',
                subtitle:
                    'Announcements from your program admins will appear here.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.xl),
                itemCount: announcements.announcements.length,
                itemBuilder: (context, index) {
                  return _NotificationCard(
                    announcement: announcements.announcements[index],
                  );
                },
              ),
        bottomNavigationBar: CustomBottomNav(
          currentTab: BottomNavTab.updates,
          onTabChanged: (tab) => handleBottomNavTap(context, tab),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(announcement.type);
    final color = _colorForType(announcement.type);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.xl),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.deepBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  announcement.body,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      AnnouncementType.reminder => Icons.schedule,
      AnnouncementType.deadline => Icons.warning_amber_rounded,
      AnnouncementType.event => Icons.event,
      _ => Icons.info_outline,
    };
  }

  Color _colorForType(String type) {
    return switch (type) {
      AnnouncementType.reminder => Colors.blue,
      AnnouncementType.deadline => Colors.red,
      AnnouncementType.event => AppColors.orangeAccent,
      _ => AppColors.buttonBlue,
    };
  }
}
