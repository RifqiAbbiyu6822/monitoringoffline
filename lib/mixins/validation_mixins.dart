mixin ValidationMixins {
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  String? validateNumeric(String? value, String fieldName) {
    final requiredValidation = validateRequired(value, fieldName);
    if (requiredValidation != null) return requiredValidation;
    
    if (double.tryParse(value!) == null) {
      return 'Format $fieldName tidak valid';
    }
    return null;
  }

  String? validateLatitude(String? value) {
    final numericValidation = validateNumeric(value, 'Latitude');
    if (numericValidation != null) return numericValidation;
    
    final lat = double.parse(value!);
    if (lat < -90 || lat > 90) {
      return 'Latitude harus antara -90 dan 90';
    }
    return null;
  }

  String? validateLongitude(String? value) {
    final numericValidation = validateNumeric(value, 'Longitude');
    if (numericValidation != null) return numericValidation;
    
    final lng = double.parse(value!);
    if (lng < -180 || lng > 180) {
      return 'Longitude harus antara -180 dan 180';
    }
    return null;
  }

  String? validateKilometer(String? value) {
    final requiredValidation = validateRequired(value, 'Kilometer');
    if (requiredValidation != null) return requiredValidation;
    
    // Validasi format kilometer (bisa berupa angka atau range seperti "10-15")
    final kmPattern = RegExp(r'^(\d+(\.\d+)?)(\s*-\s*\d+(\.\d+)?)?$');
    if (!kmPattern.hasMatch(value!)) {
      return 'Format kilometer tidak valid (contoh: 10 atau 10-15)';
    }
    return null;
  }

  String? validateDescription(String? value) {
    final requiredValidation = validateRequired(value, 'Deskripsi');
    if (requiredValidation != null) return requiredValidation;
    
    if (value!.trim().length < 10) {
      return 'Deskripsi minimal 10 karakter';
    }
    
    if (value.trim().length > 500) {
      return 'Deskripsi maksimal 500 karakter';
    }
    return null;
  }

  String? validateJenisPerbaikan(String? value) {
    final requiredValidation = validateRequired(value, 'Jenis Perbaikan');
    if (requiredValidation != null) return requiredValidation;
    
    if (value!.trim().length < 3) {
      return 'Jenis perbaikan minimal 3 karakter';
    }
    return null;
  }

  String? validateJenisTemuan(String? value) {
    final requiredValidation = validateRequired(value, 'Jenis Temuan');
    if (requiredValidation != null) return requiredValidation;
    
    if (value!.trim().length < 3) {
      return 'Jenis temuan minimal 3 karakter';
    }
    return null;
  }

  // Validasi untuk koordinat GPS
  String? validateGpsCoordinates(String? latitude, String? longitude) {
    final latValidation = validateLatitude(latitude);
    if (latValidation != null) return latValidation;
    
    final lngValidation = validateLongitude(longitude);
    if (lngValidation != null) return lngValidation;
    
    return null;
  }

  // Validasi untuk form temuan
  Map<String, String?> validateTemuanForm({
    required String? jenisTemuan,
    required String? kilometer,
    required String? latitude,
    required String? longitude,
    required String? deskripsi,
  }) {
    return {
      'jenisTemuan': validateJenisTemuan(jenisTemuan),
      'kilometer': validateKilometer(kilometer),
      'latitude': validateLatitude(latitude),
      'longitude': validateLongitude(longitude),
      'deskripsi': validateDescription(deskripsi),
    };
  }

  // Validasi untuk form perbaikan
  Map<String, String?> validatePerbaikanForm({
    required String? jenisPerbaikan,
    required String? kilometer,
    required String? latitude,
    required String? longitude,
    required String? deskripsi,
  }) {
    return {
      'jenisPerbaikan': validateJenisPerbaikan(jenisPerbaikan),
      'kilometer': validateKilometer(kilometer),
      'latitude': validateLatitude(latitude),
      'longitude': validateLongitude(longitude),
      'deskripsi': validateDescription(deskripsi),
    };
  }

  // Helper method untuk mengecek apakah form valid
  bool isFormValid(Map<String, String?> validations) {
    return validations.values.every((error) => error == null);
  }
}
