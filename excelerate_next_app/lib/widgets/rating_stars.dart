/// Interactive star-rating widget used on the Feedback screen.
///
/// Supports tap-to-set and read-only display modes.
import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// A row of 5 tappable / display-only stars.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 32,
    this.enabled = true,
  });

  /// Current rating (0–5, supports half-stars in display mode).
  final int rating;

  /// Called with the new value when a star is tapped.
  final ValueChanged<int>? onChanged;

  /// Icon size in logical pixels.
  final double size;

  /// False = display-only (no tap interaction).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;
        return GestureDetector(
          onTap: (enabled && onChanged != null)
              ? () => onChanged!(starIndex)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFilled ? AppColors.orangeAccent : Colors.grey.shade400,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
