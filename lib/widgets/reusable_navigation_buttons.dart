import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class ReusableNavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onExport;
  final VoidCallback? onExportData;
  final VoidCallback? onFilter;
  final VoidCallback? onSort;
  final String? exportTooltip;
  final String? exportDataTooltip;
  final String? filterTooltip;
  final String? sortTooltip;
  final String? backTooltip;
  final Color? exportColor;
  final Color? exportDataColor;
  final Color? filterColor;
  final Color? sortColor;
  final Color? backColor;
  final bool showExport;
  final bool showExportData;
  final bool showFilter;
  final bool showSort;
  final bool showBack;

  const ReusableNavigationButtons({
    super.key,
    this.onBack,
    this.onExport,
    this.onExportData,
    this.onFilter,
    this.onSort,
    this.exportTooltip = 'Ekspor ke PDF',
    this.exportDataTooltip = 'Export Data',
    this.filterTooltip = 'Filter',
    this.sortTooltip = 'Sort',
    this.backTooltip = 'Kembali',
    this.exportColor = ThemeConstants.primary,
    this.exportDataColor = ThemeConstants.secondary,
    this.filterColor = ThemeConstants.warningOrange,
    this.sortColor = ThemeConstants.textSecondary,
    this.backColor = ThemeConstants.textSecondary,
    this.showExport = true,
    this.showExportData = false,
    this.showFilter = false,
    this.showSort = false,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showExport && onExport != null) ...[
            FloatingActionButton(
              heroTag: "export_pdf_${DateTime.now().millisecondsSinceEpoch}",
              onPressed: onExport,
              backgroundColor: exportColor,
              mini: true,
              child: const Icon(Icons.picture_as_pdf, color: ThemeConstants.backgroundWhite),
              tooltip: exportTooltip,
            ),
            const SizedBox(height: 8),
          ],
          
          if (showExportData && onExportData != null) ...[
            FloatingActionButton(
              heroTag: "export_data_${DateTime.now().millisecondsSinceEpoch}",
              onPressed: onExportData,
              backgroundColor: exportDataColor,
              mini: true,
              child: const Icon(Icons.file_download, color: ThemeConstants.backgroundWhite),
              tooltip: exportDataTooltip,
            ),
            const SizedBox(height: 8),
          ],
          
          if (showFilter && onFilter != null) ...[
            FloatingActionButton(
              heroTag: "filter_${DateTime.now().millisecondsSinceEpoch}",
              onPressed: onFilter,
              backgroundColor: filterColor,
              mini: true,
              child: const Icon(Icons.filter_list, color: ThemeConstants.backgroundWhite),
              tooltip: filterTooltip,
            ),
            const SizedBox(height: 8),
          ],
          
          if (showSort && onSort != null) ...[
            FloatingActionButton(
              heroTag: "sort_${DateTime.now().millisecondsSinceEpoch}",
              onPressed: onSort,
              backgroundColor: sortColor,
              mini: true,
              child: const Icon(Icons.sort, color: ThemeConstants.backgroundWhite),
              tooltip: sortTooltip,
            ),
            const SizedBox(height: 8),
          ],
          
          if (showBack && onBack != null) ...[
            FloatingActionButton(
              heroTag: "back_button_${DateTime.now().millisecondsSinceEpoch}",
              onPressed: onBack,
              backgroundColor: backColor,
              mini: true,
              child: const Icon(Icons.arrow_back, color: ThemeConstants.backgroundWhite),
              tooltip: backTooltip,
            ),
          ],
        ],
      ),
    );
  }
}
