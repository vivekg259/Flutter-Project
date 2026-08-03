/// Login screen — wired to real Firebase Authentication via [AuthProvider].
///
/// Form validation reuses the centralized [Validators]. Loading state is
/// handled through the shared [LoadingDialog] widget. On success the
/// [AuthProvider] flips to authenticated, and the auth wrapper redirects.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final provider = context.read<AuthProvider>();
    final navigator = Navigator.of(context, rootNavigator: true);

    LoadingDialog.show(context, message: 'Signing in...');
    try {
      await provider.signIn(email: email, password: password);
      if (mounted) {
        LoadingDialog.hide(context);
        final target = provider.isAdmin
            ? AppRoutes.adminHome
            : AppRoutes.learnerHome;
        navigator.pushNamedAndRemoveUntil(target, (_) => false);
      }
    } catch (e) {
      final msg = friendlyError(e);
      if (mounted) LoadingDialog.hide(context);

      // ---- Unverified email → resend link + redirect to verification ----
      if (msg.contains('Email not verified')) {
        await provider.resendVerificationEmail(
          email: email,
          password: password,
        );
        if (mounted) {
          navigator.pushNamedAndRemoveUntil(
            AppRoutes.emailVerification,
            (_) => false,
            arguments: {'email': email, 'password': password},
          );
        }
        return;
      }

      // ---- Other errors (wrong password, not found, etc.) ----
      if (mounted) {
        showAppSnackBar(context, msg, isError: true);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (!RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      showAppSnackBar(
        context,
        'Enter your email above first to reset password.',
        isError: true,
      );
      return;
    }
    try {
      await context.read<AuthProvider>().resetPassword(email);
      if (mounted) {
        showAppSnackBar(
          context,
          'Password reset email sent. Check your inbox.',
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, friendlyError(e), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen so we auto-hide the dialog once authenticated (the wrapper
    // takes over navigation).
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.xxl),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.lg),

                // Logo Placement 2: Login Screen
                Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: AppSizes.logoInline,
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'Welcome\nBack',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: AppColors.deepBlue,
                  ),
                ),
                const SizedBox(height: 30),

                // White Card with Soft Shadows
                Container(
                  padding: const EdgeInsets.all(AppSizes.xxl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),

                      const Text(
                        'Password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: Validators.password,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: AppColors.orangeAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSignIn,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // "Not a member yet?" CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppColors.buttonBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                // Show auth error (if any) below the form
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: AppSizes.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
