/// Feedback Dashboard — admin views aggregated ratings and reviews per program.
///
/// Select a program to see its average ratings, pace distribution,
/// and a list of individual review submissions.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/feedback.dart' as fb;
import '../../models/program.dart';
import '../../providers/program_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/rating_stars.dart';

class FeedbackDashboardScreen extends StatefulWidget {
  const FeedbackDashboardScreen({super.key});

  @override
  State<FeedbackDashboardScreen> createState() =>
      _FeedbackDashboardScreenState();
}

class _FeedbackDashboardScreenState extends State<FeedbackDashboardScreen> {
  Program? _selectedProgram;
  List<fb.Feedback> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<fb.Feedback>>? _sub;

  double get _avgContent => _items.isEmpty
      ? 0
      : _items.map((f) => f.contentRating).reduce((a, b) => a + b) /
            _items.length;
  double get _avgInstructor => _items.isEmpty
      ? 0
      : _items.map((f) => f.instructorRating).reduce((a, b) => a + b) /
            _items.length;
  double get _avgOverall => _items.isEmpty
      ? 0
      : _items
                .map((f) => (f.contentRating + f.instructorRating) / 2)
                .reduce((a, b) => a + b) /
            _items.length;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _selectProgram(Program? p) {
    _sub?.cancel();
    setState(() {
      _selectedProgram = p;
      _items = [];
      _errorMessage = null;
    });
    if (p != null) {
      setState(() => _isLoading = true);
      _sub = FirestoreService()
          .watchProgramFeedback(p.id)
          .listen(
            (list) {
              if (mounted) {
                setState(() {
                  _items = list;
                  _isLoading = false;
                  _errorMessage = null;
                });
              }
            },
            onError: (err) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Failed to load feedback. Please try again.';
                });
              }
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final programs = context.watch<ProgramProvider>().programs;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Dashboard')),
      body: Column(
        children: [
          // Program selector
          Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Program>(
                  isExpanded: true,
                  hint: const Text('Select a program'),
                  value: _selectedProgram,
                  items: programs
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
                  onChanged: _selectProgram,
                ),
              ),
            ),
          ),

          Expanded(
            child: _selectedProgram == null
                ? const EmptyState(
                    icon: Icons.analytics_outlined,
                    title: 'Select a program',
                    subtitle: 'Choose a program to see its feedback analytics.',
                  )
                : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? EmptyState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    subtitle: _errorMessage!,
                    actionLabel: 'Retry',
                    onAction: () => _selectProgram(_selectedProgram),
                  )
                : _items.isEmpty
                ? const EmptyState(
                    icon: Icons.rate_review_outlined,
                    title: 'No feedback yet',
                    subtitle:
                        'No learners have submitted feedback for this program.',
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final paceCounts = {
      'Too Slow': _items.where((f) => f.pace == fb.FeedbackPace.tooSlow).length,
      'Just Right': _items
          .where((f) => f.pace == fb.FeedbackPace.justRight)
          .length,
      'Too Fast': _items.where((f) => f.pace == fb.FeedbackPace.tooFast).length,
    };

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      children: [
        // Ratings summary
        Card(
          margin: const EdgeInsets.only(bottom: AppSizes.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              children: [
                const Text(
                  'Average Ratings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Column(
                  children: [
                    _StatRow('Content', _avgContent),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _StatRow('Instructor', _avgInstructor),
                    Divider(height: 1, color: Colors.grey.shade200),
                    _StatRow('Overall', _avgOverall),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  '${_items.length} review${_items.length == 1 ? '' : 's'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        // Pace distribution
        Card(
          margin: const EdgeInsets.only(bottom: AppSizes.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pace Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                ...paceCounts.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 80, child: Text(e.key)),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _items.isEmpty ? 0 : e.value / _items.length,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.buttonBlue,
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: Text('${e.value}', textAlign: TextAlign.end),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Individual reviews
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ..._items.map((f) => _ReviewCard(feedback: f)),
        const SizedBox(height: AppSizes.xl),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.deepBlue,
              ),
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
          const SizedBox(width: 8),
          RatingStars(rating: value.round(), enabled: false, size: 18),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.feedback});
  final fb.Feedback feedback;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.buttonBlue.withValues(alpha: 0.1),
                  child: Text(
                    initialsOf(feedback.userName),
                    style: const TextStyle(
                      color: AppColors.buttonBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userName ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        formatDate(feedback.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: RatingStars(
                    rating:
                        ((feedback.contentRating + feedback.instructorRating) /
                                2)
                            .round(),
                    enabled: false,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (feedback.review.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                feedback.review,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.sm),
            Text(
              'Pace: ${feedback.pace == fb.FeedbackPace.tooSlow
                  ? "Too Slow"
                  : feedback.pace == fb.FeedbackPace.tooFast
                  ? "Too Fast"
                  : "Just Right"}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
