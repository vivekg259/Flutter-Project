/// Create / Edit Program screen — admin form for publishing programs.
///
/// Supports both create (new) and update (edit) modes. Pass an existing
/// [Program] in route arguments to pre-fill the form for editing.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/program.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class CreateProgramScreen extends StatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  State<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _eligibilityCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  String _level = 'Beginner';
  String _status = ProgramStatus.open;
  bool _publishNow = true;
  DateTime? _scheduledPublishAt;
  bool _isSubmitting = false;
  Program? _editProgram;
  bool get _isEdit => _editProgram != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editProgram != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Program) {
      _editProgram = args;
      _titleCtrl.text = args.title;
      _descCtrl.text = args.description;
      _instructorCtrl.text = args.instructor;
      _durationCtrl.text = args.duration;
      _scheduleCtrl.text = args.schedule ?? '';
      _eligibilityCtrl.text = args.eligibility ?? '';
      _skillsCtrl.text = args.skills.join(', ');
      _capacityCtrl.text = '${args.capacity}';
      _level = args.level;
      _status = args.status;
      if (args.publishAt != null) {
        _publishNow = false;
        _scheduledPublishAt = args.publishAt;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _instructorCtrl.dispose();
    _durationCtrl.dispose();
    _scheduleCtrl.dispose();
    _eligibilityCtrl.dispose();
    _skillsCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const levels = ['Beginner', 'Intermediate', 'Advanced'];

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Program' : 'Create Program')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                'Title',
                _titleCtrl,
                hint: 'e.g., Flutter Development Bootcamp',
              ),
              const SizedBox(height: AppSizes.xl),
              _field(
                'Description',
                _descCtrl,
                maxLines: 4,
                hint: 'Describe what this program covers...',
              ),
              const SizedBox(height: AppSizes.xl),
              _field(
                'Instructor',
                _instructorCtrl,
                hint: 'e.g., Dr. Alex Rivera',
              ),
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      'Duration',
                      _durationCtrl,
                      hint: 'e.g., 6 Weeks',
                    ),
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(
                    child: _numberField('Capacity', _capacityCtrl, hint: '50'),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Level dropdown
              const Text(
                'Level',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.sm),
              _dropdown(levels, _level, (v) => setState(() => _level = v!)),
              const SizedBox(height: AppSizes.xl),

              // Publish control — Now vs Scheduled
              const Text(
                'Publish',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: _PublishChip(
                      label: 'Publish Now',
                      selected: _publishNow,
                      enabled: true,
                      onTap: () => setState(() => _publishNow = true),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: _PublishChip(
                      label: 'Schedule Publish',
                      selected: !_publishNow,
                      enabled:
                          !_isEdit ||
                          (_scheduledPublishAt == null ||
                              _scheduledPublishAt!.isAfter(DateTime.now())),
                      onTap: () => setState(() => _publishNow = false),
                    ),
                  ),
                ],
              ),

              // Schedule presets (only when Schedule selected)
              if (!_publishNow) ...[
                const SizedBox(height: AppSizes.lg),
                Wrap(
                  spacing: AppSizes.md,
                  runSpacing: AppSizes.sm,
                  children: [
                    _PresetChip(
                      label: '+30 min',
                      selected: _isPresetActive(const Duration(minutes: 30)),
                      onTap: () => _applyPreset(const Duration(minutes: 30)),
                    ),
                    _PresetChip(
                      label: '+2 days',
                      selected: _isPresetActive(const Duration(days: 2)),
                      onTap: () => _applyPreset(const Duration(days: 2)),
                    ),
                    _PresetChip(
                      label: '+1 week',
                      selected: _isPresetActive(const Duration(days: 7)),
                      onTap: () => _applyPreset(const Duration(days: 7)),
                    ),
                    _PresetChip(
                      label: 'Custom',
                      selected:
                          _scheduledPublishAt != null &&
                          !_isAnyQuickPresetActive(),
                      onTap: _pickDateTime,
                    ),
                  ],
                ),

                // Preview
                if (_scheduledPublishAt != null) ...[
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Will be published on ${formatDateTime(_scheduledPublishAt)}',
                    style: TextStyle(
                      color: AppColors.buttonBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],

                // Hint when no date selected
                if (_scheduledPublishAt == null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Select a preset or pick a custom date & time',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ],

              const SizedBox(height: AppSizes.xl),

              // Status dropdown (edit mode)
              if (_isEdit) ...[
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSizes.sm),
                _dropdown(
                  [
                    ProgramStatus.open,
                    ProgramStatus.upcoming,
                    ProgramStatus.closed,
                  ],
                  _status,
                  (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: AppSizes.xl),
              ],

              _field(
                'Schedule',
                _scheduleCtrl,
                hint: 'e.g., Mon & Wed, 6:00–8:00 PM',
              ),
              const SizedBox(height: AppSizes.xl),
              _field(
                'Eligibility',
                _eligibilityCtrl,
                hint: 'e.g., Basic programming knowledge',
              ),
              const SizedBox(height: AppSizes.xl),
              _field(
                'Skills',
                _skillsCtrl,
                hint: 'e.g., Flutter, Dart, Firebase (comma-separated)',
              ),
              const SizedBox(height: AppSizes.xxl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _save,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(_isEdit ? 'Update Program' : 'Publish Program'),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null || !user.isAdmin) return;

    final capacity = int.tryParse(_capacityCtrl.text.trim());
    if (capacity == null || capacity < 0) {
      showAppSnackBar(
        context,
        'Please enter a valid number for capacity.',
        isError: true,
      );
      return;
    }

    if (!_publishNow && _scheduledPublishAt == null) {
      showAppSnackBar(
        context,
        'Please select a scheduled publish time.',
        isError: true,
      );
      return;
    }
    if (!_publishNow &&
        _scheduledPublishAt != null &&
        !_scheduledPublishAt!.isAfter(DateTime.now())) {
      showAppSnackBar(
        context,
        'Scheduled publish time must be in the future.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final program = Program(
        id: _editProgram?.id ?? '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        instructor: _instructorCtrl.text.trim(),
        duration: _durationCtrl.text.trim(),
        level: _level,
        skills: _skillsCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        rating: _editProgram?.rating ?? 0.0,
        reviewsCount: _editProgram?.reviewsCount ?? 0,
        capacity: capacity,
        registeredCount: _editProgram?.registeredCount ?? 0,
        status: _status,
        eligibility: _eligibilityCtrl.text.trim(),
        schedule: _scheduleCtrl.text.trim(),
        createdBy: _editProgram?.createdBy ?? user.uid,
        publishAt: _publishNow ? null : _scheduledPublishAt,
        createdAt: _editProgram?.createdAt ?? DateTime.now(),
      );

      if (_isEdit) {
        await FirestoreService().updateProgram(program);
        if (mounted) {
          showAppSnackBar(context, 'Program updated!');
          Navigator.pop(context);
        }
      } else {
        await FirestoreService().createProgram(program);
        if (mounted) {
          showAppSnackBar(context, 'Program published!');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) showAppSnackBar(context, friendlyError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  bool _isPresetActive(Duration d) {
    if (_scheduledPublishAt == null) return false;
    final preset = DateTime.now().add(d);
    return _scheduledPublishAt!.difference(preset).inMinutes.abs() < 1;
  }

  bool _isAnyQuickPresetActive() =>
      _isPresetActive(const Duration(minutes: 30)) ||
      _isPresetActive(const Duration(days: 2)) ||
      _isPresetActive(const Duration(days: 7));

  void _applyPreset(Duration d) =>
      setState(() => _scheduledPublishAt = DateTime.now().add(d));

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledPublishAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledPublishAt != null
          ? TimeOfDay.fromDateTime(_scheduledPublishAt!)
          : TimeOfDay.fromDateTime(now.add(const Duration(minutes: 30))),
    );
    if (time == null) return;
    setState(() {
      _scheduledPublishAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? '$label is required' : null,
    );
  }

  Widget _numberField(
    String label,
    TextEditingController ctrl, {
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label is required';
        final n = int.tryParse(v.trim());
        if (n == null || n < 0) return 'Enter a valid number';
        return null;
      },
    );
  }

  Widget _dropdown(
    List<String> items,
    String current,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: current,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PublishChip extends StatelessWidget {
  const _PublishChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.buttonBlue
              : (enabled ? Colors.white : Colors.grey[200]),
          border: Border.all(
            color: selected ? AppColors.buttonBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled
                ? (selected ? Colors.white : Colors.black87)
                : Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.buttonBlue : Colors.white,
          border: Border.all(
            color: selected ? AppColors.buttonBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.buttonBlue,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
