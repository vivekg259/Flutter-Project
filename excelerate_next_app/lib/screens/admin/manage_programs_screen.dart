/// Manage Programs — admin CRUD list of all programs.
///
/// Uses [ProgramProvider] for the live list. Tap to edit, swipe to delete.
/// Floating action button launches [CreateProgramScreen].
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/program.dart';
import '../../providers/program_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';

class ManageProgramsScreen extends StatelessWidget {
  const ManageProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final programs = context.watch<ProgramProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Programs')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.buttonBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.adminCreateProgram),
      ),
      body: programs.isLoading
          ? const LoadingOverlay()
          : programs.programs.isEmpty
          ? const EmptyState(
              icon: Icons.school_outlined,
              title: 'No programs yet',
              subtitle: 'Tap + to publish your first program.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.xl),
              itemCount: programs.programs.length,
              itemBuilder: (_, i) {
                final p = programs.programs[i];
                return _ProgramRow(program: p);
              },
            ),
    );
  }
}

class _ProgramRow extends StatelessWidget {
  const _ProgramRow({required this.program});

  final Program program;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(program.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.menu_book, color: color, size: 20),
        ),
        title: Text(
          program.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${program.instructor} • ${program.status} • ${program.registeredCount}/${program.capacity} seats',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleAction(context, action),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (program.status != ProgramStatus.closed)
              const PopupMenuItem(value: 'close', child: Text('Close')),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: () => _editProgram(context),
      ),
    );
  }

  void _editProgram(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.adminCreateProgram,
      arguments: program,
    );
  }

  void _handleAction(BuildContext context, String action) async {
    if (action == 'edit') {
      _editProgram(context);
      return;
    }
    if (action == 'close') {
      final updated = program.copyWith(status: ProgramStatus.closed);
      await FirestoreService().updateProgram(updated);
      if (context.mounted) {
        showAppSnackBar(context, 'Program closed.');
      }
      return;
    }
    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Program?'),
          content: Text('Are you sure you want to delete "${program.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await FirestoreService().deleteProgram(program.id);
      if (context.mounted) {
        showAppSnackBar(context, 'Program deleted.');
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case ProgramStatus.open:
        return Colors.green;
      case ProgramStatus.upcoming:
        return AppColors.orangeAccent;
      case ProgramStatus.closed:
        return Colors.grey;
      default:
        return AppColors.buttonBlue;
    }
  }
}
