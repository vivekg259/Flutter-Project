import 'package:flutter/material.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> updatesData = [
      {
        'title': 'Live Session Reminder',
        'desc': 'Week 3 API Prep session starts in 30 minutes. Join via the Zoom link in your dashboard.',
        'icon': Icons.videocam,
        'color': Colors.redAccent,
        'time': 'Just now'
      },
      {
        'title': 'Assignment Graded',
        'desc': 'Your Week 1 Figma Wireframes have been evaluated. You scored 95/100! Tap to view feedback.',
        'icon': Icons.task_alt,
        'color': const Color(0xFF0056D2),
        'time': '2 hours ago'
      },
      {
        'title': 'New Course Material',
        'desc': 'Dr. Angela Yu has uploaded new study materials for the Flutter Architecture module.',
        'icon': Icons.library_books,
        'color': const Color(0xFFFF6D00),
        'time': '1 day ago'
      },
      {
        'title': 'Upcoming Deadline',
        'desc': 'Submit your Week 2 Frontend code repository by tomorrow 11:59 PM.',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.amber[700],
        'time': '2 days ago'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/logo.png', height: 28),
        centerTitle: true,
      ),
      // FIXED: Used a single ListView for everything so Header and Cards scroll together seamlessly
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
          const SizedBox(height: 20),
          
          ...updatesData.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
                    child: Icon(item['icon'], color: item['color']),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item['title'], 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003366)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['time'], 
                              style: const TextStyle(fontSize: 11, color: Colors.grey)
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(item['desc'], style: TextStyle(color: Colors.grey[700], height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, 3),
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