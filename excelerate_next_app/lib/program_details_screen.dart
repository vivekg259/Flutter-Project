import 'package:flutter/material.dart';

class ProgramDetailsScreen extends StatefulWidget {
  const ProgramDetailsScreen({super.key});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic> _programData = {};

  // Enroll Button States
  bool _isEnrolling = false;
  bool _isEnrolled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Perform initial API fetch only once when dependencies are resolved
    if (_isLoading && _programData.isEmpty && !_hasError) {
      _fetchProgramDetails();
    }
  }

  Future<void> _fetchProgramDetails() async {
    // Reset state before fetching (needed for Retry)
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    // 1. Extract dynamic arguments passed from the previous screen/route
    final rawData = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> passedData = rawData != null && rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : {};

    try {
      // 2. Simulate API Network Call delay (Replace this with http.get call in production)
      await Future.delayed(const Duration(seconds: 2));
      // Week 3: 'Error Test Program' intentionally fails
      // to demonstrate the error handling UI and Retry button
      if (passedData['title'] == 'Error Test Program') {
        throw Exception('Simulated API failure for error handling demo');
      }

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

      if (!mounted) return;
      setState(() {
        _programData = apiResult;
        _isLoading = false;
        _hasError = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Failed to load program details.\nPlease check your internet connection and try again.';
      });
    }
  }

  // Handle Enroll Button Click
  Future<void> _handleEnrollment() async {
    if (_isEnrolled || _isEnrolling) return;

    setState(() {
      _isEnrolling = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isEnrolling = false;
      _isEnrolled = true;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully enrolled in the program!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 28),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  /// Decides which state to show: Loading, Error, or Success (content)
  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_hasError) {
      return _buildErrorState();
    }
    return _buildContent();
  }

  // ---------------- LOADING STATE ----------------
  Widget _buildLoadingState() {
    return const Center(
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
    );
  }

  // ---------------- ERROR STATE (with Retry button) ----------------
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchProgramDetails,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Retry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SUCCESS STATE (main content) ----------------
  Widget _buildContent() {
    return Column(
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
                  children: (_programData['skills']?.toString() ??
                          'General Skills')
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
                      backgroundColor:
                          const Color(0xFF0056D2).withValues(alpha: 0.1),
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
                _buildCurriculumTile('Module 1', 'Introduction & Setup',
                    '2 Videos • 1 Reading'),
                _buildCurriculumTile('Module 2', 'Core Fundamentals',
                    '4 Videos • 2 Quizzes'),
                _buildCurriculumTile('Module 3', 'Advanced Deep Dive',
                    '5 Videos • 1 Project'),
                _buildCurriculumTile(
                    'Module 4', 'Final Assessment', '1 Final Exam'),
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
                backgroundColor: _isEnrolled ? Colors.grey : const Color(0xFF0056D2),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Disables the button if loading or already enrolled
              onPressed: (_isEnrolling || _isEnrolled) ? null : _handleEnrollment,
              child: _isEnrolling
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _isEnrolled ? 'Enrolled' : 'Enroll for Free',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
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