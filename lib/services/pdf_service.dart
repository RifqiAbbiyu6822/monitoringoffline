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
  Future<void> generateTemuanPdf(List<Temuan> temuanList, pdf_config.PdfConfig config) async {
    final pdf = pw.Document();
    
    // Header
    final header = pw.Header(
      level: 0,
      child: pw.Text(
        'LAPORAN TEMUAN JALAN TOL MBZ',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );

    // Date info
    final dateInfo = pw.Text(
      'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
      style: const pw.TextStyle(fontSize: 12),
    );

    // Tampilkan grid foto untuk semua data (dengan atau tanpa foto)
    if (temuanList.isNotEmpty) {
      await _addPhotoGridPages(pdf, temuanList, config, 'TEMUAN');
    } else {
      // Jika tidak ada data sama sekali, tampilkan halaman kosong
      pdf.addPage(
        pw.Page(
          pageFormat: config.orientation == pdf_config.Orientation.portrait 
              ? PdfPageFormat.a4 
              : PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                header,
                pw.SizedBox(height: 20),
                dateInfo,
                pw.SizedBox(height: 20),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      'Tidak ada data temuan untuk tanggal ini',
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

    // Save and open PDF
    await _saveAndOpenPdf(pdf, 'temuan_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
  }

  Future<void> generatePerbaikanPdf(List<Perbaikan> perbaikanList, pdf_config.PdfConfig config) async {
    final pdf = pw.Document();
    
    // Header
    final header = pw.Header(
      level: 0,
      child: pw.Text(
        'LAPORAN PERBAIKAN JALAN TOL MBZ',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );

    // Date info
    final dateInfo = pw.Text(
      'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
      style: const pw.TextStyle(fontSize: 12),
    );

    // Tampilkan grid foto untuk semua data (dengan atau tanpa foto)
    if (perbaikanList.isNotEmpty) {
      await _addPhotoGridPages(pdf, perbaikanList, config, 'PERBAIKAN');
    } else {
      // Jika tidak ada data sama sekali, tampilkan halaman kosong
      pdf.addPage(
        pw.Page(
          pageFormat: config.orientation == pdf_config.Orientation.portrait 
              ? PdfPageFormat.a4 
              : PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                header,
                pw.SizedBox(height: 20),
                dateInfo,
                pw.SizedBox(height: 20),
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      'Tidak ada data perbaikan untuk tanggal ini',
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

    // Save and open PDF
    await _saveAndOpenPdf(pdf, 'perbaikan_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
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
          pageFormat: config.orientation == pdf_config.Orientation.portrait 
              ? PdfPageFormat.a4 
              : PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  'LAPORAN $type JALAN TOL MBZ',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 10),
                
                // Date info
                pw.Text(
                  'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                
                // Grid foto
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
    String? fotoPath;
    String tanggal;
    String jenis;
    String jalur;
    String lajur;
    String kilometer;
    String latitude;
    String longitude;
    String deskripsi;
    String? statusPerbaikan;

    if (type == 'TEMUAN') {
      final temuan = item as Temuan;
      fotoPath = temuan.fotoPath;
      tanggal = DateFormat('dd/MM/yyyy').format(temuan.tanggal);
      jenis = temuan.jenisTemuan;
      jalur = temuan.jalur;
      lajur = temuan.lajur;
      kilometer = temuan.kilometer;
      latitude = temuan.latitude;
      longitude = temuan.longitude;
      deskripsi = temuan.deskripsi;
    } else {
      final perbaikan = item as Perbaikan;
      fotoPath = perbaikan.fotoPath;
      tanggal = DateFormat('dd/MM/yyyy').format(perbaikan.tanggal);
      jenis = perbaikan.jenisPerbaikan;
      jalur = perbaikan.jalur;
      lajur = perbaikan.lajur;
      kilometer = perbaikan.kilometer;
      latitude = perbaikan.latitude;
      longitude = perbaikan.longitude;
      deskripsi = perbaikan.deskripsi;
      statusPerbaikan = perbaikan.statusPerbaikan;
    }

    // Cek apakah file foto ada dan bisa dibaca
    pw.Widget fotoWidget;
    if (fotoPath != null && fotoPath.isNotEmpty) {
      try {
        final file = File(fotoPath);
        if (await file.exists()) {
          final imageBytes = await file.readAsBytes();
          fotoWidget = pw.Container(
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
          // File tidak ada, tampilkan placeholder
          fotoWidget = _buildPhotoPlaceholder('File tidak ditemukan');
        }
      } catch (e) {
        // Error membaca file, tampilkan placeholder
        fotoWidget = _buildPhotoPlaceholder('Error: ${e.toString()}');
      }
    } else {
      // Tidak ada path foto, tampilkan placeholder
      fotoWidget = _buildPhotoPlaceholder('Tidak ada foto');
    }

    return pw.Container(
      margin: const pw.EdgeInsets.all(5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Foto atau Placeholder
          fotoWidget,
          
          pw.SizedBox(height: 8),
          
          // Keterangan
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Tanggal: $tanggal',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Jenis: $jenis',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Jalur: $jalur',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Lajur: $lajur',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Km: $kilometer',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Lat: $latitude',
                  style: pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Lng: $longitude',
                  style: pw.TextStyle(fontSize: 8),
                ),
                if (statusPerbaikan != null)
                  pw.Text(
                    'Status: $statusPerbaikan',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Deskripsi:',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  deskripsi,
                  style: pw.TextStyle(fontSize: 8),
                  maxLines: 3,
                  overflow: pw.TextOverflow.clip,
                ),
              ],
            ),
          ),
        ],
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
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    // Open PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }
}
