/// Shown after signup. User must verify their email before they can sign in.
///
/// Includes a 60-second cooldown on the Resend button, which resets after
/// each successful resend. A countdown timer shows seconds remaining.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  String? _email;
  String? _password;
  String? _firstName;
  String? _lastName;
  String? _nationality;
  bool _isChecking = false;
  bool _isResending = false;

  // ---- Resend cooldown ----
  static const int _cooldownSeconds = 60;
  int _secondsLeft = _cooldownSeconds;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_email != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _email = '${args['email']}';
      _password = '${args['password']}';
      _firstName = args['firstName']?.toString();
      _lastName = args['lastName']?.toString();
      _nationality = args['nationality']?.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    // Start countdown immediately — email was just sent during signup
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    _secondsLeft = _cooldownSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) t.cancel();
      });
    });
  }

  bool get _canResend => _secondsLeft <= 0 && !_isResending;

  // =========================================================================
  // "I've Verified"
  // =========================================================================

  Future<void> _onVerified() async {
    setState(() => _isChecking = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.signIn(
        email: _email!,
        password: _password!,
        firstName: _firstName,
        lastName: _lastName,
        nationality: _nationality,
      );
      if (mounted) {
        final target = auth.isAdmin
            ? AppRoutes.adminHome
            : AppRoutes.learnerHome;
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil(target, (_) => false);
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, friendlyError(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  // =========================================================================
  // Resend — restarts 60s cooldown after success
  // =========================================================================

  Future<void> _onResend() async {
    if (!_canResend) return;
    setState(() => _isResending = true);
    try {
      await context.read<AuthProvider>().resendVerificationEmail(
        email: _email!,
        password: _password!,
      );
      if (mounted) {
        showAppSnackBar(context, 'Verification email sent! Check your inbox.');
        _startCooldown(); // restart 60s timer
      }
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Could not resend. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // =========================================================================
  // Build
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.xxl),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Mail icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.buttonBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 48,
                  color: AppColors.buttonBlue,
                ),
              ),
              const SizedBox(height: AppSizes.xxl),

              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              Text(
                'We\'ve sent a verification link to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                _email ?? 'your email',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                'Click the link in the email, then tap\n"I\'ve Verified" below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.xxl),

              // "I've Verified"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _onVerified,
                  child: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "I've Verified, Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Resend with countdown — wrapped to prevent overflow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Didn't receive the email?",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _isResending
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _canResend
                        ? TextButton(
                            onPressed: _onResend,
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.buttonBlue,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Resend in $_secondsLeft s',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xxl),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                    ),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: AppSizes.xl),

              // Back to login
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false),
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.orangeAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
