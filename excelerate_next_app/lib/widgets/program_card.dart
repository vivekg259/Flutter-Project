/// A reusable card that displays a [Program] summary.
///
/// Used on the Program Listing screen and potentially on the Home dashboard
/// for upcoming programs.
import 'package:flutter/material.dart';

import '../models/program.dart';
import '../utils/constants.dart';

class ProgramCard extends StatelessWidget {
  const ProgramCard({super.key, required this.program, this.onTap});

  final Program program;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.xl),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                const Icon(
                  Icons.school,
                  size: 28,
                  color: AppColors.orangeAccent,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    program.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Divider
            Container(
              height: 2,
              width: double.infinity,
              color: Colors.grey[200],
            ),
            const SizedBox(height: AppSizes.lg),

            // Info row: duration, level, rating — each wrapped so nothing overflows
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.access_time_filled,
                    text: program.duration,
                  ),
                ),
                Expanded(
                  child: _InfoChip(icon: Icons.bar_chart, text: program.level),
                ),
                Expanded(
                  child: _InfoChip(icon: Icons.star, text: program.ratingShort),
                ),
              ],
            ),

            // Status badge
            if (program.status != ProgramStatus.open) ...[
              const SizedBox(height: AppSizes.md),
              _StatusBadge(status: program.status),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.buttonBlue),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ProgramStatus.upcoming => Colors.blue.shade100,
      ProgramStatus.closed => Colors.red.shade100,
      _ => Colors.green.shade100,
    };
    final textColor = switch (status) {
      ProgramStatus.upcoming => Colors.blue.shade800,
      ProgramStatus.closed => Colors.red.shade800,
      _ => Colors.green.shade800,
    };
    final label = switch (status) {
      ProgramStatus.upcoming => 'Upcoming',
      ProgramStatus.closed => 'Closed',
      _ => 'Open',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
