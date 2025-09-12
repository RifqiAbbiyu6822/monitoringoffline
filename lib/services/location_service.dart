import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Cache untuk lokasi terakhir
  Position? _cachedPosition;
  DateTime? _lastLocationTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  Future<bool> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  Future<bool> _checkLocationService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Cek cache terlebih dahulu
      if (_isCacheValid()) {
        return {
          'success': true,
          'error': null,
          'latitude': _cachedPosition!.latitude.toString(),
          'longitude': _cachedPosition!.longitude.toString(),
        };
      }

      // Cek permission
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        return _createErrorResponse('Permission lokasi tidak diberikan');
      }

      // Cek service GPS
      final serviceEnabled = await _checkLocationService();
      if (!serviceEnabled) {
        return _createErrorResponse('GPS tidak aktif. Silakan aktifkan GPS terlebih dahulu.');
      }

      // Ambil posisi saat ini
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
        forceAndroidLocationManager: true, // Use Android's classic location manager
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Timeout saat mencari lokasi');
        },
      );

      // Update cache
      _cachedPosition = position;
      _lastLocationTime = DateTime.now();

      return {
        'success': true,
        'error': null,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      return _createErrorResponse('Gagal mendapatkan lokasi: ${e.toString()}');
    }
  }

  bool _isCacheValid() {
    if (_cachedPosition == null || _lastLocationTime == null) {
      return false;
    }
    return DateTime.now().difference(_lastLocationTime!) < _cacheExpiry;
  }

  Map<String, dynamic> _createErrorResponse(String error) {
    return {
      'success': false,
      'error': error,
      'latitude': null,
      'longitude': null,
    };
  }

  Future<Map<String, dynamic>> getLastKnownLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        return _createErrorResponse('Permission lokasi tidak diberikan');
      }

      final position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return _createErrorResponse('Tidak ada lokasi terakhir yang tersimpan');
      }

      return {
        'success': true,
        'error': null,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      return _createErrorResponse('Gagal mendapatkan lokasi terakhir: ${e.toString()}');
    }
  }

  // Method untuk clear cache jika diperlukan
  void clearCache() {
    _cachedPosition = null;
    _lastLocationTime = null;
  }

  // Method untuk mendapatkan status cache
  bool get hasValidCache => _isCacheValid();
}

