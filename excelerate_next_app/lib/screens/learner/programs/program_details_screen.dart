/// Program details with registration workflow:
///   Enroll → Admin Approval → Enrolled / Rejected (30-day cooldown).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/program.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/registration_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';

class ProgramDetailsScreen extends StatefulWidget {
  const ProgramDetailsScreen({super.key});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  Program? _program;
  bool _isRegistering = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _program ??= ModalRoute.of(context)?.settings.arguments as Program?;
  }

  Future<void> _handleRegister() async {
    if (_program == null) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    setState(() => _isRegistering = true);
    try {
      await context.read<RegistrationProvider>().register(user, _program!);
      if (mounted) {
        showAppSnackBar(
          context,
          'Application submitted! Awaiting admin approval.',
        );
      }
    } catch (e) {
      if (mounted) showAppSnackBar(context, friendlyError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrations = context.watch<RegistrationProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    if (_program == null) {
      return Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/logo.png', height: AppSizes.logoAppBar),
          centerTitle: true,
        ),
        body: const EmptyProgramState(),
      );
    }

    final program = _program!;
    final reg = user != null ? registrations.registrationFor(program.id) : null;
    final isEnrolled = reg?.isEnrolled ?? false;
    final isPending = reg?.isPending ?? false;
    final isRejected = reg?.isRejected ?? false;
    final canReapply = reg?.canReapply ?? false;
    final daysLeft = reg?.daysUntilReapply ?? 0;

    final (buttonLabel, buttonActive, buttonColor) = _buttonState(
      program: program,
      isEnrolled: isEnrolled,
      isPending: isPending,
      isRejected: isRejected,
      canReapply: canReapply,
      daysLeft: daysLeft,
    );

    final seatsLeft = program.capacity == 0
        ? null
        : (program.capacity - program.registeredCount).clamp(0, 1 << 31);
    final seatsLabel = seatsLeft == null
        ? null
        : seatsLeft > 0
        ? '$seatsLeft left'
        : 'Full';

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: AppSizes.logoAppBar),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        program.ratingShort,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (program.reviewsCount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${program.reviewsCount})',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(width: AppSizes.sm),
                      const Icon(Icons.verified, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Excelerate Certified',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.xxl),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailIcon(
                          Icons.access_time_filled,
                          program.duration,
                          'Duration',
                        ),
                        _DetailIcon(Icons.bar_chart, program.level, 'Level'),
                        _DetailIcon(
                          Icons.people_outline,
                          seatsLabel ?? 'Unlimited',
                          'Seats',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xxl),
                  const Text(
                    'Instructor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.buttonBlue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.instructor,
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
                  const SizedBox(height: AppSizes.xxl),
                  const Text(
                    'Skills you will gain',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: program.skills
                        .map(
                          (s) => Chip(
                            label: Text(
                              s.trim(),
                              style: const TextStyle(
                                color: AppColors.buttonBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: AppColors.buttonBlue.withValues(
                              alpha: 0.1,
                            ),
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSizes.xxl),
                  const Text(
                    'About the course',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    program.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  if (program.eligibility != null &&
                      program.eligibility!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xxl),
                    const Text(
                      'Eligibility',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      program.eligibility!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 15,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: _isRegistering
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.buttonBlue,
                        ),
                      )
                    : buttonActive
                    ? ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor ?? AppColors.buttonBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius,
                            ),
                          ),
                        ),
                        child: Text(
                          buttonLabel ?? 'Enroll Now',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (buttonColor ?? Colors.grey).withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                        child: Text(
                          buttonLabel ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: buttonColor ?? Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static (String?, bool, Color?) _buttonState({
    required Program program,
    required bool isEnrolled,
    required bool isPending,
    required bool isRejected,
    required bool canReapply,
    required int daysLeft,
  }) {
    if (isEnrolled) return ('✓ Enrolled', false, Colors.green);
    if (isPending) return ('Awaiting Approval', false, AppColors.orangeAccent);
    if (isRejected && !canReapply) {
      return (
        'Re-enroll in $daysLeft day${daysLeft == 1 ? '' : 's'}',
        false,
        Colors.red,
      );
    }
    if (!program.isPublished) {
      return ('Coming Soon', false, Colors.grey);
    }
    if (program.status == ProgramStatus.closed) {
      return ('Registration Closed', false, Colors.grey);
    }
    if (!program.hasSeats) return ('No Seats Left', false, Colors.grey);
    return ('Enroll Now', true, AppColors.buttonBlue);
  }
}

class _DetailIcon extends StatelessWidget {
  const _DetailIcon(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppColors.orangeAccent),
        const SizedBox(height: AppSizes.sm),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class EmptyProgramState extends StatelessWidget {
  const EmptyProgramState({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Program not found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
