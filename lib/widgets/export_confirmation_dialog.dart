import 'package:flutter/material.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../constants/theme_constants.dart';

class ExportConfirmationDialog extends StatelessWidget {
  final List<Temuan>? temuanList;
  final List<Perbaikan>? perbaikanList;
  final String exportType; // 'temuan' or 'perbaikan'
  final String? dateRange;
  final String? filterInfo;

  const ExportConfirmationDialog({
    super.key,
    this.temuanList,
    this.perbaikanList,
    required this.exportType,
    this.dateRange,
    this.filterInfo,
  });

  @override
  Widget build(BuildContext context) {
    final dataCount = exportType == 'temuan' 
        ? (temuanList?.length ?? 0)
        : (perbaikanList?.length ?? 0);
    
    final dataType = exportType == 'temuan' ? 'Temuan' : 'Perbaikan';
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
      ),
      title: Row(
        children: [
          Icon(
            Icons.picture_as_pdf,
            color: exportType == 'temuan' 
                ? ThemeConstants.primary 
                : ThemeConstants.secondary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Konfirmasi Export PDF',
            style: ThemeConstants.heading3,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Informasi data yang akan diekspor
            Container(
              padding: const EdgeInsets.all(ThemeConstants.spacingM),
              decoration: BoxDecoration(
                color: exportType == 'temuan' 
                    ? ThemeConstants.primary.withOpacity(0.1)
                    : ThemeConstants.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                border: Border.all(
                  color: exportType == 'temuan' 
                      ? ThemeConstants.primary.withOpacity(0.3)
                      : ThemeConstants.secondary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        exportType == 'temuan' ? Icons.search_outlined : Icons.build_outlined,
                        color: exportType == 'temuan' 
                            ? ThemeConstants.primary 
                            : ThemeConstants.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data $dataType',
                        style: ThemeConstants.heading3.copyWith(
                          color: exportType == 'temuan' 
                              ? ThemeConstants.primary 
                              : ThemeConstants.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$dataCount ${dataType.toLowerCase()} akan diekspor',
                    style: ThemeConstants.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Informasi tanggal
            if (dateRange != null) ...[
              _buildInfoRow('Periode', dateRange!, Icons.calendar_today),
              const SizedBox(height: ThemeConstants.spacingS),
            ],
            
            // Informasi filter
            if (filterInfo != null) ...[
              _buildInfoRow('Filter', filterInfo!, Icons.filter_list),
              const SizedBox(height: ThemeConstants.spacingS),
            ],
            
            // Informasi format
            _buildInfoRow('Format', 'PDF dengan foto dan detail', Icons.description),
            
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Peringatan jika tidak ada data
            if (dataCount == 0) ...[
              Container(
                padding: const EdgeInsets.all(ThemeConstants.spacingM),
                decoration: BoxDecoration(
                  color: ThemeConstants.warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  border: Border.all(
                    color: ThemeConstants.warningOrange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: ThemeConstants.warningOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tidak ada data $dataType untuk diekspor',
                        style: ThemeConstants.bodyMedium.copyWith(
                          color: ThemeConstants.warningOrange,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Batal',
            style: TextStyle(color: ThemeConstants.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: dataCount > 0 
              ? () => Navigator.of(context).pop(true)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: exportType == 'temuan' 
                ? ThemeConstants.primary 
                : ThemeConstants.secondary,
            foregroundColor: ThemeConstants.backgroundWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
          ),
          child: const Text('Export PDF'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ThemeConstants.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: ThemeConstants.bodySmall.copyWith(
            color: ThemeConstants.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: ThemeConstants.bodySmall,
          ),
        ),
      ],
    );
  }
}
