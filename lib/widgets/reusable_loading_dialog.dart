import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class ReusableLoadingDialog extends StatelessWidget {
  final String message;
  final Color? indicatorColor;
  final bool barrierDismissible;

  const ReusableLoadingDialog({
    super.key,
    required this.message,
    this.indicatorColor = ThemeConstants.primary,
    this.barrierDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeConstants.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: indicatorColor),
          const SizedBox(width: ThemeConstants.spacingL),
          Expanded(
            child: Text(
              message,
              style: ThemeConstants.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, {
    required String message,
    Color? indicatorColor,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ReusableLoadingDialog(
        message: message,
        indicatorColor: indicatorColor,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
