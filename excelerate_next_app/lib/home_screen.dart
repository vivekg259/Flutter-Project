import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/logo.png', height: 28),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    // FIXED: Replaced Vivek with User
                    'Hello User 👋',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                  ),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0056D2).withValues(alpha: 0.1),
                    // FIXED: Replaced VG with TU (Test User)
                    child: const Text('TU', style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: _buildStatCard('3', 'Courses\nIn Progress')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('1', 'Certificate\nEarned')),
                ],
              ),
              const SizedBox(height: 30),

              const Text('Announcements & Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
              const SizedBox(height: 16),
              // FIXED: Removed the boolean parameter for bell icon
              _buildSessionCard('19 Jul', 'Week 2 UI Evaluation', 'Submit your GitHub links before 11:59 PM'),
              const SizedBox(height: 16),
              _buildSessionCard('21 Jul', 'Week 3 API Bootcamp', 'Live session on REST APIs & Postman'),
              const SizedBox(height: 30),

              const Text('Quick Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickLinkIcon(Icons.ondemand_video, 'Webinars'),
                  _buildQuickLinkIcon(Icons.forum_outlined, 'Community'),
                  _buildQuickLinkIcon(Icons.help_outline, 'Support'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildStatCard(String number, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF6D00))),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }

  // FIXED: Removed boolean isUpcoming and bell icon logic completely
  Widget _buildSessionCard(String date, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0056D2).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF0056D2)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: Icon(icon, color: const Color(0xFF0056D2), size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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