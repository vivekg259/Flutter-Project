/// A centered loading spinner with an optional message.
///
/// Used as a body replacement while data is being fetched.
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.message = 'Loading...',
    this.spinnerColor,
  });

  final String message;
  final Color? spinnerColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: spinnerColor ?? AppColors.orangeAccent,
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// A dialog-style loading indicator (for auth, form submissions).
///
/// Call [show] to display and [hide] to dismiss.
class LoadingDialog {
  LoadingDialog._();

  static bool _isVisible = false;

  /// Shows a non-dismissible loading dialog.
  static void show(BuildContext context, {String message = 'Please wait...'}) {
    if (_isVisible) return;
    _isVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonBlue),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.deepBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dismisses the loading dialog.
  static void hide(BuildContext context) {
    if (_isVisible && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _isVisible = false;
  }
}
