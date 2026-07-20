import 'package:flutter/material.dart';

class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  final List<Map<String, String>> programs = [
    {
      'title': 'Advanced Flutter & Dart Mastery',
      'duration': '8 Weeks',
      'level': 'Intermediate',
      'rating': '4.8 (2.1k reviews)',
      'instructor': 'Dr. Angela Yu',
      'skills': 'State Management, API Integration, Firebase',
      'description': 'Take your Flutter skills to the next level. Learn advanced State Management (Provider, Riverpod), REST API integration, and build production-ready iOS and Android apps from a single codebase.'
    },
    {
      'title': 'Applied Data Science with Python',
      'duration': '10 Weeks',
      'level': 'Advanced',
      'rating': '4.7 (5.4k reviews)',
      'instructor': 'Andrew Ng',
      'skills': 'Machine Learning, Pandas, NumPy, Data Viz',
      'description': 'Master data analysis and machine learning using Python. You will learn to clean data, create visualizations, and build predictive models using real-world datasets.'
    },
    {
      'title': 'MERN Full-Stack Bootcamp',
      'duration': '12 Weeks',
      'level': 'Beginner',
      'rating': '4.9 (8.2k reviews)',
      'instructor': 'Colt Steele',
      'skills': 'MongoDB, Express, React, Node.js',
      'description': 'Become a full-stack web developer. Learn to build interactive React frontends and powerful Node.js backends with MongoDB databases. Includes 5 real-world portfolio projects.'
    },
    {
      'title': 'UI/UX Product Design Pro',
      'duration': '6 Weeks',
      'level': 'Beginner',
      'rating': '4.8 (3.5k reviews)',
      'instructor': 'Gary Simon',
      'skills': 'Figma, Wireframing, User Research',
      'description': 'Learn the complete design process from ideation to high-fidelity prototyping. Master Figma and learn how to create intuitive, accessible, and beautiful user interfaces.'
    },
    {
      'title': 'Cloud Computing AWS Practitioner',
      'duration': '4 Weeks',
      'level': 'Beginner',
      'rating': '4.6 (1.2k reviews)',
      'instructor': 'Stephane Maarek',
      'skills': 'EC2, S3, IAM, Cloud Security',
      'description': 'Pass the AWS Certified Cloud Practitioner exam. Understand global cloud infrastructure, core AWS services, security architecture, and pricing models.'
    },
    {
      'title': 'Digital Marketing & SEO Strategy',
      'duration': '5 Weeks',
      'level': 'Intermediate',
      'rating': '4.5 (4.8k reviews)',
      'instructor': 'Isaac Rudansky',
      'skills': 'Google Ads, SEO, Analytics, Social Media',
      'description': 'Grow any business online from scratch. Master search engine optimization, run profitable Google Ads campaigns, and understand audience analytics to maximize ROI.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset('assets/logo.png', height: 28),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/details', arguments: program);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, size: 28, color: Color(0xFFFF6D00)), 
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          program['title']!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 2, width: double.infinity, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoIcon(Icons.access_time_filled, program['duration']!),
                      _buildInfoIcon(Icons.bar_chart, program['level']!),
                      _buildInfoIcon(Icons.star, program['rating']!.split(' ')[0]), 
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context, 1),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0056D2)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
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