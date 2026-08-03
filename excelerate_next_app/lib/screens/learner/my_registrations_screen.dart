/// "My Registrations" screen — shows the learner's applied programs
/// with real-time approval status from admins.
///
/// Reads from [RegistrationProvider] (which itself streams from Firestore).
/// Status badges update instantly as the admin approves/rejects.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/registration.dart';
import '../../providers/registration_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class MyRegistrationsScreen extends StatelessWidget {
  const MyRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registrations = context.watch<RegistrationProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Registrations'),
      ),
      body: registrations.isLoading
          ? const Center(child: CircularProgressIndicator())
          : registrations.visible.isEmpty
          ? EmptyState(
              icon: Icons.event_busy,
              title: 'No registrations yet',
              subtitle: 'Browse programs and apply to see them here.',
              actionLabel: 'Browse Programs',
              onAction: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.learnerPrograms,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.xl),
              itemCount: registrations.visible.length,
              itemBuilder: (_, i) {
                final reg = registrations.visible[i];
                return _RegistrationCard(registration: reg);
              },
            ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.registration});

  final Registration registration;

  @override
  Widget build(BuildContext context) {
    final (Color chipBg, Color chipFg, String chipLabel) = () {
      if (registration.isApproved) {
        return (Colors.green.shade50, Colors.green.shade700, 'Approved');
      }
      if (registration.isPending) {
        return (
          Colors.orange.shade50,
          Colors.orange.shade700,
          'Pending Approval',
        );
      }
      if (registration.isRejected) {
        return (Colors.red.shade50, Colors.red.shade700, 'Rejected');
      }
      return (Colors.grey.shade100, Colors.grey.shade600, registration.status);
    }();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 24, color: AppColors.orangeAccent),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  registration.programTitle ?? 'Program',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (registration.programInstructor != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Text(
                'Instructor: ${registration.programInstructor}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applied: ${formatDate(registration.registeredAt)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: chipFg,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
