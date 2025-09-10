import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../models/pdf_config.dart' as pdf_config;

class PdfService {
  static const String _appTitle = 'LAPORAN JALAN TOL MBZ';
  static const String _dateFormat = 'dd MMMM yyyy';
  static const String _fileNameFormat = 'yyyyMMdd';

  Future<void> generateTemuanPdf(List<Temuan> temuanList, pdf_config.PdfConfig config) async {
    final pdf = pw.Document();
    
    if (temuanList.isNotEmpty) {
      await _addPhotoGridPages(pdf, temuanList, config, 'TEMUAN');
    } else {
      _addEmptyPage(pdf, config, 'TEMUAN', 'Tidak ada data temuan untuk tanggal ini');
    }

    await _saveAndOpenPdf(pdf, 'temuan_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf');
  }

  Future<void> generatePerbaikanPdf(List<Perbaikan> perbaikanList, pdf_config.PdfConfig config) async {
    final pdf = pw.Document();
    
    if (perbaikanList.isNotEmpty) {
      await _addPhotoGridPages(pdf, perbaikanList, config, 'PERBAIKAN');
    } else {
      _addEmptyPage(pdf, config, 'PERBAIKAN', 'Tidak ada data perbaikan untuk tanggal ini');
    }

    await _saveAndOpenPdf(pdf, 'perbaikan_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf');
  }

  void _addEmptyPage(pw.Document pdf, pdf_config.PdfConfig config, String type, String message) {
    pdf.addPage(
      pw.Page(
        pageFormat: _getPageFormat(config),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(type),
              pw.SizedBox(height: 20),
              _buildDateInfo(),
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

  pw.Widget _buildHeader(String type) {
    return pw.Header(
      level: 0,
      child: pw.Text(
        '$_appTitle $type',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildDateInfo() {
    return pw.Text(
      'Tanggal: ${DateFormat(_dateFormat).format(DateTime.now())}',
      style: const pw.TextStyle(fontSize: 12),
    );
  }

  Future<void> _addPhotoGridPages(pw.Document pdf, List<dynamic> dataList, pdf_config.PdfConfig config, String type) async {
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
        photoWidgets.add(await _buildPhotoItem(item, type));
      }
      
      pdf.addPage(
        pw.Page(
          pageFormat: _getPageFormat(config),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(type),
                pw.SizedBox(height: 10),
                _buildDateInfo(),
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
          return _buildPhotoPlaceholder('File tidak ditemukan');
        }
      } catch (e) {
        return _buildPhotoPlaceholder('Error: ${e.toString()}');
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
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      // Open PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: fileName,
      );
    } catch (e) {
      throw Exception('Gagal menyimpan atau membuka PDF: $e');
    }
  }
}
