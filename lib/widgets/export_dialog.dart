import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../services/export_service.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_config_dialog.dart';
import '../utils/error_handler.dart';
import '../constants/theme_constants.dart';

class ExportDialog extends StatefulWidget {
  final List<Temuan> temuanList;
  final List<Perbaikan> perbaikanList;

  const ExportDialog({
    super.key,
    required this.temuanList,
    required this.perbaikanList,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _isExporting = false;
  String _selectedFormat = 'csv';
  String _selectedDataType = 'all';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ThemeConstants.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
      ),
      title: const Text(
        'Export Data',
        style: ThemeConstants.heading3,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Type Selection
            const Text('Pilih Data:', style: ThemeConstants.bodyLarge),
            const SizedBox(height: ThemeConstants.spacingS),
            RadioListTile<String>(
              title: const Text('Semua Data', style: ThemeConstants.bodyMedium),
              subtitle: Text('Temuan: ${widget.temuanList.length}, Perbaikan: ${widget.perbaikanList.length}'),
              value: 'all',
              groupValue: _selectedDataType,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedDataType = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
            RadioListTile<String>(
              title: const Text('Data Temuan', style: ThemeConstants.bodyMedium),
              subtitle: Text('${widget.temuanList.length} data'),
              value: 'temuan',
              groupValue: _selectedDataType,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedDataType = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
            RadioListTile<String>(
              title: const Text('Data Perbaikan', style: ThemeConstants.bodyMedium),
              subtitle: Text('${widget.perbaikanList.length} data'),
              value: 'perbaikan',
              groupValue: _selectedDataType,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedDataType = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
            
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Format Selection
            const Text('Pilih Format:', style: ThemeConstants.bodyLarge),
            const SizedBox(height: ThemeConstants.spacingS),
            RadioListTile<String>(
              title: const Text('CSV', style: ThemeConstants.bodyMedium),
              subtitle: const Text('Format spreadsheet (Excel)', style: ThemeConstants.bodySmall),
              value: 'csv',
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
            RadioListTile<String>(
              title: const Text('JSON', style: ThemeConstants.bodyMedium),
              subtitle: const Text('Format data untuk integrasi sistem', style: ThemeConstants.bodySmall),
              value: 'json',
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
            RadioListTile<String>(
              title: const Text('TXT', style: ThemeConstants.bodyMedium),
              subtitle: const Text('Format teks yang mudah dibaca', style: ThemeConstants.bodySmall),
              value: 'txt',
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
            RadioListTile<String>(
              title: const Text('PDF', style: ThemeConstants.bodyMedium),
              subtitle: const Text('Format dokumen dengan foto dan layout', style: ThemeConstants.bodySmall),
              value: 'pdf',
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              activeColor: ThemeConstants.primary,
            ),
            
            if (_selectedDataType == 'all') ...[
              RadioListTile<String>(
                title: const Text('ZIP', style: ThemeConstants.bodyMedium),
                subtitle: const Text('Semua format dalam satu file', style: ThemeConstants.bodySmall),
                value: 'zip',
                groupValue: _selectedFormat,
                onChanged: _isExporting ? null : (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
                activeColor: ThemeConstants.primary,
              ),
            ],
            
            const SizedBox(height: ThemeConstants.spacingM),
            
            // Export Info
            Container(
              padding: const EdgeInsets.all(ThemeConstants.spacingM),
              decoration: BoxDecoration(
                color: ThemeConstants.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                border: Border.all(color: ThemeConstants.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Export:', style: ThemeConstants.bodyLarge),
                  const SizedBox(height: ThemeConstants.spacingXS),
                  const Text('• File akan disimpan di folder Documents', style: ThemeConstants.bodySmall),
                  const Text('• Nama file akan otomatis dengan timestamp', style: ThemeConstants.bodySmall),
                  if (_selectedDataType == 'all' && _selectedFormat == 'zip')
                    const Text('• File ZIP berisi semua format data', style: ThemeConstants.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportData,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConstants.secondary,
            foregroundColor: ThemeConstants.backgroundWhite,
          ),
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.backgroundWhite),
                  ),
                )
              : const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      String filePath;
      
      switch (_selectedDataType) {
        case 'temuan':
          filePath = await _exportTemuanData();
          break;
        case 'perbaikan':
          filePath = await _exportPerbaikanData();
          break;
        case 'all':
        default:
          filePath = await _exportAllData();
          break;
      }

      if (mounted) {
        Navigator.of(context).pop();
        _showExportSuccessDialog(filePath);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'Gagal export data');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<String> _exportTemuanData() async {
    switch (_selectedFormat) {
      case 'csv':
        return await ExportService.exportTemuanToCsv(widget.temuanList);
      case 'json':
        return await ExportService.exportTemuanToJson(widget.temuanList);
      case 'txt':
        return await ExportService.exportTemuanToTxt(widget.temuanList);
      case 'pdf':
        return await _exportTemuanToPdf();
      default:
        throw Exception('Format tidak didukung');
    }
  }

  Future<String> _exportPerbaikanData() async {
    switch (_selectedFormat) {
      case 'csv':
        return await ExportService.exportPerbaikanToCsv(widget.perbaikanList);
      case 'json':
        return await ExportService.exportPerbaikanToJson(widget.perbaikanList);
      case 'txt':
        return await ExportService.exportPerbaikanToTxt(widget.perbaikanList);
      case 'pdf':
        return await _exportPerbaikanToPdf();
      default:
        throw Exception('Format tidak didukung');
    }
  }

  Future<String> _exportAllData() async {
    if (_selectedFormat == 'zip') {
      return await ExportService.exportAllDataToZip(
        temuanList: widget.temuanList,
        perbaikanList: widget.perbaikanList,
      );
    } else {
      // Export both types in selected format
      final temuanPath = await _exportTemuanData();
      final perbaikanPath = await _exportPerbaikanData();
      return '$temuanPath, $perbaikanPath';
    }
  }

  void _showExportSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConstants.backgroundWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.radiusL)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: ThemeConstants.successGreen),
            SizedBox(width: 8),
            Text('Export Berhasil', style: ThemeConstants.heading3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data berhasil diekspor ke:', style: ThemeConstants.bodyMedium),
            const SizedBox(height: ThemeConstants.spacingS),
            Container(
              padding: const EdgeInsets.all(ThemeConstants.spacingS),
              decoration: BoxDecoration(
                color: ThemeConstants.surfaceGrey,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
              ),
              child: Text(
                filePath,
                style: ThemeConstants.bodySmall,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingS),
            const Text('File dapat diakses melalui file manager di folder Documents.', style: ThemeConstants.bodySmall),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyPathToClipboard(filePath);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primary,
              foregroundColor: ThemeConstants.backgroundWhite,
            ),
            child: const Text('Copy Path'),
          ),
        ],
      ),
    );
  }

  void _copyPathToClipboard(String path) {
    Clipboard.setData(ClipboardData(text: path));
    ErrorHandler.showSuccessSnackBar(context, 'Path berhasil disalin ke clipboard');
  }

  Future<String> _exportTemuanToPdf() async {
    // Tampilkan dialog konfigurasi PDF
    final config = await showDialog<pdf_config.PdfConfig>(
      context: context,
      builder: (context) => const PdfConfigDialog(),
    );

    if (config == null) {
      throw Exception('Konfigurasi PDF dibatalkan');
    }

    // Generate PDF
    await PdfService().generateTemuanPdf(
      widget.temuanList, 
      config,
      dateRange: 'Export dari History',
      filterInfo: '${widget.temuanList.length} data temuan',
    );

    return 'PDF Temuan berhasil dibuat';
  }

  Future<String> _exportPerbaikanToPdf() async {
    // Tampilkan dialog konfigurasi PDF
    final config = await showDialog<pdf_config.PdfConfig>(
      context: context,
      builder: (context) => const PdfConfigDialog(),
    );

    if (config == null) {
      throw Exception('Konfigurasi PDF dibatalkan');
    }

    // Generate PDF
    await PdfService().generatePerbaikanPdf(
      widget.perbaikanList, 
      config,
      dateRange: 'Export dari History',
      filterInfo: '${widget.perbaikanList.length} data perbaikan',
    );

    return 'PDF Perbaikan berhasil dibuat';
  }
}
