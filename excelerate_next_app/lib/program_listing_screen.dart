import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  List<dynamic> programs = [];
  bool isLoading = true;
  String errorMessage = '';

  // Week 3: Special test program that always shows in the list.
  // Tapping it triggers the error handling demo on the details screen.
  static const Map<String, dynamic> _errorTestProgram = {
    'id': 'error-test',
    'title': 'Error Test Program',
    'duration': 'N/A',
    'level': 'Test',
    'rating': 'N/A',
    'instructor': 'System',
    'skills': 'Error Handling',
    'description':
        "This program intentionally fails to demonstrate the app's error handling and retry flow.",
  };

  @override
  void initState() {
    super.initState();
    fetchProgramsFromApi();
  }

  // Dynamic Data Fetching without hardcoded lists or undefined index variables
  Future<void> fetchProgramsFromApi() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://flutter-project-164c5-default-rtdb.firebaseio.com/.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);

        final List<dynamic> loadedPrograms = fetchedData.map((item) {
          return {
            'id': item['id']?.toString() ?? '',
            'title': item['title'] ?? 'Untitled Program',
            'duration': item['duration'] ?? 'Self-Paced',
            'level': item['level'] ?? 'All Levels',
            'rating': item['rating'] ?? '4.5 (50 reviews)',
            'instructor': item['instructor'] ?? 'Industry Specialist',
            'skills': item['skills'] ?? 'General Skills',
            'description': item['description'] ?? 'No description available.',
          };
        }).toList();

        // Week 3: Append the error test program (avoid duplicates)
        final bool alreadyExists = loadedPrograms
            .any((p) => p['title'] == _errorTestProgram['title']);
        if (!alreadyExists) {
          loadedPrograms.add(Map<String, dynamic>.from(_errorTestProgram));
        }

        if (!mounted) return;
        setState(() {
          programs = loadedPrograms;
          isLoading = false;
        });
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      // Fallback: If network API call fails, load directly from local JSON asset
      _loadFromLocalAssets();
    }
  }

  Future<void> _loadFromLocalAssets() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/programs.json');
      final List<dynamic> localData = json.decode(jsonString);

      // Week 3: Ensure the error test program is present (avoid duplicates)
      final bool alreadyExists =
          localData.any((p) => p['title'] == _errorTestProgram['title']);
      if (!alreadyExists) {
        localData.add(Map<String, dynamic>.from(_errorTestProgram));
      }

      if (mounted) {
        setState(() {
          programs = localData;
          isLoading = false;
        });
      }
    } catch (assetError) {
      if (mounted) {
        setState(() {
          errorMessage =
              'Unable to load programs. Please check your connection and try again.';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 28,
          errorBuilder: (c, e, s) => const Text(
            'Excelerate Programs',
            style: TextStyle(color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF6D00)),
            SizedBox(height: 16),
            Text('Loading programs...'),
          ],
        ),
      )
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 12),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: fetchProgramsFromApi,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Fetch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6D00),
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/details',
                arguments: program,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              padding: const EdgeInsets.all(20.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 28,
                        color: Color(0xFFFF6D00),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          program['title']?.toString() ?? 'Untitled Program',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoIcon(
                        Icons.access_time_filled,
                        program['duration']?.toString() ?? 'N/A',
                      ),
                      _buildInfoIcon(
                        Icons.bar_chart,
                        program['level']?.toString() ?? 'N/A',
                      ),
                      _buildInfoIcon(
                        Icons.star,
                        '${program['rating'] ?? 'N/A'}'.split(' ')[0],
                      ),
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
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
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