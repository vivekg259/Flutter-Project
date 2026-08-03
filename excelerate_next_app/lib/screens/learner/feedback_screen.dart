/// Feedback screen — only enrolled learners can submit feedback.
///
/// Program dropdown shows only programs the learner is APPROVED for.
/// If the learner hasn't enrolled in any program, a helpful empty state
/// is shown. On submit, an enrollment check provides a clear error.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/feedback.dart' as fb;
import '../../models/program.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/empty_state.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _reviewController = TextEditingController();

  Program? _selectedProgram;
  String _pace = fb.FeedbackPace.justRight;
  int _contentRating = 0;
  int _instructorRating = 0;
  bool _isSubmitting = false;

  /// Guards the async "has reviewed?" check so a slow response for program A
  /// cannot overwrite the state after the learner switched to program B.
  String? _reviewCheckProgramId;

  /// Tracks whether the learner has already reviewed the currently-selected
  /// program.  Checked proactively when the dropdown changes so the UI can
  /// disable the form before the learner fills it out.
  bool _hasAlreadyReviewed = false;
  bool _isCheckingReview = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedProgram == null) {
      showAppSnackBar(context, 'Please select a course.', isError: true);
      return;
    }
    if (_contentRating == 0 || _instructorRating == 0) {
      showAppSnackBar(
        context,
        'Please provide both content and instructor ratings.',
        isError: true,
      );
      return;
    }

    if (_reviewController.text.trim().length < 20) {
      showAppSnackBar(
        context,
        'Please write at least 20 characters in your review.',
        isError: true,
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    // ---- Enrollment check ----
    final registrations = context.read<RegistrationProvider>();
    if (!registrations.isEnrolledFor(_selectedProgram!.id)) {
      showAppSnackBar(
        context,
        'You are not enrolled in this program. Only enrolled learners can submit feedback.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final fbFeedback = fb.Feedback(
        id: '',
        programId: _selectedProgram!.id,
        userId: user.uid,
        contentRating: _contentRating,
        instructorRating: _instructorRating,
        pace: _pace,
        review: _reviewController.text.trim(),
        userName: user.fullName,
        userEmail: user.email,
        programTitle: _selectedProgram!.title,
        createdAt: DateTime.now(),
      );
      await FirestoreService().submitFeedback(fbFeedback);

      if (mounted) {
        showAppSnackBar(context, 'Feedback submitted successfully! Thank you.');
        setState(() {
          _selectedProgram = null;
          _pace = fb.FeedbackPace.justRight;
          _contentRating = 0;
          _instructorRating = 0;
          _reviewController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, friendlyError(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrations = context.watch<RegistrationProvider>();

    // Build enrolled programs list from the registration provider data
    final enrolledPrograms = <Program>[];
    for (final r in registrations.enrolled) {
      // We build minimal Program objects from registration denormalized fields
      // so the dropdown shows enrolled programs even if ProgramProvider has no data
      enrolledPrograms.add(
        Program(
          id: r.programId,
          title: r.programTitle ?? 'Program',
          description: '',
          instructor: r.programInstructor ?? '',
          duration: '',
          level: '',
          skills: const [],
          createdAt: r.registeredAt,
        ),
      );
    }

    // Reset selected program if it's no longer in the enrolled list
    if (_selectedProgram != null &&
        !enrolledPrograms.any((p) => p.id == _selectedProgram!.id)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedProgram = null;
            _hasAlreadyReviewed = false;
            _reviewCheckProgramId = null;
          });
        }
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // Dismiss keyboard on back press; only pop if keyboard already closed
        if (!didPop) {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
          } else {
            // Let the bottom nav handle navigation — nothing to pop here
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Image.asset('assets/logo.png', height: AppSizes.logoAppBar),
          centerTitle: true,
        ),
        body: enrolledPrograms.isEmpty
            ? const EmptyState(
                icon: Icons.rate_review_outlined,
                title: 'No enrolled programs',
                subtitle:
                    'You can only provide feedback for programs you are enrolled in. Enroll in a program first!',
              )
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.xl,
                  AppSizes.xl,
                  AppSizes.xl,
                  AppSizes.xl +
                      100, // extra bottom padding so submit button clears keyboard
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Feedback',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    const Text(
                      'Help us improve your learning experience',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: AppSizes.xxl),

                    _label('Select Course'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                      ),
                      decoration: _cardDecoration(),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Program>(
                          isExpanded: true,
                          hint: const Text('Which course are you reviewing?'),
                          icon: _isCheckingReview
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppColors.buttonBlue,
                                ),
                          value: _selectedProgram,
                          items: enrolledPrograms
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) async {
                            if (v == null) return;
                            final programId = v.id;
                            setState(() {
                              _selectedProgram = v;
                              _hasAlreadyReviewed = false;
                              _isCheckingReview = true;
                              _reviewCheckProgramId = programId;
                            });

                            try {
                              final user = context
                                  .read<AuthProvider>()
                                  .currentUser;
                              if (user != null) {
                                final already = await FirestoreService()
                                    .hasSubmittedFeedback(user.uid, programId);
                                // Ignore stale responses from a previous
                                // selection (learner switched programs).
                                if (!mounted ||
                                    _reviewCheckProgramId != programId) {
                                  return;
                                }
                                setState(() => _hasAlreadyReviewed = already);
                              }
                            } catch (e) {
                              if (!context.mounted ||
                                  _reviewCheckProgramId != programId) {
                                return;
                              }
                              showAppSnackBar(
                                context,
                                friendlyError(e),
                                isError: true,
                              );
                            } finally {
                              if (context.mounted &&
                                  _reviewCheckProgramId == programId) {
                                setState(() => _isCheckingReview = false);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.xxl),

                    // If already reviewed, show a clear info banner and hide
                    // the rest of the form so the learner cannot re-submit.
                    if (_hasAlreadyReviewed)
                      Container(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        decoration: BoxDecoration(
                          color: AppColors.buttonBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                          border: Border.all(
                            color: AppColors.buttonBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.buttonBlue,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                'You have already submitted feedback & review '
                                'for "${_selectedProgram!.title}". '
                                'You can select a different program to review '
                                'from the dropdown above.',
                                style: const TextStyle(
                                  color: AppColors.deepBlue,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!_hasAlreadyReviewed) ...[
                      _buildStarRow(
                        'Content Rating',
                        _contentRating,
                        (r) => setState(() => _contentRating = r),
                      ),
                      _buildStarRow(
                        'Instructor Rating',
                        _instructorRating,
                        (r) => setState(() => _instructorRating = r),
                      ),

                      Text(
                        'Your overall rating will be calculated as the average of the two ratings above.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: AppSizes.xxl),

                      _label('How was the course pace?'),
                      Row(
                        children:
                            [
                              ('Too Slow', fb.FeedbackPace.tooSlow),
                              ('Just Right', fb.FeedbackPace.justRight),
                              ('Too Fast', fb.FeedbackPace.tooFast),
                            ].map((entry) {
                              final (label, value) = entry;
                              final isSelected = _pace == value;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _pace = value),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.buttonBlue
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.buttonBlue
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radius,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: AppSizes.xxl),

                      _label('Detailed Review (Minimum 20 characters)'),
                      Container(
                        decoration: _cardDecoration(),
                        child: TextField(
                          controller: _reviewController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText:
                                'Write at least 20 characters about your experience...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(AppSizes.lg),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xxl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isSubmitting || _hasAlreadyReviewed)
                              ? null
                              : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit Review',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ), // SizedBox close
                    ], // !_hasAlreadyReviewed — end of conditional spread block
                  ], // Column children close
                ), // Column
              ), // SingleChildScrollView
        bottomNavigationBar: CustomBottomNav(
          currentTab: BottomNavTab.feedback,
          onTabChanged: (tab) => handleBottomNavTap(context, tab),
        ),
      ), // Scaffold
    ); // PopScope
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.deepBlue,
        ),
      ),
    );
  }

  Widget _buildStarRow(
    String title,
    int currentRating,
    Function(int) onRatingChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title),
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
          decoration: _cardDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Icon(
                  index < currentRating ? Icons.star : Icons.star_border,
                  size: 36,
                  color: AppColors.orangeAccent,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSizes.xxl),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.radius),
      boxShadow: const [
        BoxShadow(
          color: AppColors.cardShadow,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
