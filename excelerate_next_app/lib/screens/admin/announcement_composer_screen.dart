/// Announcement Composer — admin pushes announcements to all learners.
///
/// Writes directly to Firestore via [FirestoreService.createAnnouncement].
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/announcement.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class AnnouncementComposerScreen extends StatefulWidget {
  const AnnouncementComposerScreen({super.key});

  @override
  State<AnnouncementComposerScreen> createState() =>
      _AnnouncementComposerScreenState();
}

class _AnnouncementComposerScreenState
    extends State<AnnouncementComposerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _type = AnnouncementType.info;
  String _priority = AnnouncementPriority.medium;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.isAdmin) return;

    setState(() => _isSubmitting = true);
    try {
      final announcement = Announcement(
        id: '',
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: _type,
        priority: _priority,
        createdBy: user.uid,
        createdAt: DateTime.now(),
      );
      await FirestoreService().createAnnouncement(announcement);

      if (mounted) {
        showAppSnackBar(context, 'Announcement published!');
        _titleController.clear();
        _bodyController.clear();
        setState(() {
          _type = AnnouncementType.info;
          _priority = AnnouncementPriority.medium;
        });
      }
    } catch (e) {
      if (mounted) showAppSnackBar(context, friendlyError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compose Announcement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Week 3 Live Session Reminder',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSizes.xl),

              // Body
              TextFormField(
                controller: _bodyController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Write the announcement body...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Message is required'
                    : null,
              ),
              const SizedBox(height: AppSizes.xl),

              // Type dropdown
              const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSizes.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _type,
                    items: [
                      _buildTypeItem(AnnouncementType.info, 'Informational'),
                      _buildTypeItem(AnnouncementType.reminder, 'Reminder'),
                      _buildTypeItem(AnnouncementType.deadline, 'Deadline'),
                      _buildTypeItem(AnnouncementType.event, 'Event'),
                    ],
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Priority
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Flexible(
                    child: _PriorityChip(
                      label: 'Low',
                      selected: _priority == AnnouncementPriority.low,
                      onTap: () =>
                          setState(() => _priority = AnnouncementPriority.low),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Flexible(
                    child: _PriorityChip(
                      label: 'Medium',
                      selected: _priority == AnnouncementPriority.medium,
                      onTap: () => setState(
                        () => _priority = AnnouncementPriority.medium,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Flexible(
                    child: _PriorityChip(
                      label: 'High',
                      selected: _priority == AnnouncementPriority.high,
                      onTap: () =>
                          setState(() => _priority = AnnouncementPriority.high),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xxl),

              // Publish button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _publish,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Publish Announcement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildTypeItem(String value, String label) {
    return DropdownMenuItem(value: value, child: Text(label));
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        backgroundColor: selected ? AppColors.buttonBlue : Colors.grey[200],
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
