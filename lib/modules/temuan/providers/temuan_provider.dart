import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/camera_service.dart';
import '../models/temuan_model.dart';

class TemuanProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final LocationService _locationService = LocationService();
  final CameraService _cameraService = CameraService();

  List<TemuanModel> _temuanList = [];
  List<TemuanModel> _todayTemuanList = [];
  bool _isLoading = false;
  String? _error;

  List<TemuanModel> get temuanList => _temuanList;
  List<TemuanModel> get todayTemuanList => _todayTemuanList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllTemuan() async {
    _setLoading(true);
    try {
      final List<Map<String, dynamic>> temuanMaps = await _databaseHelper.getAllTemuan();
      _temuanList = temuanMaps.map((map) => TemuanModel.fromMap(map)).toList();
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat data temuan: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTodayTemuan() async {
    _setLoading(true);
    try {
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final List<Map<String, dynamic>> temuanMaps = await _databaseHelper.getTemuanByDate(today);
      _todayTemuanList = temuanMaps.map((map) => TemuanModel.fromMap(map)).toList();
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat data temuan hari ini: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTemuan({
    required String deskripsi,
    required File foto,
  }) async {
    _setLoading(true);
    try {
      // Get current location
      final coordinates = await _locationService.getLocationCoordinates();
      if (coordinates == null) {
        _error = 'Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin lokasi diberikan.';
        _setLoading(false);
        return false;
      }

      // Create temuan model
      final now = DateTime.now();
      final temuan = TemuanModel(
        deskripsi: deskripsi,
        fotoPath: foto.path,
        latitude: coordinates['latitude']!,
        longitude: coordinates['longitude']!,
        timestamp: now.toIso8601String(),
        createdDate: DateFormat('yyyy-MM-dd').format(now),
      );

      // Save to database
      await _databaseHelper.insertTemuan(temuan.toMap());

      // Refresh data
      await loadTodayTemuan();
      await loadAllTemuan();

      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal menyimpan temuan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<File?> takePicture() async {
    try {
      return await _cameraService.takePicture();
    } catch (e) {
      _error = 'Gagal mengambil foto: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteTemuan(int id, String fotoPath) async {
    _setLoading(true);
    try {
      // Delete from database
      await _databaseHelper.deleteTemuan(id);

      // Delete image file
      await _cameraService.deleteImage(fotoPath);

      // Refresh data
      await loadTodayTemuan();
      await loadAllTemuan();

      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal menghapus temuan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<TemuanModel> getTemuanByDate(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return _temuanList.where((temuan) => temuan.createdDate == dateString).toList();
  }

  List<String> getAvailableDates() {
    final dates = _temuanList.map((temuan) => temuan.createdDate).toSet().toList();
    dates.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return dates;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
