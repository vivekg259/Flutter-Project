import 'package:flutter/material.dart';

class ProgramDetailsScreen extends StatefulWidget {
  const ProgramDetailsScreen({super.key});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _programData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Perform initial API fetch only once when dependencies are resolved
    if (_isLoading && _programData.isEmpty) {
      _fetchProgramDetails();
    }
  }

  Future<void> _fetchProgramDetails() async {
    // 1. Extract dynamic arguments passed from the previous screen/route
    final rawData = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> passedData = rawData != null && rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : {};

    //final String programId = passedData['id']?.toString() ?? '1';

    try {
      // 2. Simulate API Network Call delay (Replace this with http.get call in production)
      // Example production usage:
      // final response = await http.get(Uri.parse('https://api.example.com/programs/$programId'));
      // final Map<String, dynamic> apiResult = json.decode(response.body);

      await Future.delayed(const Duration(seconds: 2));

      // Mock response payload from backend/API
      final Map<String, dynamic> apiResult = {
        'title': passedData['title'] ?? 'Flutter Mobile Development Masterclass',
        'rating': passedData['rating'] ?? '4.8 (120 reviews)',
        'duration': passedData['duration'] ?? '6 Weeks',
        'level': passedData['level'] ?? 'Intermediate',
        'instructor': passedData['instructor'] ?? 'Dr. Alex Rivera',
        'skills': passedData['skills'] ?? 'Flutter, Dart, Mobile UI, State Management',
        'description': passedData['description'] ??
            'Master cross-platform mobile development using Flutter and Dart from scratch. Build production-ready iOS and Android applications with state management and API integration.',
      };

      if (mounted) {
        setState(() {
          _programData = apiResult;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _programData = {
            'title': 'Error Loading Program',
            'rating': 'N/A',
            'duration': 'N/A',
            'level': 'N/A',
            'instructor': 'N/A',
            'skills': 'None',
            'description': 'Failed to fetch details from server. Please try again.',
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 28),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFFF6D00),
            ),
            SizedBox(height: 16),
            Text(
              'Fetching Program Details...',
              style: TextStyle(
                color: Color(0xFF003366),
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic Title
                  Text(
                    _programData['title']?.toString() ?? 'Program Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating Row
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _programData['rating']?.toString() ?? '4.8',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.verified, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        'Excelerate Certified',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Key Details Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailIcon(
                          Icons.access_time_filled,
                          _programData['duration']?.toString() ?? 'N/A',
                          'Duration',
                        ),
                        _buildDetailIcon(
                          Icons.bar_chart,
                          _programData['level']?.toString() ?? 'N/A',
                          'Level',
                        ),
                        _buildDetailIcon(
                          Icons.menu_book,
                          '100%',
                          'Online',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Dynamic Instructor
                  const Text(
                    'Instructor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
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
                          Text(
                            _programData['instructor']?.toString() ??
                                'Industry Specialist',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Senior Industry Expert',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dynamic Skills Chips
                  const Text(
                    'Skills you will gain',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: (_programData['skills']?.toString() ?? 'General Skills')
                        .split(',')
                        .map((skill) {
                      return Chip(
                        label: Text(
                          skill.trim(),
                          style: const TextStyle(
                            color: Color(0xFF0056D2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFF0056D2)
                            .withValues(alpha: 0.1),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic Description
                  const Text(
                    'About the course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _programData['description']?.toString() ??
                        'No description available.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Requirements
                  const Text(
                    'Requirements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• A laptop or desktop with a stable internet connection.\n'
                        '• No prior deep technical knowledge is required.\n'
                        '• A willingness to learn and complete hands-on projects.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Curriculum Section
                  const Text(
                    'Course Curriculum',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003366),
                    ),
                  ),
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

          // Bottom Action Button (Enroll Button)
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully Enrolled in ${_programData['title']}!',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Enroll for Free',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
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
            decoration: BoxDecoration(
              color: const Color(0xFF0056D2).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_lesson, color: Color(0xFF0056D2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$module: $title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}