import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

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
      // Cek permission
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        return {
          'success': false,
          'error': 'Permission lokasi tidak diberikan',
          'latitude': null,
          'longitude': null,
        };
      }

      // Cek service GPS
      final serviceEnabled = await _checkLocationService();
      if (!serviceEnabled) {
        return {
          'success': false,
          'error': 'GPS tidak aktif. Silakan aktifkan GPS terlebih dahulu.',
          'latitude': null,
          'longitude': null,
        };
      }

      // Ambil posisi saat ini
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return {
        'success': true,
        'error': null,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Gagal mendapatkan lokasi: ${e.toString()}',
        'latitude': null,
        'longitude': null,
      };
    }
  }

  Future<Map<String, dynamic>> getLastKnownLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        return {
          'success': false,
          'error': 'Permission lokasi tidak diberikan',
          'latitude': null,
          'longitude': null,
        };
      }

      final position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return {
          'success': false,
          'error': 'Tidak ada lokasi terakhir yang tersimpan',
          'latitude': null,
          'longitude': null,
        };
      }

      return {
        'success': true,
        'error': null,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Gagal mendapatkan lokasi terakhir: ${e.toString()}',
        'latitude': null,
        'longitude': null,
      };
    }
  }
}
