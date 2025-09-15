import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class ReusableHeaderWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ReusableHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = ThemeConstants.primary,
    this.backgroundColor = ThemeConstants.surfaceGrey,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.all(ThemeConstants.spacingL),
      padding: padding ?? const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
            ),
            child: Icon(
              icon,
              size: 32,
              color: ThemeConstants.backgroundWhite,
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          Text(
            title,
            style: ThemeConstants.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.spacingXS),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: iconColor.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
