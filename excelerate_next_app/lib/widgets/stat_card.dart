/// A compact stat card used on dashboards (e.g. "3 Courses In Progress").
///
/// The [label] may contain embedded `\n` to produce a two-line label
/// (e.g. `"My\nRegistrations"`). This widget respects that and renders
/// up to 2 lines, wrapping only when the text is exceptionally long.
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor = AppColors.orangeAccent,
    this.valueColor = AppColors.deepBlue,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color iconColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius),
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
          if (icon != null) ...[
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(width: AppSizes.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Value: numbers like "3", "5", "4.3" — always 1 line
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
                const SizedBox(height: 2),
                // Label: supports embedded `\n` for two-line labels
                // (e.g. "My\nRegistrations" → My / Registrations)
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
