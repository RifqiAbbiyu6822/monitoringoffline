import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../models/pdf_config.dart' as pdf_config;

class PdfService {
  static const String _dateFormat = 'dd MMMM yyyy';
  static const String _fileNameFormat = 'yyyyMMdd';

  Future<void> generateTemuanPdf(List<Temuan> temuanList, pdf_config.PdfConfig config, {String? dateRange, String? filterInfo}) async {
    try {
      final pdf = pw.Document();
      
      if (temuanList.isNotEmpty) {
        await _addPhotoGridPages(pdf, temuanList, config, 'TEMUAN', dateRange: dateRange, filterInfo: filterInfo);
      } else {
        _addEmptyPage(pdf, config, 'TEMUAN', 'Tidak ada data temuan untuk diekspor', dateRange: dateRange, filterInfo: filterInfo);
      }

      final fileName = dateRange != null 
          ? 'temuan_${dateRange}_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf'
          : 'temuan_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf';
      
      await _saveAndOpenPdf(pdf, fileName);
    } catch (e) {
      throw Exception('Gagal membuat PDF temuan: ${e.toString()}');
    }
  }

  Future<void> generatePerbaikanPdf(List<Perbaikan> perbaikanList, pdf_config.PdfConfig config, {String? dateRange, String? filterInfo}) async {
    try {
      final pdf = pw.Document();
      
      if (perbaikanList.isNotEmpty) {
        await _addPhotoGridPages(pdf, perbaikanList, config, 'PERBAIKAN', dateRange: dateRange, filterInfo: filterInfo);
      } else {
        _addEmptyPage(pdf, config, 'PERBAIKAN', 'Tidak ada data perbaikan untuk diekspor', dateRange: dateRange, filterInfo: filterInfo);
      }

      final fileName = dateRange != null 
          ? 'perbaikan_${dateRange}_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf'
          : 'perbaikan_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf';
      
      await _saveAndOpenPdf(pdf, fileName);
    } catch (e) {
      throw Exception('Gagal membuat PDF perbaikan: ${e.toString()}');
    }
  }

