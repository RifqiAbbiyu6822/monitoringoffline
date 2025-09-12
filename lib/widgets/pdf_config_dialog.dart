import 'package:flutter/material.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../constants/theme_constants.dart';

class PdfConfigDialog extends StatefulWidget {
  const PdfConfigDialog({super.key});

  @override
  State<PdfConfigDialog> createState() => _PdfConfigDialogState();
}

class _PdfConfigDialogState extends State<PdfConfigDialog> {
  pdf_config.GridType _selectedGridType = pdf_config.GridType.fullA4;
  pdf_config.Orientation _selectedOrientation = pdf_config.Orientation.portrait;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeConstants.backgroundWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusL)),
      title: const Text('Konfigurasi PDF', style: ThemeConstants.heading3),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipe Grid
            const Text('Tipe Grid:', style: ThemeConstants.bodyLarge),
            const SizedBox(height: ThemeConstants.spacingS),
            _buildGridTypeOption(
              pdf_config.GridType.fullA4,
              'Full A4',
              'Layout tabel penuh satu halaman A4',
            ),
            _buildGridTypeOption(
              pdf_config.GridType.twoColumns,
              '2 Kolom',
              'Layout tabel dengan 2 kolom',
            ),
            _buildGridTypeOption(
              pdf_config.GridType.fourColumns,
              '4 Kolom',
              'Layout tabel dengan 4 kolom',
            ),
            _buildGridTypeOption(
              pdf_config.GridType.sixColumns,
              '6 Kolom',
              'Layout tabel dengan 6 gambar per halaman (3x2)',
            ),
            
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Orientasi
            const Text('Orientasi:', style: ThemeConstants.bodyLarge),
            const SizedBox(height: ThemeConstants.spacingS),
            _buildOrientationOption(
              pdf_config.Orientation.portrait,
              'Potret',
              'Orientasi vertikal',
            ),
            _buildOrientationOption(
              pdf_config.Orientation.landscape,
              'Lanskap',
              'Orientasi horizontal',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            final config = pdf_config.PdfConfig(
              gridType: _selectedGridType,
              orientation: _selectedOrientation,
            );
            Navigator.of(context).pop(config);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConstants.primary,
            foregroundColor: ThemeConstants.backgroundWhite,
          ),
          child: const Text('Generate PDF'),
        ),
      ],
    );
  }

  Widget _buildGridTypeOption(
    pdf_config.GridType gridType,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.spacingS),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGridType = gridType;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedGridType == gridType
                  ? ThemeConstants.primary
                  : ThemeConstants.textSecondary.withOpacity(0.3),
              width: _selectedGridType == gridType ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            color: _selectedGridType == gridType
                ? ThemeConstants.primary.withOpacity(0.05)
                : ThemeConstants.backgroundWhite,
          ),
          child: Row(
            children: [
              Radio<pdf_config.GridType>(
                value: gridType,
                groupValue: _selectedGridType,
                onChanged: (value) {
                  setState(() {
                    _selectedGridType = value!;
                  });
                },
                activeColor: ThemeConstants.primary,
              ),
              const SizedBox(width: ThemeConstants.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _selectedGridType == gridType
                            ? ThemeConstants.primary
                            : ThemeConstants.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: ThemeConstants.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrientationOption(
    pdf_config.Orientation orientation,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ThemeConstants.spacingS),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOrientation = orientation;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedOrientation == orientation
                  ? ThemeConstants.primary
                  : ThemeConstants.textSecondary.withOpacity(0.3),
              width: _selectedOrientation == orientation ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            color: _selectedOrientation == orientation
                ? ThemeConstants.primary.withOpacity(0.05)
                : ThemeConstants.backgroundWhite,
          ),
          child: Row(
            children: [
              Radio<pdf_config.Orientation>(
                value: orientation,
                groupValue: _selectedOrientation,
                onChanged: (value) {
                  setState(() {
                    _selectedOrientation = value!;
                  });
                },
                activeColor: ThemeConstants.primary,
              ),
              const SizedBox(width: ThemeConstants.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _selectedOrientation == orientation
                            ? ThemeConstants.primary
                            : ThemeConstants.textPrimary,
                      ),
                    ),
                    Text(
                      description,
                      style: ThemeConstants.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
