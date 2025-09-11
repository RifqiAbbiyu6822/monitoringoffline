class AppConstants {
  // App Info
  static const String appName = 'Jasa Marga Mobile Offline';
  static const String appTitle = 'Monitoring Jalan Tol MBZ';
  static const String appSubtitle = 'Aplikasi Offline';

  // Database
  static const String databaseName = 'monitoring_offline.db';
  static const int databaseVersion = 2;

  // Date Formats
  static const String dateFormatDisplay = 'dd MMMM yyyy';
  static const String dateFormatShort = 'dd/MM/yyyy';
  static const String dateFormatFileName = 'yyyyMMdd';

  // PDF
  static const String pdfTitle = 'LAPORAN JALAN TOL MBZ';
  static const String pdfTemuanTitle = 'LAPORAN TEMUAN JALAN TOL MBZ';
  static const String pdfPerbaikanTitle = 'LAPORAN PERBAIKAN JALAN TOL MBZ';

  // Form Options
  static const List<String> jalurOptions = [
    'Jalur A',
    'Jalur B',
  ];

  static const List<String> lajurOptions = [
    'Lajur 1',
    'Lajur 2',
    'Bahu Dalam',
    'Bahu Luar',
  ];

  static const List<String> jenisTemuanOptions = [
    'Kerusakan jalan',
    'Fasilitas rusak',
    'Lain-lain',
  ];

  static const List<String> statusPerbaikanOptions = [
    '0%',
    '25%',
    '50%',
    '75%',
    '100%',
  ];

  // Colors
  static const int primaryColorValue = 0xFF1976D2; // Blue 800
  static const int secondaryColorValue = 0xFFFF8F00; // Orange 600
  static const int successColorValue = 0xFF388E3C; // Green 600
  static const int errorColorValue = 0xFFD32F2F; // Red 600

  // UI Constants
  static const double defaultPadding = 20.0;
  static const double cardBorderRadius = 15.0;
  static const double buttonBorderRadius = 10.0;
  static const double inputBorderRadius = 8.0;
  static const double photoHeight = 200.0;
  static const double photoHeightPdf = 120.0;

  // Validation
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 500;
  static const int minJenisLength = 3;

  // Location
  static const int locationTimeoutSeconds = 15;
  static const int locationCacheMinutes = 5;

  // Error Messages
  static const String errorDatabaseConnection = 'Gagal terhubung ke database';
  static const String errorLocationPermission = 'Permission lokasi tidak diberikan';
  static const String errorLocationService = 'GPS tidak aktif. Silakan aktifkan GPS terlebih dahulu.';
  static const String errorPdfGeneration = 'Gagal membuat PDF';
  static const String errorImagePick = 'Gagal mengambil gambar';
  static const String errorDataSave = 'Gagal menyimpan data';
  static const String errorDataLoad = 'Gagal memuat data';

  // Success Messages
  static const String successDataSaved = 'Data berhasil disimpan';
  static const String successPdfGenerated = 'PDF berhasil diekspor';
  static const String successLocationObtained = 'Lokasi GPS berhasil diambil';
  static const String successImagePicked = 'Gambar berhasil diambil';

  // File Extensions
  static const String pdfExtension = '.pdf';
  static const String imageExtension = '.jpg';

  // Default Values
  static const String defaultJalur = 'Jalur A';
  static const String defaultLajur = 'Lajur 1';
  static const String defaultJenisTemuan = 'Kerusakan jalan';
  static const String defaultStatusPerbaikan = '0%';
}
