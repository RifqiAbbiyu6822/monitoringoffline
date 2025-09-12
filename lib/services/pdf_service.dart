import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
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
  
  // Cache untuk logo yang sudah di-load
  static pw.Widget? _cachedLogo;
  
  // Method untuk memverifikasi asset logo
  static Future<bool> verifyLogoAsset() async {
    final List<String> assetPaths = [
      'lib/assets/logo_jjcnormal.png',
      'assets/logo_jjcnormal.png',
      'lib/assets/logoJJCWhite.png',
      'assets/logoJJCWhite.png',
    ];
    
    for (String path in assetPaths) {
      try {
        final ByteData logoData = await rootBundle.load(path);
        final Uint8List logoBytes = logoData.buffer.asUint8List();
        if (logoBytes.isNotEmpty) {
          print('✅ Logo asset ditemukan di: $path');
          return true;
        }
      } catch (e) {
        print('❌ Logo asset tidak ditemukan di: $path');
        continue;
      }
    }
    
    print('❌ Tidak ada logo asset yang ditemukan');
    return false;
  }

  Future<void> generateTemuanPdf(List<Temuan> temuanList, pdf_config.PdfConfig config, {String? dateRange, String? filterInfo}) async {
    try {
      final pdf = pw.Document();
      
      if (temuanList.isNotEmpty) {
        await _addPhotoGridPages(pdf, temuanList, config, 'TEMUAN', dateRange: dateRange, filterInfo: filterInfo);
      } else {
        await _addEmptyPage(pdf, config, 'TEMUAN', 'Tidak ada data temuan untuk diekspor', dateRange: dateRange, filterInfo: filterInfo);
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
        await _addEmptyPage(pdf, config, 'PERBAIKAN', 'Tidak ada data perbaikan untuk diekspor', dateRange: dateRange, filterInfo: filterInfo);
      }

      final fileName = dateRange != null 
          ? 'perbaikan_${dateRange}_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf'
          : 'perbaikan_${DateFormat(_fileNameFormat).format(DateTime.now())}.pdf';
      
      await _saveAndOpenPdf(pdf, fileName);
    } catch (e) {
      throw Exception('Gagal membuat PDF perbaikan: ${e.toString()}');
    }
  }

  Future<void> _addEmptyPage(pw.Document pdf, pdf_config.PdfConfig config, String type, String message, {String? dateRange, String? filterInfo}) async {
    final header = await _buildHeader(type, dateRange: dateRange, filterInfo: filterInfo);
    
    pdf.addPage(
      pw.Page(
        pageFormat: _getPageFormat(config),
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              header,
              pw.SizedBox(height: 60),
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

  Future<pw.Widget> _buildHeader(String type, {String? dateRange, String? filterInfo}) async {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(bottom: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header utama dengan logo dan judul
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo dan judul dalam kolom vertikal
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo dengan ukuran baru
                  pw.Container(
                    width: 120,
                    height: 120,
                    child: await _buildLogoWidget(),
                  ),
                  pw.SizedBox(height: 16),
                  
                  // Judul laporan dengan style baru
                  pw.Text(
                    type == 'TEMUAN' ? 'LAPORAN ANOMALI JALAN LAYANG MBZ' : 'LAPORAN PERBAIKAN JALAN LAYANG MBZ',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                ],
              ),

              // Informasi tanggal dan filter
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    DateFormat(_dateFormat).format(DateTime.now()),
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.blueGrey700,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (dateRange != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Periode: $dateRange',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.blueGrey600,
                      ),
                    ),
                  ],
                  if (filterInfo != null) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      filterInfo,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.blueGrey600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          // Garis pembatas sederhana
          pw.SizedBox(height: 20),
          pw.Container(
            height: 1,
            width: double.infinity,
            color: PdfColors.blueGrey300,
          ),
        ],
      ),
    );
  }

  Future<pw.Widget> _buildLogoWidget() async {
    // Gunakan cache jika sudah ada
    if (_cachedLogo != null) {
      return _cachedLogo!;
    }
    
    try {
      // Coba beberapa path asset yang mungkin
      final List<String> assetPaths = [
        'lib/assets/logo_jjcnormal.png',
        'assets/logo_jjcnormal.png',
        'lib/assets/logoJJCWhite.png',
        'assets/logoJJCWhite.png',
      ];
      
      for (String path in assetPaths) {
        try {
          final ByteData logoData = await rootBundle.load(path);
          final Uint8List logoBytes = logoData.buffer.asUint8List();
          
          if (logoBytes.isNotEmpty) {
            final logoWidget = pw.Image(
              pw.MemoryImage(logoBytes),
              fit: pw.BoxFit.contain,
            );
            // Cache logo yang berhasil di-load
            _cachedLogo = logoWidget;
            return logoWidget;
          }
        } catch (e) {
          // Lanjut ke path berikutnya
          continue;
        }
      }
      
      // Jika semua path gagal, coba dari file system
      for (String path in assetPaths) {
        try {
          final logoFile = File(path);
          if (await logoFile.exists()) {
            final imageBytes = await logoFile.readAsBytes();
            if (imageBytes.isNotEmpty) {
              final logoWidget = pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain,
              );
              // Cache logo yang berhasil di-load
              _cachedLogo = logoWidget;
              return logoWidget;
            }
          }
        } catch (e) {
          // Lanjut ke path berikutnya
          continue;
        }
      }
      
      // Jika semua gagal, gunakan placeholder dan cache
      final placeholder = _buildLogoPlaceholder();
      _cachedLogo = placeholder;
      return placeholder;
    } catch (e) {
      final placeholder = _buildLogoPlaceholder();
      _cachedLogo = placeholder;
      return placeholder;
    }
  }

  pw.Widget _buildLogoPlaceholder() {
    return pw.Container(
      width: 80,
      height: 80,
      child: pw.Center(
        child: pw.Text(
          'JJC',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey600,
          ),
        ),
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
          columnsPerRow = 2;
          break;
        case pdf_config.GridType.sixColumns:
          columnsPerRow = 2;
          break;
      }

      // Bagi data menjadi chunks untuk setiap halaman dengan maksimal 4 item per halaman
      final itemsPerPage = 4;
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
            photoWidgets.add(_buildPhotoPlaceholder('Error memuat item'));
          }
        }
        
        final header = await _buildHeader(type, dateRange: dateRange, filterInfo: filterInfo);
        
        pdf.addPage(
          pw.Page(
            pageFormat: _getPageFormat(config),
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  header,
                  pw.SizedBox(height: 30),
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
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15),
              child: photoWidgets[i + j],
            ),
          ),
        );
      }
      
      // Add spacers for incomplete rows
      while (rowItems.length < columnsPerRow) {
        rowItems.add(pw.Expanded(
          child: pw.Container(),
        ));
      }
      
      rows.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: rowItems,
        ),
      );
      
      if (i + columnsPerRow < photoWidgets.length) {
        rows.add(pw.SizedBox(height: 40));
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
              height: 180,
              width: double.infinity,
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
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header section dengan informasi utama
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              itemData['jenis'],
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
            pw.Text(
              itemData['tanggal'],
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.blueGrey600,
              ),
            ),
          ],
        ),
        
        pw.SizedBox(height: 12),
        
        // Photo section
        fotoWidget,
        
        pw.SizedBox(height: 16),
        
        // Information section dengan layout yang clean
        _buildItemInfo(itemData),
      ],
    );
  }

  pw.Widget _buildItemInfo(Map<String, dynamic> itemData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Location information
        pw.Text(
          'Lokasi: ${itemData['jalur']} - ${itemData['lajur']} (KM ${itemData['kilometer']})',
          style: pw.TextStyle(
            fontSize: 11,
            color: PdfColors.blueGrey700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        
        pw.SizedBox(height: 8),
        
        // Coordinates
        pw.Text(
          'Koordinat: ${itemData['latitude']}, ${itemData['longitude']}',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.blueGrey600,
          ),
        ),
        
        // Status (if available)
        if (itemData['statusPerbaikan'] != null) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            'Status: ${itemData['statusPerbaikan']}',
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.green700,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
        
        pw.SizedBox(height: 12),
        
        // Description
        pw.Text(
          'Deskripsi:',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          itemData['deskripsi'],
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.blueGrey700,
            height: 1.4,
          ),
          maxLines: 4,
          overflow: pw.TextOverflow.clip,
        ),
      ],
    );
  }

  pw.Widget _buildPhotoPlaceholder(String message) {
    return pw.Container(
      height: 180,
      width: double.infinity,
      color: PdfColors.grey100,
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              '📷',
              style: pw.TextStyle(
                fontSize: 24,
                color: PdfColors.grey400,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              message,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey500,
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