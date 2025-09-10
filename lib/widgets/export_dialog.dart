import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../services/export_service.dart';
import '../utils/error_handler.dart';

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
      title: const Text(
        'Export Data',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Type Selection
            const Text(
              'Pilih Data:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Semua Data'),
              subtitle: Text('Temuan: ${widget.temuanList.length}, Perbaikan: ${widget.perbaikanList.length}'),
              value: 'all',
              groupValue: _selectedDataType,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedDataType = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Data Temuan'),
              subtitle: Text('${widget.temuanList.length} data'),
              value: 'temuan',
              groupValue: _selectedDataType,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedDataType = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Data Perbaikan'),
              subtitle: Text('${widget.perbaikanList.length} data'),
              value: 'perbaikan',
              groupValue: _selectedDataType,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedDataType = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Format Selection
            const Text(
              'Pilih Format:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('CSV'),
              subtitle: const Text('Format spreadsheet (Excel)'),
              value: 'csv',
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('JSON'),
              subtitle: const Text('Format data untuk integrasi sistem'),
              value: 'json',
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('TXT'),
              subtitle: const Text('Format teks yang mudah dibaca'),
              value: 'txt',
              groupValue: _selectedFormat,
              onChanged: _isExporting ? null : (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
            ),
            
            if (_selectedDataType == 'all') ...[
              RadioListTile<String>(
                title: const Text('ZIP'),
                subtitle: const Text('Semua format dalam satu file'),
                value: 'zip',
                groupValue: _selectedFormat,
                onChanged: _isExporting ? null : (value) {
                  setState(() {
                    _selectedFormat = value!;
                  });
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Export Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Export:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('• File akan disimpan di folder Documents'),
                  Text('• Nama file akan otomatis dengan timestamp'),
                  if (_selectedDataType == 'all' && _selectedFormat == 'zip')
                    const Text('• File ZIP berisi semua format data'),
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
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
          child: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Export Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Data berhasil diekspor ke:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                filePath,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'File dapat diakses melalui file manager di folder Documents.',
              style: TextStyle(fontSize: 12),
            ),
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
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
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
}
