import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/logo.png', height: 28),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      // FIXED: withOpacity to withValues
                      color: const Color(0xFF0056D2).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('TU', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Test User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                        SizedBox(height: 4),
                        Text('testuser@gmail.com', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Excelerate Intern', style: TextStyle(fontSize: 12, color: Color(0xFFFF6D00))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildProfileOption(Icons.workspace_premium, 'My Certificates', true),
                  _buildProfileOption(Icons.subscriptions, 'My Subscriptions', true),
                  _buildProfileOption(Icons.person_outline, 'Edit Personal Info', true),
                  _buildProfileOption(Icons.notifications_active_outlined, 'Notification Settings', true),
                  _buildProfileOption(Icons.help_outline, 'Help & Support', false),
                ],
              ),
            ),
            const SizedBox(height: 40),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 4),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, bool showDivider) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFF0056D2)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF003366))),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {},
        ),
        if (showDivider) const Divider(height: 1, indent: 56, endIndent: 16),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFFFF6D00),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        // FIXED: Added { }
        if (index == currentIndex) {
          return;
        }
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/programs');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/feedback');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/updates');
        } else if (index == 4) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Programs'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Feedback'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Updates'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}