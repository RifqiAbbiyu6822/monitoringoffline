import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String itemName;
  final String itemType; // 'temuan' or 'perbaikan'

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.itemName,
    required this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeConstants.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConstants.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 32,
                color: ThemeConstants.errorRed,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Title
            Text(
              title,
              style: ThemeConstants.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingS),
            
            // Message
            Text(
              message,
              style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Item Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeConstants.spacingM),
              decoration: BoxDecoration(
                color: itemType == 'temuan' 
                    ? ThemeConstants.primary.withOpacity(0.1)
                    : ThemeConstants.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: itemType == 'temuan' 
                      ? ThemeConstants.primary.withOpacity(0.3)
                      : ThemeConstants.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    itemType == 'temuan' ? Icons.search_outlined : Icons.build_outlined,
                    color: itemType == 'temuan' ? ThemeConstants.primary : ThemeConstants.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      itemName,
                      style: ThemeConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: itemType == 'temuan' ? ThemeConstants.primary : ThemeConstants.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingS),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.errorRed,
                      foregroundColor: ThemeConstants.backgroundWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingS),
                    ),
                    child: const Text('Hapus', style: ThemeConstants.bodyMedium),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
