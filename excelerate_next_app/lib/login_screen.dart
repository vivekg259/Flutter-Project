import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

  bool _isSigningIn = false;
  bool _isSigningInWithGoogle = false;
  bool _isSigningInWithApple = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSigningIn = true;
      });

      // Simulate authentication delay (replace with actual auth logic)
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
          });
          Navigator.pop(context); // Close loading dialog
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  // TODO: Wire up with the `google_sign_in` package (or your backend's
  // Google OAuth flow), then navigate on success.
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningInWithGoogle = true;
    });

    try {
      // Simulate authentication delay (replace with actual Google Sign In logic)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSigningInWithGoogle = false;
        });
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSigningInWithGoogle = false;
        });
        Navigator.pop(context); // Close loading dialog
      }
    }
  }

  // TODO: Wire up with the `sign_in_with_apple` package. Apple Sign In
  // also requires enabling the "Sign In with Apple" capability in Xcode
  // for iOS builds.
  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isSigningInWithApple = true;
    });

    try {
      // Simulate authentication delay (replace with actual Apple Sign In logic)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSigningInWithApple = false;
        });
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSigningInWithApple = false;
        });
        Navigator.pop(context); // Close loading dialog
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0056D2)),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF003366),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading dialog when any auth is in progress
    if (_isSigningIn || _isSigningInWithGoogle || _isSigningInWithApple) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          String message = 'Signing in...';
          if (_isSigningInWithGoogle) {
            message = 'Signing in with Google...';
          } else if (_isSigningInWithApple) {
            message = 'Signing in with Apple...';
          }

          if (!Navigator.of(context).canPop() ||
              !context.mounted ||
              ModalRoute.of(context)?.isCurrent != true) {
            _showLoadingDialog(message);
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Logo Placement 2: Login Screen
                Center(child: Image.asset('assets/logo.png', height: 50)),
                const SizedBox(height: 40),

                const Text(
                  'Welcome\nBack',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 30),

                // White Card with Soft Shadows
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
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
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFFFF6D00)),
                          ), // Orange Accent
                        ),
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed:
                            _isSigningIn ||
                                _isSigningInWithGoogle ||
                                _isSigningInWithApple
                            ? null
                            : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF0056D2),
                          disabledBackgroundColor: const Color(0xFFB3D9FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSigningIn
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

                // "Or continue with" divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Social sign-in buttons
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton.google(
                        onPressed:
                            _isSigningIn ||
                                _isSigningInWithGoogle ||
                                _isSigningInWithApple
                            ? null
                            : _handleGoogleSignIn,
                        isLoading: _isSigningInWithGoogle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SocialButton.apple(
                        onPressed:
                            _isSigningIn ||
                                _isSigningInWithGoogle ||
                                _isSigningInWithApple
                            ? null
                            : _handleAppleSignIn,
                        isLoading: _isSigningInWithApple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                OutlinedButton(
                  onPressed:
                      _isSigningIn ||
                          _isSigningInWithGoogle ||
                          _isSigningInWithApple
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/signup');
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(
                      color:
                          _isSigningIn ||
                              _isSigningInWithGoogle ||
                              _isSigningInWithApple
                          ? const Color(0xFFB3D9FF)
                          : const Color(0xFF0056D2),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create New account',
                    style: TextStyle(
                      color:
                          _isSigningIn ||
                              _isSigningInWithGoogle ||
                              _isSigningInWithApple
                          ? const Color(0xFFB3D9FF)
                          : const Color(0xFF0056D2),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A modern, pill-shaped social sign-in button. Use the [_SocialButton.google]
/// and [_SocialButton.apple] named constructors so styling stays consistent
/// wherever this is reused (e.g. on the signup screen).
class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
    this.isLoading = false,
  });

  factory _SocialButton.google({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return _SocialButton(
      label: 'Google',
      // Swap for Image.asset('assets/google_logo.png', height: 20) once you
      // add the multicolor "G" logo asset to your project + pubspec.yaml.
      icon: const _GoogleGlyph(),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1F1F1F),
      borderColor: const Color(0xFFDADCE0),
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  factory _SocialButton.apple({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return _SocialButton(
      label: 'Apple',
      icon: const Icon(Icons.apple, size: 22, color: Colors.white),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: onPressed == null
              ? backgroundColor.withValues(alpha: 0.6)
              : backgroundColor,
          side: BorderSide(
            color: onPressed == null
                ? (borderColor ?? Colors.transparent).withValues(alpha: 0.5)
                : (borderColor ?? Colors.transparent),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0056D2)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onPressed == null
                            ? foregroundColor.withValues(alpha: 0.6)
                            : foregroundColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A dependency-free approximation of the Google "G" logo using layered
/// arcs in Google's brand colors. Swap this out for the official asset
/// (assets/google_logo.png) or the `font_awesome_flutter` package if you'd
/// rather use the pixel-perfect version.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width * 0.22;
    final Rect rect = Offset.zero & size;
    final Offset center = rect.center;
    final double radius = (size.width - strokeWidth) / 2;

    void drawArc(double startDegrees, double sweepDegrees, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startDegrees * 3.1415926535 / 180,
        sweepDegrees * 3.1415926535 / 180,
        false,
        paint,
      );
    }

    // Four brand-colored arcs approximating the Google "G".
    drawArc(-40, 110, const Color(0xFF4285F4)); // blue (right)
    drawArc(70, 80, const Color(0xFF34A853)); // green (bottom)
    drawArc(150, 60, const Color(0xFFFBBC05)); // yellow (left)
    drawArc(210, 130, const Color(0xFFEA4335)); // red (top)

    // Horizontal bar of the "G"
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - strokeWidth / 2,
        radius + strokeWidth / 2,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
