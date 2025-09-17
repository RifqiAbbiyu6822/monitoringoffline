import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/camera_service.dart';
import '../models/perbaikan_model.dart';
import '../models/perbaikan_foto_model.dart';

class PerbaikanProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final LocationService _locationService = LocationService();
  final CameraService _cameraService = CameraService();

  List<PerbaikanModel> _perbaikanList = [];
  PerbaikanModel? _currentPerbaikan;
  List<PerbaikanFotoModel> _currentFotoList = [];
  bool _isLoading = false;
  String? _error;

  List<PerbaikanModel> get perbaikanList => _perbaikanList;
  PerbaikanModel? get currentPerbaikan => _currentPerbaikan;
  List<PerbaikanFotoModel> get currentFotoList => _currentFotoList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllPerbaikan() async {
    _setLoading(true);
    try {
      final List<Map<String, dynamic>> perbaikanMaps = await _databaseHelper.getAllPerbaikan();
      _perbaikanList = perbaikanMaps.map((map) => PerbaikanModel.fromMap(map)).toList();
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat data perbaikan: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPerbaikan({
    required String namaProyek,
    String? deskripsi,
  }) async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final perbaikan = PerbaikanModel(
        namaProyek: namaProyek,
        deskripsi: deskripsi,
        status: 0,
        createdDate: now.toIso8601String(),
        updatedDate: now.toIso8601String(),
      );

      await _databaseHelper.insertPerbaikan(perbaikan.toMap());
      await loadAllPerbaikan();

      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal membuat proyek perbaikan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPerbaikanDetail(int perbaikanId) async {
    _setLoading(true);
    try {
      // Load perbaikan detail
      final perbaikanMap = await _databaseHelper.getPerbaikanById(perbaikanId);
      if (perbaikanMap != null) {
        _currentPerbaikan = PerbaikanModel.fromMap(perbaikanMap);
      }

      // Load photos
      final fotoMaps = await _databaseHelper.getPerbaikanFotoByProject(perbaikanId);
      _currentFotoList = fotoMaps.map((map) => PerbaikanFotoModel.fromMap(map)).toList();

      _error = null;
    } catch (e) {
      _error = 'Gagal memuat detail perbaikan: $e';
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

  Future<bool> addFotoPerbaikan({
    required int perbaikanId,
    required File foto,
    required int progres,
    String? deskripsi,
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

      // Create foto model
      final now = DateTime.now();
      final fotoModel = PerbaikanFotoModel(
        perbaikanId: perbaikanId,
        fotoPath: foto.path,
        deskripsi: deskripsi,
        progres: progres,
        latitude: coordinates['latitude']!,
        longitude: coordinates['longitude']!,
        timestamp: now.toIso8601String(),
      );

      // Save to database
      await _databaseHelper.insertPerbaikanFoto(fotoModel.toMap());

      // Update perbaikan status if needed
      await _updatePerbaikanStatus(perbaikanId);

      // Refresh data
      await loadPerbaikanDetail(perbaikanId);

      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal menyimpan foto: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updatePerbaikanStatus(int perbaikanId) async {
    try {
      // Get all photos for this project
      final fotoMaps = await _databaseHelper.getPerbaikanFotoByProject(perbaikanId);
      final fotos = fotoMaps.map((map) => PerbaikanFotoModel.fromMap(map)).toList();

      // Determine status based on available photos
      int newStatus = 0;
      bool has0Percent = fotos.any((foto) => foto.progres == 0);
      bool has50Percent = fotos.any((foto) => foto.progres == 50);
      bool has100Percent = fotos.any((foto) => foto.progres == 100);

      if (has100Percent) {
        newStatus = 2; // 100%
      } else if (has50Percent) {
        newStatus = 1; // 50%
      } else if (has0Percent) {
        newStatus = 0; // 0%
      }

      // Update perbaikan status
      final now = DateTime.now();
      await _databaseHelper.updatePerbaikan(perbaikanId, {
        'status': newStatus,
        'updated_date': now.toIso8601String(),
      });
    } catch (e) {
      print('Error updating perbaikan status: $e');
    }
  }

  Future<bool> deletePerbaikan(int id) async {
    _setLoading(true);
    try {
      // Get all photos for this project to delete files
      final fotoMaps = await _databaseHelper.getPerbaikanFotoByProject(id);
      final fotos = fotoMaps.map((map) => PerbaikanFotoModel.fromMap(map)).toList();

      // Delete all photo files
      for (final foto in fotos) {
        await _cameraService.deleteImage(foto.fotoPath);
      }

      // Delete from database (cascade will handle photos)
      await _databaseHelper.deletePerbaikan(id);

      // Refresh data
      await loadAllPerbaikan();

      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal menghapus proyek perbaikan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteFotoPerbaikan(int fotoId, String fotoPath, int perbaikanId) async {
    _setLoading(true);
    try {
      // Delete from database
      await _databaseHelper.deletePerbaikanFoto(fotoId);

      // Delete image file
      await _cameraService.deleteImage(fotoPath);

      // Update perbaikan status
      await _updatePerbaikanStatus(perbaikanId);

      // Refresh data
      await loadPerbaikanDetail(perbaikanId);

      _error = null;
      return true;
    } catch (e) {
      _error = 'Gagal menghapus foto: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<PerbaikanFotoModel> getFotoByProgres(int progres) {
    return _currentFotoList.where((foto) => foto.progres == progres).toList();
  }

  bool canExportPdf() {
    return _currentPerbaikan?.isCompleted == true;
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
