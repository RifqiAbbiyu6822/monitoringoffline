import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../constants/theme_constants.dart';
import 'reusable_loading_dialog.dart';
import 'reusable_snackbar_helper.dart';

class ReusableLocationService {
  static Future<Map<String, dynamic>> getCurrentLocation(BuildContext context) async {
    // Show loading dialog
    ReusableLoadingDialog.show(
      context,
      message: 'Mengambil lokasi GPS...',
      indicatorColor: ThemeConstants.primary,
    );

    try {
      final result = await LocationService().getCurrentLocation();
      
      // Hide loading dialog
      ReusableLoadingDialog.hide(context);

      if (result['success']) {
        ReusableSnackbarHelper.showSuccess(
          context,
          'Lokasi GPS berhasil diambil',
        );
        return result;
      } else {
        ReusableSnackbarHelper.showError(
          context,
          result['error'],
        );
        return result;
      }
    } catch (e) {
      // Hide loading dialog
      ReusableLoadingDialog.hide(context);
      
      ReusableSnackbarHelper.showError(
        context,
        'Error: $e',
      );
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  static Future<void> updateLocationFields(
    BuildContext context,
    TextEditingController latitudeController,
    TextEditingController longitudeController,
  ) async {
    final result = await getCurrentLocation(context);
    
    if (result['success']) {
      latitudeController.text = result['latitude'];
      longitudeController.text = result['longitude'];
    }
  }
}
