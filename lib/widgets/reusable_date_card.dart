import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme_constants.dart';

class ReusableDateCard extends StatelessWidget {
  final DateTime date;
  final int count;
  final String type;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsets? margin;

  const ReusableDateCard({
    super.key,
    required this.date,
    required this.count,
    required this.type,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isYesterday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
    
    String dateText;
    if (isToday) {
      dateText = 'Hari Ini';
    } else if (isYesterday) {
      dateText = 'Kemarin';
    } else {
      dateText = dateFormat.format(date);
    }

    final cardIconColor = iconColor ?? (type == 'temuan' ? ThemeConstants.primary : ThemeConstants.secondary);
    final cardBackgroundColor = backgroundColor ?? ThemeConstants.backgroundWhite;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: ThemeConstants.cardDecoration.copyWith(
        color: cardBackgroundColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacingM),
                  decoration: BoxDecoration(
                    color: cardIconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  ),
                  child: Icon(
                    type == 'temuan' ? Icons.search_outlined : Icons.build_outlined,
                    color: cardIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cardIconColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count ${type == 'temuan' ? 'temuan' : 'perbaikan'} ditemukan',
                        style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardIconColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacingS),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: ThemeConstants.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
