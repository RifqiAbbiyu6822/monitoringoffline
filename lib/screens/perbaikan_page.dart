import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/perbaikan.dart';
import '../database/database_helper.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_config_dialog.dart';
import '../widgets/export_confirmation_dialog.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../services/location_service.dart';
import '../constants/theme_constants.dart';
import '../constants/app_constants.dart';

class PerbaikanPage extends StatefulWidget {
  final Perbaikan? existingPerbaikan; // For continuing existing perbaikan
  
  const PerbaikanPage({super.key, this.existingPerbaikan});

  @override
  State<PerbaikanPage> createState() => _PerbaikanPageState();
}

class _PerbaikanPageState extends State<PerbaikanPage> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  final _jenisPerbaikanController = TextEditingController();
  final _kilometerController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _objectIdController = TextEditingController();
  
  DateTime _tanggal = DateTime.now();
  String _jalur = 'Jalur A';
  String _lajur = 'Lajur 1';
  String _statusPerbaikan = '0%'; // Always start at 0%
  String? _fotoPath;
  int? _editingId; // ID of perbaikan being edited
  
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

  final List<String> _statusOptions = AppConstants.statusPerbaikanOptions;

  @override
  void initState() {
    super.initState();
    if (widget.existingPerbaikan != null) {
      _loadExistingPerbaikan();
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _jenisPerbaikanController.dispose();
    _kilometerController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _objectIdController.dispose();
    super.dispose();
  }

  void _loadExistingPerbaikan() {
    final perbaikan = widget.existingPerbaikan!;
    setState(() {
      _editingId = perbaikan.id;
      _tanggal = perbaikan.tanggal;
      _jalur = perbaikan.jalur;
      _lajur = perbaikan.lajur;
      _statusPerbaikan = perbaikan.statusPerbaikan;
      _fotoPath = perbaikan.fotoPath;
    });
    
    _deskripsiController.text = perbaikan.deskripsi;
    _jenisPerbaikanController.text = perbaikan.jenisPerbaikan;
    _kilometerController.text = perbaikan.kilometer;
    _latitudeController.text = perbaikan.latitude;
    _longitudeController.text = perbaikan.longitude;
    _objectIdController.text = perbaikan.objectId;
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
                  padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingL, vertical: ThemeConstants.spacingM),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        
                        const SizedBox(height: ThemeConstants.spacingXL),
                        
                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(ThemeConstants.spacingL),
                          decoration: ThemeConstants.cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tanggal
                              _buildDateField(),
                              const SizedBox(height: ThemeConstants.spacingL),

                              // ID Objek
                              _buildTextField(
                                label: 'ID Objek',
                                controller: _objectIdController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ID objek harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Jenis Perbaikan
                              _buildTextField(
                                label: 'Jenis Perbaikan',
                                controller: _jenisPerbaikanController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jenis perbaikan harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Jalur
                              _buildDropdownField(
                                label: 'Jalur',
                                value: _jalur,
                                items: _jalurOptions,
                                onChanged: (value) {
                                  setState(() {
                                    _jalur = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Lajur
                              _buildDropdownField(
                                label: 'Lajur',
                                value: _lajur,
                                items: _lajurOptions,
                                onChanged: (value) {
                                  setState(() {
                                    _lajur = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Kilometer
                              _buildTextField(
                                label: 'Kilometer',
                                controller: _kilometerController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kilometer harus diisi';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Status Perbaikan
                              _buildDropdownField(
                                label: 'Status Perbaikan',
                                value: _statusPerbaikan,
                                items: _statusOptions,
                                onChanged: (value) {
                                  setState(() {
                                    _statusPerbaikan = value!;
                                  });
                                },
                              ),
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Koordinat
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Koordinat GPS',
                                        style: ThemeConstants.bodyLarge,
                                      ),
                                      const Spacer(),
                                      ElevatedButton.icon(
                                        onPressed: _getCurrentLocation,
                                        icon: const Icon(Icons.my_location, size: 16),
                                        label: const Text('Ambil GPS'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ThemeConstants.secondary,
                                          foregroundColor: ThemeConstants.backgroundWhite,
                                          padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM, vertical: ThemeConstants.spacingS),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(ThemeConstants.radiusS),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: ThemeConstants.spacingS),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          label: 'Latitude',
                                          controller: _latitudeController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Latitude harus diisi';
                                            }
                                            if (double.tryParse(value) == null) {
                                              return 'Format latitude tidak valid';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: ThemeConstants.spacingM),
                                      Expanded(
                                        child: _buildTextField(
                                          label: 'Longitude',
                                          controller: _longitudeController,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Longitude harus diisi';
                                            }
                                            if (double.tryParse(value) == null) {
                                              return 'Format longitude tidak valid';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Deskripsi
                              _buildTextField(
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
                              const SizedBox(height: ThemeConstants.spacingL),
                              
                              // Foto
                              _buildPhotoSection(),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: ThemeConstants.spacingXL),
                        
                        // Tombol Simpan
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _savePerbaikan,
                            style: ThemeConstants.secondaryButtonStyle,
                            child: const Text(
                              'Simpan Data Perbaikan',
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


  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal',
          style: ThemeConstants.bodyLarge,
        ),
        const SizedBox(height: ThemeConstants.spacingS),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            decoration: BoxDecoration(
              border: Border.all(color: ThemeConstants.secondary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              color: ThemeConstants.backgroundWhite,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: ThemeConstants.secondary.withOpacity(0.7)),
                const SizedBox(width: ThemeConstants.spacingM),
                Text(
                  DateFormat('dd MMMM yyyy').format(_tanggal),
                  style: ThemeConstants.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeConstants.bodyLarge,
        ),
        const SizedBox(height: ThemeConstants.spacingS),
        DropdownButtonFormField<String>(
          value: value,
          decoration: ThemeConstants.inputDecoration(label),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: ThemeConstants.bodyMedium),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeConstants.bodyLarge,
        ),
        const SizedBox(height: ThemeConstants.spacingS),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: ThemeConstants.bodyMedium,
          decoration: ThemeConstants.inputDecoration(label),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Perbaikan',
          style: ThemeConstants.bodyLarge,
        ),
        const SizedBox(height: ThemeConstants.spacingS),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.secondary,
                  foregroundColor: ThemeConstants.backgroundWhite,
                  padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  ),
                ),
              ),
            ),
            if (_fotoPath != null) ...[
              const SizedBox(width: ThemeConstants.spacingM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.errorRed,
                    foregroundColor: ThemeConstants.backgroundWhite,
                    padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingM),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_fotoPath != null) ...[
          const SizedBox(height: ThemeConstants.spacingM),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: ThemeConstants.secondary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              child: Image.file(
                File(_fotoPath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }

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
            const CircularProgressIndicator(color: ThemeConstants.secondary),
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

  Future<void> _savePerbaikan() async {
    if (_formKey.currentState!.validate()) {
      final perbaikan = Perbaikan(
        id: _editingId, // Include ID if editing
        tanggal: _tanggal,
        objectId: _objectIdController.text,
        jenisPerbaikan: _jenisPerbaikanController.text,
        jalur: _jalur,
        lajur: _lajur,
        kilometer: _kilometerController.text,
        latitude: _latitudeController.text,
        longitude: _longitudeController.text,
        deskripsi: _deskripsiController.text,
        statusPerbaikan: _editingId != null ? _statusPerbaikan : '0%', // Start at 0% for new repairs
        fotoPath: _fotoPath,
      );

      try {
        if (_editingId != null) {
          // Update existing perbaikan
          await DatabaseHelper().updatePerbaikan(perbaikan);
        } else {
          // Insert new perbaikan
          await DatabaseHelper().insertPerbaikan(perbaikan);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_editingId != null 
                  ? 'Data perbaikan berhasil diperbarui' 
                  : 'Data perbaikan berhasil disimpan'),
              backgroundColor: ThemeConstants.successGreen,
              behavior: SnackBarBehavior.fixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              ),
            ),
          );
          
          // Navigate back if editing, reset form if creating new
          if (_editingId != null) {
            Navigator.pop(context);
          } else {
            _resetForm();
          }
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
      _jalur = 'Jalur A';
      _lajur = 'Lajur 1';
      _statusPerbaikan = '0%';  // Always start at 0%
      _fotoPath = null;
    });
    _deskripsiController.clear();
    _jenisPerbaikanController.clear();
    _kilometerController.clear();
    _objectIdController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
  }

  Future<void> _exportToPdf() async {
    try {
      // Ambil data perbaikan untuk tanggal yang dipilih
      final perbaikanList = await DatabaseHelper().getPerbaikanByDate(_tanggal);
      
      // Tampilkan dialog konfirmasi export
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ExportConfirmationDialog(
          perbaikanList: perbaikanList,
          exportType: 'perbaikan',
          dateRange: DateFormat('dd/MM/yyyy').format(_tanggal),
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
          await PdfService().generatePerbaikanPdf(
            perbaikanList, 
            config,
            dateRange: DateFormat('dd/MM/yyyy').format(_tanggal),
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF berhasil diekspor (${perbaikanList.length} data)'),
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
            backgroundColor: ThemeConstants.secondary,
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