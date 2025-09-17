import 'package:flutter/material.dart';
import '../../constants/theme_constants.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBackPressed;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacing20),
      decoration: const BoxDecoration(
        color: ThemeConstants.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ThemeConstants.radiusXLarge),
          bottomRight: Radius.circular(ThemeConstants.radiusXLarge),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (onBackPressed != null)
                  Padding(
                    padding: const EdgeInsets.only(right: ThemeConstants.spacing12),
                    child: IconButton(
                      onPressed: onBackPressed,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: ThemeConstants.primaryWhite,
                        size: ThemeConstants.iconMedium,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: ThemeConstants.primaryWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: ThemeConstants.spacing8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ThemeConstants.primaryWhite.withOpacity(0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
