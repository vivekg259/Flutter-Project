/// A card for displaying a single [Announcement].
///
/// Used on both the Home dashboard and the Updates screen.
import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.announcement, this.onTap});

  final Announcement announcement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconData = _iconForType(announcement.type);
    final iconColor = _colorForType(announcement.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.body,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(announcement.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
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