  void _addEmptyPage(pw.Document pdf, pdf_config.PdfConfig config, String type, String message, {String? dateRange, String? filterInfo}) {
    pdf.addPage(
      pw.Page(
        pageFormat: _getPageFormat(config),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(type, dateRange: dateRange, filterInfo: filterInfo),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Center(
                  child: pw.Text(
                    message,
                    style: pw.TextStyle(fontSize: 16, color: PdfColors.grey600),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PdfPageFormat _getPageFormat(pdf_config.PdfConfig config) {
    return config.orientation == pdf_config.Orientation.portrait 
        ? PdfPageFormat.a4 
        : PdfPageFormat.a4.landscape;
  }

  pw.Widget _buildHeader(String type, {String? dateRange, String? filterInfo}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue200, width: 2),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Baris 1: Logo (placeholder untuk logo JJC)
          pw.Row(
            children: [
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue600,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'JJC',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 15),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'JASAMARGA',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    'JALAN LAYANG CIKAMPEK',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.blue600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          
          // Baris 2: Judul Laporan
          pw.Text(
            type == 'TEMUAN' ? 'LAPORAN TEMUAN JALAN LAYANG MBZ' : 'LAPORAN PERBAIKAN JALAN LAYANG MBZ',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          
          // Baris 3: Tanggal dan Filter
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Tanggal Laporan: ${DateFormat(_dateFormat).format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              if (dateRange != null) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Periode Data: $dateRange',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
              ],
              if (filterInfo != null) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Filter: $filterInfo',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }


  Future<void> _addPhotoGridPages(pw.Document pdf, List<dynamic> dataList, pdf_config.PdfConfig config, String type, {String? dateRange, String? filterInfo}) async {
    try {
      // Tentukan jumlah kolom berdasarkan grid type
      int columnsPerRow;
      switch (config.gridType) {
        case pdf_config.GridType.fullA4:
          columnsPerRow = 1;
          break;
        case pdf_config.GridType.twoColumns:
          columnsPerRow = 2;
          break;
        case pdf_config.GridType.fourColumns:
          columnsPerRow = 4;
          break;
      }

      // Bagi data menjadi chunks untuk setiap halaman
      final itemsPerPage = columnsPerRow * 2; // 2 baris per halaman
      final pages = <List<dynamic>>[];
      
      for (int i = 0; i < dataList.length; i += itemsPerPage) {
        final end = (i + itemsPerPage < dataList.length) ? i + itemsPerPage : dataList.length;
        pages.add(dataList.sublist(i, end));
      }

      // Buat halaman untuk setiap chunk
      for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
        final pageData = pages[pageIndex];
        
        // Pre-load semua gambar untuk halaman ini
        final photoWidgets = <pw.Widget>[];
        for (final item in pageData) {
          try {
            photoWidgets.add(await _buildPhotoItem(item, type));
          } catch (e) {
            // Jika ada error pada item tertentu, buat placeholder
            photoWidgets.add(_buildPhotoPlaceholder('Error memuat item'));
          }
        }
        
        pdf.addPage(
          pw.Page(
            pageFormat: _getPageFormat(config),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(type, dateRange: dateRange, filterInfo: filterInfo),
                pw.SizedBox(height: 20),
                  pw.Expanded(
                    child: _buildPhotoGridFromWidgets(photoWidgets, columnsPerRow),
                  ),
                ],
              );
            },
          ),
        );
      }
    } catch (e) {
      throw Exception('Gagal membuat halaman PDF: ${e.toString()}');
    }
  }

  pw.Widget _buildPhotoGridFromWidgets(List<pw.Widget> photoWidgets, int columnsPerRow) {
    final rows = <pw.Widget>[];
    
    for (int i = 0; i < photoWidgets.length; i += columnsPerRow) {
      final rowItems = <pw.Widget>[];
      
      for (int j = 0; j < columnsPerRow && (i + j) < photoWidgets.length; j++) {
        rowItems.add(
          pw.Expanded(
            child: photoWidgets[i + j],
          ),
        );
      }
      
      // Tambahkan spacer jika baris tidak penuh
      while (rowItems.length < columnsPerRow) {
        rowItems.add(pw.Expanded(child: pw.SizedBox()));
      }
      
      rows.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: rowItems,
        ),
      );
      
      if (i + columnsPerRow < photoWidgets.length) {
        rows.add(pw.SizedBox(height: 20));
      }
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  Future<pw.Widget> _buildPhotoItem(dynamic item, String type) async {
    final itemData = _extractItemData(item, type);
    final fotoWidget = await _buildFotoWidget(itemData['fotoPath']);
    
    return _buildPhotoContainer(fotoWidget, itemData);
  }

  Map<String, dynamic> _extractItemData(dynamic item, String type) {
    if (type == 'TEMUAN') {
      final temuan = item as Temuan;
      return {
        'fotoPath': temuan.fotoPath,
        'tanggal': DateFormat('dd/MM/yyyy').format(temuan.tanggal),
        'jenis': temuan.jenisTemuan,
        'jalur': temuan.jalur,
        'lajur': temuan.lajur,
        'kilometer': temuan.kilometer,
        'latitude': temuan.latitude,
        'longitude': temuan.longitude,
        'deskripsi': temuan.deskripsi,
        'statusPerbaikan': null,
      };
    } else {
      final perbaikan = item as Perbaikan;
      return {
        'fotoPath': perbaikan.fotoPath,
        'tanggal': DateFormat('dd/MM/yyyy').format(perbaikan.tanggal),
        'jenis': perbaikan.jenisPerbaikan,
        'jalur': perbaikan.jalur,
        'lajur': perbaikan.lajur,
        'kilometer': perbaikan.kilometer,
        'latitude': perbaikan.latitude,
        'longitude': perbaikan.longitude,
        'deskripsi': perbaikan.deskripsi,
        'statusPerbaikan': perbaikan.statusPerbaikan,
      };
    }
  }

  Future<pw.Widget> _buildFotoWidget(String? fotoPath) async {
    if (fotoPath != null && fotoPath.isNotEmpty) {
      try {
        final file = File(fotoPath);
        if (await file.exists()) {
          final imageBytes = await file.readAsBytes();
          if (imageBytes.isNotEmpty) {
            return pw.Container(
              height: 120,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.cover,
              ),
            );
          } else {
            return _buildPhotoPlaceholder('File foto kosong');
          }
        } else {
          return _buildPhotoPlaceholder('File tidak ditemukan');
        }
      } catch (e) {
        return _buildPhotoPlaceholder('Error memuat foto');
      }
    } else {
      return _buildPhotoPlaceholder('Tidak ada foto');
    }
  }

  pw.Widget _buildPhotoContainer(pw.Widget fotoWidget, Map<String, dynamic> itemData) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          fotoWidget,
          pw.SizedBox(height: 8),
          _buildItemInfo(itemData),
        ],
      ),
    );
  }

  pw.Widget _buildItemInfo(Map<String, dynamic> itemData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoText('Tanggal', itemData['tanggal'], isBold: true),
          _buildInfoText('Jenis', itemData['jenis']),
          _buildInfoText('Jalur', itemData['jalur']),
          _buildInfoText('Lajur', itemData['lajur']),
          _buildInfoText('Km', itemData['kilometer']),
          _buildInfoText('Lat', itemData['latitude']),
          _buildInfoText('Lng', itemData['longitude']),
          if (itemData['statusPerbaikan'] != null)
            _buildInfoText('Status', itemData['statusPerbaikan']),
          pw.SizedBox(height: 4),
          pw.Text(
            'Deskripsi:',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            itemData['deskripsi'],
            style: pw.TextStyle(fontSize: 8),
            maxLines: 3,
            overflow: pw.TextOverflow.clip,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoText(String label, String value, {bool isBold = false}) {
    return pw.Text(
      '$label: $value',
      style: pw.TextStyle(
        fontSize: 8,
        fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    );
  }

  pw.Widget _buildPhotoPlaceholder(String message) {
    return pw.Container(
      height: 120,
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey200,
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Icon(
              pw.IconData(0xe3b2), // camera_alt icon
              size: 30,
              color: PdfColors.grey600,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              message,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndOpenPdf(pw.Document pdf, String fileName) async {
    try {
      // Generate PDF bytes
      final pdfBytes = await pdf.save();
      
      if (pdfBytes.isEmpty) {
        throw Exception('PDF bytes kosong');
      }
      
      // Open PDF directly without saving to file
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: fileName,
      );
    } catch (e) {
      throw Exception('Gagal membuat PDF: ${e.toString()}');
    }
  }
}
