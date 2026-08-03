/// Participants Tracker — admin sees all registered learners per program
/// with ability to Approve / Reject pending registrations.
///
/// Uses real-time Firestore streams. Status changes propagate instantly.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/program.dart';
import '../../models/registration.dart';
import '../../providers/program_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class ParticipantsTrackerScreen extends StatefulWidget {
  const ParticipantsTrackerScreen({super.key});

  @override
  State<ParticipantsTrackerScreen> createState() =>
      _ParticipantsTrackerScreenState();
}

class _ParticipantsTrackerScreenState extends State<ParticipantsTrackerScreen> {
  Program? _selectedProgram;
  List<Registration> _registrations = [];
  bool _isLoading = false;
  StreamSubscription<List<Registration>>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onProgramChanged(Program? program) {
    _sub?.cancel();
    setState(() {
      _selectedProgram = program;
      _registrations = [];
    });
    if (program != null) {
      _isLoading = true;
      _sub = FirestoreService()
          .watchProgramRegistrations(program.id)
          .listen(
            (regs) {
              if (mounted) {
                setState(() {
                  _registrations = regs;
                  _isLoading = false;
                });
              }
            },
            onError: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final programs = context.watch<ProgramProvider>().programs;

    return Scaffold(
      appBar: AppBar(title: const Text('Participants')),
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
                border: Border.all(color: Colors.grey.shade300),
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
                  onChanged: _onProgramChanged,
                ),
              ),
            ),
          ),

          // Registrations list
          Expanded(
            child: _selectedProgram == null
                ? const EmptyState(
                    icon: Icons.people_outline,
                    title: 'Select a program',
                    subtitle:
                        'Choose a program above to view its participants.',
                  )
                : _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _registrations.isEmpty
                ? const EmptyState(
                    icon: Icons.person_off,
                    title: 'No participants yet',
                    subtitle: 'No learners have registered for this program.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xl,
                    ),
                    itemCount: _registrations.length,
                    itemBuilder: (_, i) {
                      final r = _registrations[i];
                      return _ParticipantTile(
                        registration: r,
                        onApprove: r.isPending ? () => _approve(r.id) : null,
                        onReject: r.isPending
                            ? () => _reject(r.id, r.programId)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(String id) async {
    await FirestoreService().approveRegistration(id);
    if (mounted) showAppSnackBar(context, 'Registration approved.');
  }

  Future<void> _reject(String id, String programId) async {
    await FirestoreService().rejectRegistration(id, programId);
    if (mounted) {
      showAppSnackBar(context, 'Registration rejected.', isError: true);
    }
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.registration,
    this.onApprove,
    this.onReject,
  });

  final Registration registration;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.buttonBlue.withValues(alpha: 0.1),
              child: Text(
                initialsOf(registration.userName),
                style: const TextStyle(
                  color: AppColors.buttonBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registration.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    registration.userEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Approval actions for pending
            if (registration.isPending) ...[
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Approve',
                onPressed: onApprove,
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                tooltip: 'Reject',
                onPressed: onReject,
              ),
            ],
            // Status badge for resolved
            if (!registration.isPending)
              _StatusBadge(status: registration.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      RegistrationStatus.approved => (
        Colors.green.shade50,
        Colors.green.shade700,
        'Approved',
      ),
      RegistrationStatus.rejected => (
        Colors.red.shade50,
        Colors.red.shade700,
        'Rejected',
      ),
      RegistrationStatus.cancelled => (
        Colors.grey.shade100,
        Colors.grey.shade600,
        'Cancelled',
      ),
      _ => (Colors.orange.shade50, Colors.orange.shade700, 'Pending'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
