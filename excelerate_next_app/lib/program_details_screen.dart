import 'package:flutter/material.dart';

class ProgramDetailsScreen extends StatelessWidget {
  const ProgramDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final programData = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 28),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    programData['title']!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(programData['rating']!, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(width: 12),
                      const Icon(Icons.verified, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      const Text('Excelerate Certified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailIcon(Icons.access_time_filled, programData['duration']!, 'Duration'),
                        _buildDetailIcon(Icons.bar_chart, programData['level']!, 'Level'),
                        _buildDetailIcon(Icons.menu_book, '100%', 'Online'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text('Instructor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFF0056D2),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(programData['instructor']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Text('Senior Industry Expert', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('Skills you will gain', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: programData['skills']!.split(', ').map((skill) {
                      return Chip(
                        label: Text(skill, style: const TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.w500)),
                        // FIXED: withOpacity to withValues
                        backgroundColor: const Color(0xFF0056D2).withValues(alpha: 0.1),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  const Text('About the course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                  const SizedBox(height: 12),
                  Text(
                    programData['description']!,
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  const Text('Requirements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                  const SizedBox(height: 12),
                  const Text(
                    '• A laptop or desktop with a stable internet connection.\n• No prior deep technical knowledge is required.\n• A willingness to learn and complete hands-on projects.',
                    style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  const Text('Course Curriculum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                  const SizedBox(height: 12),
                  _buildCurriculumTile('Module 1', 'Introduction & Setup', '2 Videos • 1 Reading'),
                  _buildCurriculumTile('Module 2', 'Core Fundamentals', '4 Videos • 2 Quizzes'),
                  _buildCurriculumTile('Module 3', 'Advanced Deep Dive', '5 Videos • 1 Project'),
                  _buildCurriculumTile('Module 4', 'Final Assessment', '1 Final Exam'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully Enrolled in the course!')));
                },
                child: const Text('Enroll for Free', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailIcon(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: const Color(0xFFFF6D00)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCurriculumTile(String module, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            // FIXED: withOpacity to withValues
            decoration: BoxDecoration(color: const Color(0xFF0056D2).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.play_lesson, color: Color(0xFF0056D2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$module: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}