import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Dapatkan direktori temporary
  static Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Dapatkan direktori documents
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Dapatkan direktori external storage
  static Future<Directory?> getExternalStorageDirectory() async {
    return await getExternalStorageDirectory();
  }

  /// Buat direktori jika belum ada
  static Future<Directory> createDirectoryIfNotExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Cek apakah file ada
  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Dapatkan ukuran file dalam bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Dapatkan ukuran file dalam format yang mudah dibaca
  static Future<String> getFileSizeFormatted(String filePath) async {
    final sizeInBytes = await getFileSize(filePath);
    return _formatBytes(sizeInBytes);
  }

  /// Format bytes ke format yang mudah dibaca
  static String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Dapatkan ekstensi file
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Dapatkan nama file tanpa ekstensi
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Dapatkan nama file dengan ekstensi
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Dapatkan direktori dari path file
  static String getDirectory(String filePath) {
    return path.dirname(filePath);
  }

  /// Buat nama file yang unik
  static String generateUniqueFileName(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${baseName}_$timestamp$extension';
  }

  /// Hapus file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Hapus direktori dan semua isinya
  static Future<bool> deleteDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Copy file
  static Future<bool> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.copy(destinationPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Move file
  static Future<bool> moveFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        await sourceFile.rename(destinationPath);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Dapatkan semua file dalam direktori
  static Future<List<File>> getFilesInDirectory(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (await directory.exists()) {
        final files = await directory.list().where((entity) => entity is File).cast<File>().toList();
        return files;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Dapatkan semua file dengan ekstensi tertentu
  static Future<List<File>> getFilesWithExtension(String dirPath, String extension) async {
    final allFiles = await getFilesInDirectory(dirPath);
    return allFiles.where((file) => getFileExtension(file.path) == extension).toList();
  }

  /// Cek apakah path adalah file gambar
  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  /// Cek apakah path adalah file PDF
  static bool isPdfFile(String filePath) {
    return getFileExtension(filePath) == '.pdf';
  }

  /// Dapatkan MIME type dari ekstensi file
  static String getMimeType(String filePath) {
    final extension = getFileExtension(filePath);
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
