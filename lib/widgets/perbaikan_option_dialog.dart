import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class PerbaikanOptionDialog extends StatelessWidget {
  const PerbaikanOptionDialog({super.key});

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
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeConstants.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.build_rounded,
                size: 32,
                color: ThemeConstants.secondary,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            
            Text(
              'Pilih Jenis Perbaikan',
              style: ThemeConstants.heading3,
            ),
            const SizedBox(height: ThemeConstants.spacingS),
            Text(
              'Pilih opsi yang sesuai dengan kebutuhan Anda',
              style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Option 1: Perbaikan Baru
            _buildOptionCard(
              context,
              icon: Icons.add_circle_outline,
              title: 'Perbaikan Baru',
              subtitle: 'Buat pencatatan perbaikan baru',
              color: ThemeConstants.secondary,
              onTap: () {
                Navigator.pop(context, 'new');
              },
            ),
            
            const SizedBox(height: ThemeConstants.spacingS),
            
            // Option 2: Lanjutkan Perbaikan
            _buildOptionCard(
              context,
              icon: Icons.edit_outlined,
              title: 'Lanjutkan Perbaikan',
              subtitle: 'Lanjutkan perbaikan yang belum selesai',
              color: ThemeConstants.primary,
              onTap: () {
                Navigator.pop(context, 'continue');
              },
            ),
            
            const SizedBox(height: ThemeConstants.spacingL),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
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
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ThemeConstants.spacingL),
          decoration: ThemeConstants.cardDecoration.copyWith(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeConstants.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: ThemeConstants.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeConstants.surfaceGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ThemeConstants.textSecondary,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
