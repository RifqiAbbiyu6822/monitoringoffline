import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../utils/date_utils.dart';

class ExportService {
  static const String _dateFormat = 'yyyyMMdd_HHmmss';

  /// Export data temuan ke CSV
  static Future<String> exportTemuanToCsv(List<Temuan> temuanList) async {
    try {
      final List<List<dynamic>> csvData = [];
      
      // Header
      csvData.add([
        'ID',
        'Tanggal',
        'Jenis Temuan',
        'Jalur',
        'Lajur',
        'Kilometer',
        'Latitude',
        'Longitude',
        'Deskripsi',
        'Foto Path',
      ]);

      // Data
      for (final temuan in temuanList) {
        csvData.add([
          temuan.id,
          AppDateUtils.formatDisplayDate(temuan.tanggal),
          temuan.jenisTemuan,
          temuan.jalur,
          temuan.lajur,
          temuan.kilometer,
          temuan.latitude,
          temuan.longitude,
          temuan.deskripsi,
          temuan.fotoPath ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      final fileName = 'temuan_${DateFormat(_dateFormat).format(DateTime.now())}.csv';
      
      return await _saveFile(fileName, csvString);
    } catch (e) {
      throw Exception('Gagal export data temuan ke CSV: $e');
    }
  }

  /// Export data perbaikan ke CSV
  static Future<String> exportPerbaikanToCsv(List<Perbaikan> perbaikanList) async {
    try {
      final List<List<dynamic>> csvData = [];
      
      // Header
      csvData.add([
        'ID',
        'Tanggal',
        'Jenis Perbaikan',
        'Jalur',
        'Lajur',
        'Kilometer',
        'Latitude',
        'Longitude',
        'Deskripsi',
        'Status Perbaikan',
        'Foto Path',
      ]);

      // Data
      for (final perbaikan in perbaikanList) {
        csvData.add([
          perbaikan.id,
          AppDateUtils.formatDisplayDate(perbaikan.tanggal),
          perbaikan.jenisPerbaikan,
          perbaikan.jalur,
          perbaikan.lajur,
          perbaikan.kilometer,
          perbaikan.latitude,
          perbaikan.longitude,
          perbaikan.deskripsi,
          perbaikan.statusPerbaikan,
          perbaikan.fotoPath ?? '',
        ]);
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      final fileName = 'perbaikan_${DateFormat(_dateFormat).format(DateTime.now())}.csv';
      
      return await _saveFile(fileName, csvString);
    } catch (e) {
      throw Exception('Gagal export data perbaikan ke CSV: $e');
    }
  }

  /// Export data temuan ke JSON
  static Future<String> exportTemuanToJson(List<Temuan> temuanList) async {
    try {
      final List<Map<String, dynamic>> jsonData = [];
      
      for (final temuan in temuanList) {
        jsonData.add({
          'id': temuan.id,
          'tanggal': AppDateUtils.formatDisplayDate(temuan.tanggal),
          'jenis_temuan': temuan.jenisTemuan,
          'jalur': temuan.jalur,
          'lajur': temuan.lajur,
          'kilometer': temuan.kilometer,
          'latitude': temuan.latitude,
          'longitude': temuan.longitude,
          'deskripsi': temuan.deskripsi,
          'foto_path': temuan.fotoPath,
        });
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final fileName = 'temuan_${DateFormat(_dateFormat).format(DateTime.now())}.json';
      
      return await _saveFile(fileName, jsonString);
    } catch (e) {
      throw Exception('Gagal export data temuan ke JSON: $e');
    }
  }

  /// Export data perbaikan ke JSON
  static Future<String> exportPerbaikanToJson(List<Perbaikan> perbaikanList) async {
    try {
      final List<Map<String, dynamic>> jsonData = [];
      
      for (final perbaikan in perbaikanList) {
        jsonData.add({
          'id': perbaikan.id,
          'tanggal': AppDateUtils.formatDisplayDate(perbaikan.tanggal),
          'jenis_perbaikan': perbaikan.jenisPerbaikan,
          'jalur': perbaikan.jalur,
          'lajur': perbaikan.lajur,
          'kilometer': perbaikan.kilometer,
          'latitude': perbaikan.latitude,
          'longitude': perbaikan.longitude,
          'deskripsi': perbaikan.deskripsi,
          'status_perbaikan': perbaikan.statusPerbaikan,
          'foto_path': perbaikan.fotoPath,
        });
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final fileName = 'perbaikan_${DateFormat(_dateFormat).format(DateTime.now())}.json';
      
      return await _saveFile(fileName, jsonString);
    } catch (e) {
      throw Exception('Gagal export data perbaikan ke JSON: $e');
    }
  }

  /// Export data temuan ke TXT
  static Future<String> exportTemuanToTxt(List<Temuan> temuanList) async {
    try {
      final StringBuffer buffer = StringBuffer();
      
      buffer.writeln('LAPORAN DATA TEMUAN');
      buffer.writeln('Tanggal Export: ${AppDateUtils.formatDisplayDate(DateTime.now())}');
      buffer.writeln('Total Data: ${temuanList.length}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (int i = 0; i < temuanList.length; i++) {
        final temuan = temuanList[i];
        buffer.writeln('${i + 1}. ID: ${temuan.id}');
        buffer.writeln('   Tanggal: ${AppDateUtils.formatDisplayDate(temuan.tanggal)}');
        buffer.writeln('   Jenis Temuan: ${temuan.jenisTemuan}');
        buffer.writeln('   Jalur: ${temuan.jalur}');
        buffer.writeln('   Lajur: ${temuan.lajur}');
        buffer.writeln('   Kilometer: ${temuan.kilometer}');
        buffer.writeln('   Koordinat: ${temuan.latitude}, ${temuan.longitude}');
        buffer.writeln('   Deskripsi: ${temuan.deskripsi}');
        if (temuan.fotoPath != null && temuan.fotoPath!.isNotEmpty) {
          buffer.writeln('   Foto: ${temuan.fotoPath}');
        }
        buffer.writeln('-' * 30);
        buffer.writeln();
      }

      final fileName = 'temuan_${DateFormat(_dateFormat).format(DateTime.now())}.txt';
      return await _saveFile(fileName, buffer.toString());
    } catch (e) {
      throw Exception('Gagal export data temuan ke TXT: $e');
    }
  }

  /// Export data perbaikan ke TXT
  static Future<String> exportPerbaikanToTxt(List<Perbaikan> perbaikanList) async {
    try {
      final StringBuffer buffer = StringBuffer();
      
      buffer.writeln('LAPORAN DATA PERBAIKAN');
      buffer.writeln('Tanggal Export: ${AppDateUtils.formatDisplayDate(DateTime.now())}');
      buffer.writeln('Total Data: ${perbaikanList.length}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (int i = 0; i < perbaikanList.length; i++) {
        final perbaikan = perbaikanList[i];
        buffer.writeln('${i + 1}. ID: ${perbaikan.id}');
        buffer.writeln('   Tanggal: ${AppDateUtils.formatDisplayDate(perbaikan.tanggal)}');
        buffer.writeln('   Jenis Perbaikan: ${perbaikan.jenisPerbaikan}');
        buffer.writeln('   Jalur: ${perbaikan.jalur}');
        buffer.writeln('   Lajur: ${perbaikan.lajur}');
        buffer.writeln('   Kilometer: ${perbaikan.kilometer}');
        buffer.writeln('   Koordinat: ${perbaikan.latitude}, ${perbaikan.longitude}');
        buffer.writeln('   Status: ${perbaikan.statusPerbaikan}');
        buffer.writeln('   Deskripsi: ${perbaikan.deskripsi}');
        if (perbaikan.fotoPath != null && perbaikan.fotoPath!.isNotEmpty) {
          buffer.writeln('   Foto: ${perbaikan.fotoPath}');
        }
        buffer.writeln('-' * 30);
        buffer.writeln();
      }

      final fileName = 'perbaikan_${DateFormat(_dateFormat).format(DateTime.now())}.txt';
      return await _saveFile(fileName, buffer.toString());
    } catch (e) {
      throw Exception('Gagal export data perbaikan ke TXT: $e');
    }
  }

  /// Export semua data ke ZIP
  static Future<String> exportAllDataToZip({
    required List<Temuan> temuanList,
    required List<Perbaikan> perbaikanList,
  }) async {
    try {
      // Create temporary directory
      final tempDir = await getTemporaryDirectory();
      final exportDir = Directory('${tempDir.path}/export_${DateFormat(_dateFormat).format(DateTime.now())}');
      await exportDir.create(recursive: true);

      // Export temuan
      if (temuanList.isNotEmpty) {
        final csvPath = await exportTemuanToCsv(temuanList);
        final jsonPath = await exportTemuanToJson(temuanList);
        final txtPath = await exportTemuanToTxt(temuanList);
        
        // Copy files to export directory
        await File(csvPath).copy('${exportDir.path}/temuan.csv');
        await File(jsonPath).copy('${exportDir.path}/temuan.json');
        await File(txtPath).copy('${exportDir.path}/temuan.txt');
      }

      // Export perbaikan
      if (perbaikanList.isNotEmpty) {
        final csvPath = await exportPerbaikanToCsv(perbaikanList);
        final jsonPath = await exportPerbaikanToJson(perbaikanList);
        final txtPath = await exportPerbaikanToTxt(perbaikanList);
        
        // Copy files to export directory
        await File(csvPath).copy('${exportDir.path}/perbaikan.csv');
        await File(jsonPath).copy('${exportDir.path}/perbaikan.json');
        await File(txtPath).copy('${exportDir.path}/perbaikan.txt');
      }

      // Create summary file
      final summaryFile = File('${exportDir.path}/summary.txt');
      await summaryFile.writeAsString('''
LAPORAN EXPORT DATA MONITORING JALAN TOL MBZ
Tanggal Export: ${AppDateUtils.formatDisplayDate(DateTime.now())}

STATISTIK DATA:
- Total Temuan: ${temuanList.length}
- Total Perbaikan: ${perbaikanList.length}
- Total Data: ${temuanList.length + perbaikanList.length}

FILE YANG DIEKSPOR:
${temuanList.isNotEmpty ? '- temuan.csv, temuan.json, temuan.txt' : ''}
${perbaikanList.isNotEmpty ? '- perbaikan.csv, perbaikan.json, perbaikan.txt' : ''}

FORMAT FILE:
- CSV: Data dalam format spreadsheet
- JSON: Data dalam format JSON untuk integrasi sistem
- TXT: Data dalam format teks yang mudah dibaca

Lokasi Export: ${exportDir.path}
''');

      return exportDir.path;
    } catch (e) {
      throw Exception('Gagal export semua data: $e');
    }
  }

  /// Helper method untuk menyimpan file
  static Future<String> _saveFile(String fileName, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      throw Exception('Gagal menyimpan file: $e');
    }
  }

  /// Get export statistics
  static Map<String, dynamic> getExportStats({
    required List<Temuan> temuanList,
    required List<Perbaikan> perbaikanList,
  }) {
    return {
      'total_temuan': temuanList.length,
      'total_perbaikan': perbaikanList.length,
      'total_data': temuanList.length + perbaikanList.length,
      'export_time': DateTime.now().toIso8601String(),
    };
  }
}
