import 'package:flutter/material.dart';
import '../models/pdf_config.dart' as pdf_config;

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
      title: const Text(
        'Konfigurasi PDF',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipe Grid
            const Text(
              'Tipe Grid:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
            
            const SizedBox(height: 20),
            
            // Orientasi
            const Text(
              'Orientasi:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
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
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGridType = gridType;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedGridType == gridType
                  ? Colors.blue[600]!
                  : Colors.grey[300]!,
              width: _selectedGridType == gridType ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _selectedGridType == gridType
                ? Colors.blue[50]
                : Colors.white,
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
                activeColor: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedGridType == gridType
                            ? Colors.blue[800]
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOrientation = orientation;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedOrientation == orientation
                  ? Colors.blue[600]!
                  : Colors.grey[300]!,
              width: _selectedOrientation == orientation ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: _selectedOrientation == orientation
                ? Colors.blue[50]
                : Colors.white,
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
                activeColor: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedOrientation == orientation
                            ? Colors.blue[800]
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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
