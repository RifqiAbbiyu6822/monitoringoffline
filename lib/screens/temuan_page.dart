import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/temuan.dart';
import '../database/database_helper.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_config_dialog.dart';
import '../widgets/export_confirmation_dialog.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../services/location_service.dart';
import '../constants/theme_constants.dart';
import '../widgets/common_form_widgets.dart';
import '../utils/ui_helpers.dart';
import '../utils/date_utils.dart';

class TemuanPage extends StatefulWidget {
  const TemuanPage({super.key});

  @override
  State<TemuanPage> createState() => _TemuanPageState();
}

class _TemuanPageState extends State<TemuanPage> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  final _kilometerController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  DateTime _tanggal = DateTime.now();
  String _jenisTemuan = 'Kerusakan jalan';
  String _jalur = 'Jalur A';
  String _lajur = 'Lajur 1';
  String? _fotoPath;
  
  final List<String> _jenisTemuanOptions = [
    'Kerusakan jalan',
    'Fasilitas rusak',
    'Lain-lain',
  ];
  
  final List<String> _jalurOptions = [
    'Jalur A',
    'Jalur B',
  ];
  
  final List<String> _lajurOptions = [
    'Lajur 1',
    'Lajur 2',
    'Bahu Dalam',
    'Bahu Luar',
  ];

  @override
  void dispose() {
    _deskripsiController.dispose();
    _kilometerController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundWhite,
      body: Column(
        children: [
          // Content
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: UIHelpers.paddingSymmetricPage,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        _buildHeaderSection(),
                        UIHelpers.vXL,
                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(ThemeConstants.spacingL),
                          decoration: ThemeConstants.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tanggal
                              CommonFormWidgets.buildDateField(
                                label: 'Tanggal',
                                value: _tanggal,
                                onTap: _selectDate,
                              ),
                              UIHelpers.vL,
                              
                              // Jenis Temuan
                              CommonFormWidgets.buildDropdownField(
                                label: 'Jenis Temuan',
                                value: _jenisTemuan,
                                items: _jenisTemuanOptions,
                                onChanged: (value) {
                                  setState(() {
                                    _jenisTemuan = value!;
                                  });
                                },
                              ),
                              UIHelpers.vL,
                              
                              // Jalur
                              CommonFormWidgets.buildDropdownField(
                                label: 'Jalur',
                                value: _jalur,
                                items: _jalurOptions,
                                onChanged: (value) {
                                  setState(() {
                                    _jalur = value!;
                                  });
                                },
                              ),
                              UIHelpers.vL,
                              
                              // Lajur
                              CommonFormWidgets.buildDropdownField(
                                label: 'Lajur',
                                value: _lajur,
                                items: _lajurOptions,
                                onChanged: (value) {
                                  setState(() {
                                    _lajur = value!;
                                  });
                                },
                              ),
                              UIHelpers.vL,
                              
                              // Kilometer
                              CommonFormWidgets.buildTextField(
                                label: 'Kilometer',
                                controller: _kilometerController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kilometer harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              UIHelpers.vL,
                              
                              // Koordinat
                              CommonFormWidgets.buildGpsSection(
                                latitudeController: _latitudeController,
                                longitudeController: _longitudeController,
                                onGetLocation: _getCurrentLocation,
                              ),
                              UIHelpers.vL,
                              
                              // Deskripsi
                              CommonFormWidgets.buildTextField(
                                label: 'Deskripsi',
                                controller: _deskripsiController,
                                maxLines: 4,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Deskripsi harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              UIHelpers.vL,
                              
                              // Foto
                              CommonFormWidgets.buildPhotoSection(
                                label: 'Foto Temuan',
                                photoPath: _fotoPath,
                                onPickImage: _pickImage,
                                onRemoveImage: _removeImage,
                                buttonColor: ThemeConstants.primary,
                              ),
                            ],
                          ),
                        ),
                        UIHelpers.vXL,
                        // Tombol Simpan
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveTemuan,
                            style: ThemeConstants.primaryButtonStyle,
                            child: const Text(
                              'Simpan Data Temuan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildNavigationButtons(),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.surfaceDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            decoration: BoxDecoration(
              color: ThemeConstants.primary,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
            ),
            child: const Icon(
              Icons.search_outlined,
              size: 32,
              color: ThemeConstants.backgroundWhite,
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          const Text(
            'Input Data Temuan',
            style: ThemeConstants.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.spacingXS),
          Text(
            'Pencatatan temuan atau anomali jalan tol',
            style: TextStyle(
              fontSize: 14,
              color: ThemeConstants.primary.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Menggunakan CommonFormWidgets untuk field

  // Menggunakan CommonFormWidgets untuk dropdown

  // Menggunakan CommonFormWidgets untuk text field

  // Menggunakan CommonFormWidgets untuk photo section

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggal) {
      setState(() {
        _tanggal = picked;
      });
    }
  }

Future<void> _pickImage() async {
  final ImagePicker picker = ImagePicker();
  
  // Show bottom sheet to choose between camera and gallery
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      );
    },
  );
  
  if (source != null) {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        setState(() {
          _fotoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengambil foto. Silakan coba lagi.'),
          ),
        );
      }
    }
  }
}  void _removeImage() {
    setState(() {
      _fotoPath = null;
    });
  }

  Future<void> _getCurrentLocation() async {
    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConstants.backgroundWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        ),
        content: Row(
          children: [
            const CircularProgressIndicator(color: ThemeConstants.primary),
            const SizedBox(width: ThemeConstants.spacingL),
            const Text('Mengambil lokasi GPS...', style: ThemeConstants.bodyMedium),
          ],
        ),
      ),
    );

    try {
      final result = await LocationService().getCurrentLocation();
      
      // Tutup loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result['success']) {
        setState(() {
          _latitudeController.text = result['latitude'];
          _longitudeController.text = result['longitude'];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Lokasi GPS berhasil diambil'),
              backgroundColor: ThemeConstants.successGreen,
              behavior: SnackBarBehavior.fixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
              backgroundColor: ThemeConstants.errorRed,
              behavior: SnackBarBehavior.fixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Tutup loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ThemeConstants.errorRed,
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveTemuan() async {
    if (_formKey.currentState!.validate()) {
      final temuan = Temuan(
        tanggal: _tanggal,
        jenisTemuan: _jenisTemuan,
        jalur: _jalur,
        lajur: _lajur,
        kilometer: _kilometerController.text,
        latitude: _latitudeController.text,
        longitude: _longitudeController.text,
        deskripsi: _deskripsiController.text,
        fotoPath: _fotoPath,
      );

      try {
        await DatabaseHelper().insertTemuan(temuan);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Data temuan berhasil disimpan'),
              backgroundColor: ThemeConstants.successGreen,
              behavior: SnackBarBehavior.fixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              ),
            ),
          );
          
          // Reset form
          _resetForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: ThemeConstants.errorRed,
              behavior: SnackBarBehavior.fixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              ),
            ),
          );
        }
      }
    }
  }

  void _resetForm() {
    setState(() {
      _tanggal = DateTime.now();
      _jenisTemuan = 'Kerusakan jalan';
      _jalur = 'Jalur A';
      _lajur = 'Lajur 1';
      _fotoPath = null;
    });
    _deskripsiController.clear();
    _kilometerController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
  }

  Future<void> _exportToPdf() async {
    try {
      // Ambil data temuan untuk tanggal yang dipilih
      final temuanList = await DatabaseHelper().getTemuanByDate(_tanggal);
      
      // Tampilkan dialog konfirmasi export
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ExportConfirmationDialog(
          temuanList: temuanList,
          exportType: 'temuan',
          dateRange: AppDateUtils.formatShortDate(_tanggal),
        ),
      );

      if (confirmed == true) {
        // Tampilkan dialog konfigurasi PDF
        final config = await showDialog<pdf_config.PdfConfig>(
          context: context,
          builder: (context) => const PdfConfigDialog(),
        );

        if (config != null) {
          // Generate PDF
          await PdfService().generateTemuanPdf(
            temuanList, 
            config,
            dateRange: AppDateUtils.formatShortDate(_tanggal),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF berhasil diekspor (${temuanList.length} data)'),
                backgroundColor: ThemeConstants.successGreen,
                behavior: SnackBarBehavior.fixed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: ${e.toString()}'),
            backgroundColor: ThemeConstants.errorRed,
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
          ),
        );
      }
    }
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Export PDF Button
          FloatingActionButton(
            heroTag: "export_pdf",
            onPressed: _exportToPdf,
            backgroundColor: ThemeConstants.primary,
            mini: true,
            child: const Icon(Icons.picture_as_pdf, color: ThemeConstants.backgroundWhite),
            tooltip: 'Ekspor ke PDF',
          ),
          const SizedBox(height: 8),
          // Back Button
          FloatingActionButton(
            heroTag: "back_button",
            onPressed: () => Navigator.pop(context),
            backgroundColor: ThemeConstants.textSecondary,
            mini: true,
            child: const Icon(Icons.arrow_back, color: ThemeConstants.backgroundWhite),
            tooltip: 'Kembali',
          ),
        ],
      ),
    );
  }
}