import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? selectedProgram;
  String pace = 'Just Right';
  
  int contentRating = 0;
  int instructorRating = 0;
  int overallRating = 0;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Course Feedback', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
            const SizedBox(height: 8),
            const Text('Help us improve your learning experience', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            _buildLabel('Select Course'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _cardDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Which course are you reviewing?'),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0056D2)),
                  value: selectedProgram,
                  items: [
                    'Advanced Flutter & Dart Mastery', 
                    'Applied Data Science with Python', 
                    'MERN Full-Stack Bootcamp',
                    'UI/UX Product Design Pro',
                    'Cloud Computing AWS Practitioner',
                    'Digital Marketing & SEO Strategy'
                  ].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (newValue) => setState(() => selectedProgram = newValue),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInteractiveStarRow('Content Rating', contentRating, (rating) {
              setState(() => contentRating = rating);
            }),
            _buildInteractiveStarRow('Instructor Rating', instructorRating, (rating) {
              setState(() => instructorRating = rating);
            }),
            _buildInteractiveStarRow('Overall Rating', overallRating, (rating) {
              setState(() => overallRating = rating);
            }),

            _buildLabel('How was the course pace?'),
            Row(
              children: ['Too Slow', 'Just Right', 'Too Fast'].map((option) {
                bool isSelected = pace == option;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => pace = option),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0056D2) : Colors.white,
                        border: Border.all(color: isSelected ? const Color(0xFF0056D2) : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option, 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            _buildLabel('Detailed Review (Optional)'),
            Container(
              decoration: _cardDecoration(),
              child: const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What did you like? What can be improved?',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback Submitted! Thank you.')));
              },
              child: const Text('Submit Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF003366))),
    );
  }

  Widget _buildInteractiveStarRow(String title, int currentRating, Function(int) onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: _cardDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Icon(
                  index < currentRating ? Icons.star : Icons.star_border,
                  size: 36,
                  color: const Color(0xFFFF6D00),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
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