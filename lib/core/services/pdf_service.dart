import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  Future<File?> generateTemuanPdf({
    required List<Map<String, dynamic>> temuanList,
    required String date,
    required int layout, // 1x1=1, 1x2=2, 2x2=4, 2x3=6
  }) async {
    try {
      final pdf = pw.Document();
      final DateFormat dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
      final DateFormat timeFormat = DateFormat('HH:mm:ss', 'id_ID');

      // Load images and create pages based on layout
      for (int i = 0; i < temuanList.length; i += layout) {
        final pageItems = temuanList.skip(i).take(layout).toList();
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue900,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'LAPORAN TEMUAN HARIAN',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Tanggal: ${dateFormat.format(DateTime.parse(date))}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  // Content based on layout
                  pw.Expanded(
                    child: _buildLayoutContent(pageItems, layout),
                  ),
                  
                  // Footer
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.symmetric(vertical: 10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey400),
                      ),
                    ),
                    child: pw.Text(
                      'Halaman ${(i ~/ layout) + 1} - Monitoring Jalan Layang MBZ',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Save PDF
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'Temuan_${date.replaceAll('-', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = path.join(appDir.path, 'reports', fileName);
      
      // Create reports directory if it doesn't exist
      final Directory reportsDir = Directory(path.join(appDir.path, 'reports'));
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  pw.Widget _buildLayoutContent(List<Map<String, dynamic>> items, int layout) {
    switch (layout) {
      case 1: // 1x1
        return _build1x1Layout(items);
      case 2: // 1x2
        return _build1x2Layout(items);
      case 4: // 2x2
        return _build2x2Layout(items);
      case 6: // 2x3
        return _build2x3Layout(items);
      default:
        return _build1x1Layout(items);
    }
  }

  pw.Widget _build1x1Layout(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return pw.Container();
    
    final item = items.first;
    return pw.Column(
      children: [
        pw.Expanded(
          child: _buildTemuanCard(item, large: true),
        ),
      ],
    );
  }

  pw.Widget _build1x2Layout(List<Map<String, dynamic>> items) {
    return pw.Column(
      children: items.map((item) => pw.Expanded(
        child: pw.Container(
          margin: pw.EdgeInsets.only(bottom: 10),
          child: _buildTemuanCard(item),
        ),
      )).toList(),
    );
  }

  pw.Widget _build2x2Layout(List<Map<String, dynamic>> items) {
    List<pw.Widget> rows = [];
    
    for (int i = 0; i < items.length; i += 2) {
      List<pw.Widget> rowItems = [];
      
      // First item in row
      rowItems.add(pw.Expanded(
        child: pw.Container(
          margin: pw.EdgeInsets.only(right: 5),
          child: _buildTemuanCard(items[i]),
        ),
      ));
      
      // Second item in row (if exists)
      if (i + 1 < items.length) {
        rowItems.add(pw.Expanded(
          child: pw.Container(
            margin: pw.EdgeInsets.only(left: 5),
            child: _buildTemuanCard(items[i + 1]),
          ),
        ));
      } else {
        rowItems.add(pw.Expanded(child: pw.Container()));
      }
      
      rows.add(pw.Expanded(
        child: pw.Container(
          margin: pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(children: rowItems),
        ),
      ));
    }
    
    return pw.Column(children: rows);
  }

  pw.Widget _build2x3Layout(List<Map<String, dynamic>> items) {
    List<pw.Widget> rows = [];
    
    for (int i = 0; i < items.length; i += 2) {
      List<pw.Widget> rowItems = [];
      
      // First item in row
      rowItems.add(pw.Expanded(
        child: pw.Container(
          margin: pw.EdgeInsets.only(right: 5),
          child: _buildTemuanCard(items[i], compact: true),
        ),
      ));
      
      // Second item in row (if exists)
      if (i + 1 < items.length) {
        rowItems.add(pw.Expanded(
          child: pw.Container(
            margin: pw.EdgeInsets.only(left: 5),
            child: _buildTemuanCard(items[i + 1], compact: true),
          ),
        ));
      } else {
        rowItems.add(pw.Expanded(child: pw.Container()));
      }
      
      rows.add(pw.Expanded(
        child: pw.Container(
          margin: pw.EdgeInsets.only(bottom: 5),
          child: pw.Row(children: rowItems),
        ),
      ));
    }
    
    return pw.Column(children: rows);
  }

  pw.Widget _buildTemuanCard(Map<String, dynamic> temuan, {bool large = false, bool compact = false}) {
    final DateFormat timeFormat = DateFormat('HH:mm:ss', 'id_ID');
    final DateTime timestamp = DateTime.parse(temuan['timestamp']);
    
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(compact ? 8 : 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Image placeholder (in real implementation, load actual image)
          pw.Expanded(
            flex: large ? 3 : 2,
            child: pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Center(
                child: pw.Text(
                  'FOTO TEMUAN',
                  style: pw.TextStyle(
                    fontSize: compact ? 8 : 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ),
          ),
          pw.SizedBox(height: compact ? 5 : 8),
          
          // Description
          pw.Text(
            temuan['deskripsi'] ?? '',
            style: pw.TextStyle(
              fontSize: compact ? 9 : 11,
              fontWeight: pw.FontWeight.bold,
            ),
            maxLines: compact ? 2 : 3,
          ),
          pw.SizedBox(height: compact ? 3 : 5),
          
          // Location and time
          pw.Text(
            'Lokasi: ${temuan['latitude']?.toStringAsFixed(6) ?? ''}, ${temuan['longitude']?.toStringAsFixed(6) ?? ''}',
            style: pw.TextStyle(fontSize: compact ? 7 : 8, color: PdfColors.grey600),
            maxLines: 1,
          ),
          pw.Text(
            'Waktu: ${timeFormat.format(timestamp)}',
            style: pw.TextStyle(fontSize: compact ? 7 : 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  Future<File?> generatePerbaikanPdf({
    required Map<String, dynamic> perbaikan,
    required List<Map<String, dynamic>> fotoList,
    required int layout,
  }) async {
    try {
      final pdf = pw.Document();
      final DateFormat dateFormat = DateFormat('dd MMMM yyyy HH:mm', 'id_ID');

      // Group photos by progress
      Map<int, List<Map<String, dynamic>>> fotoByProgress = {};
      for (var foto in fotoList) {
        int progres = foto['progres'] ?? 0;
        if (!fotoByProgress.containsKey(progres)) {
          fotoByProgress[progres] = [];
        }
        fotoByProgress[progres]!.add(foto);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN PROYEK PERBAIKAN',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      perbaikan['nama_proyek'] ?? '',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.yellow,
                      ),
                    ),
                    if (perbaikan['deskripsi'] != null && perbaikan['deskripsi'].isNotEmpty)
                      pw.Padding(
                        padding: pw.EdgeInsets.only(top: 5),
                        child: pw.Text(
                          perbaikan['deskripsi'],
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Progress sections
              ...fotoByProgress.entries.map((entry) {
                int progres = entry.key;
                List<Map<String, dynamic>> fotos = entry.value;
                
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.yellow,
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        'PROGRES ${progres}%',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    
                    // Photos grid
                    ...fotos.map((foto) => pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 15),
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Image placeholder
                          pw.Container(
                            width: double.infinity,
                            height: 200,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey200,
                              borderRadius: pw.BorderRadius.circular(3),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'FOTO PROGRES ${progres}%',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          
                          if (foto['deskripsi'] != null && foto['deskripsi'].isNotEmpty)
                            pw.Text(
                              foto['deskripsi'],
                              style: pw.TextStyle(fontSize: 11),
                            ),
                          
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'Lokasi: ${foto['latitude']?.toStringAsFixed(6) ?? ''}, ${foto['longitude']?.toStringAsFixed(6) ?? ''}',
                            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                          pw.Text(
                            'Waktu: ${dateFormat.format(DateTime.parse(foto['timestamp']))}',
                            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    )).toList(),
                    
                    pw.SizedBox(height: 20),
                  ],
                );
              }).toList(),
            ];
          },
        ),
      );

      // Save PDF
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'Perbaikan_${perbaikan['nama_proyek']?.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = path.join(appDir.path, 'reports', fileName);
      
      // Create reports directory if it doesn't exist
      final Directory reportsDir = Directory(path.join(appDir.path, 'reports'));
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      print('Error generating Perbaikan PDF: $e');
      return null;
    }
  }
}
