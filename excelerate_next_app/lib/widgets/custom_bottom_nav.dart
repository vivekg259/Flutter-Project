/// A single shared bottom navigation bar used by every main screen.
///
/// This replaces the 5 identical `_buildBottomNav()` methods that were
/// copy-pasted across the old flat-file screens.
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../utils/constants.dart';

/// Which tab is currently active.
enum BottomNavTab {
  home(Icons.home_outlined, Icons.home, 'Home'),
  programs(Icons.menu_book_outlined, Icons.menu_book, 'Programs'),
  feedback(Icons.chat_bubble_outline, Icons.chat_bubble, 'Feedback'),
  updates(Icons.notifications_none, Icons.notifications, 'Updates'),
  profile(Icons.person_outline, Icons.person, 'Profile');

  const BottomNavTab(this.outlinedIcon, this.filledIcon, this.label);

  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
}

/// A shared bottom navigation bar widget.
///
/// Usage:
/// ```dart
/// CustomBottomNav(currentTab: BottomNavTab.home)
/// ```
/// The widget calls [onTabChanged] whenever a different tab is tapped.
/// The parent screen should use [pushReplacementNamed] to switch.
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentTab,
    this.onTabChanged,
  });

  /// Which tab is currently highlighted.
  final BottomNavTab currentTab;

  /// Callback when the user taps a different tab.
  final ValueChanged<BottomNavTab>? onTabChanged;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTab.index,
      selectedItemColor: AppColors.orangeAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != currentTab.index) {
          onTabChanged?.call(BottomNavTab.values[index]);
        }
      },
      items: BottomNavTab.values
          .map(
            (tab) => BottomNavigationBarItem(
              icon: Icon(tab.outlinedIcon),
              activeIcon: Icon(tab.filledIcon),
              label: tab.label,
            ),
          )
          .toList(),
    );
  }
}

/// Helper: handles navigation when a tab is tapped.
///
/// Use this in screens so they don't each repeat the same navigation logic.
void handleBottomNavTap(BuildContext context, BottomNavTab tab) {
  final routes = {
    BottomNavTab.home: AppRoutes.learnerHome,
    BottomNavTab.programs: AppRoutes.learnerPrograms,
    BottomNavTab.feedback: AppRoutes.learnerFeedback,
    BottomNavTab.updates: AppRoutes.learnerUpdates,
    BottomNavTab.profile: AppRoutes.learnerProfile,
  };
  Navigator.pushReplacementNamed(context, routes[tab]!);
}
