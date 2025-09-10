import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/perbaikan.dart';
import '../database/database_helper.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_config_dialog.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../services/location_service.dart';

class PerbaikanPage extends StatefulWidget {
  const PerbaikanPage({super.key});

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
  
  DateTime _tanggal = DateTime.now();
  String _jalur = 'Jalur A';
  String _lajur = 'Lajur 1';
  String _statusPerbaikan = '25%';
  String? _fotoPath;
  
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

  final List<String> _statusOptions = [
    '25%',
    '50%',
    '75%',
    '100%',
  ];

  @override
  void dispose() {
    _deskripsiController.dispose();
    _jenisPerbaikanController.dispose();
    _kilometerController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Input Data Perbaikan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[800],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _exportToPdf,
            tooltip: 'Ekspor ke PDF',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange[800]!,
              Colors.orange[600]!,
              Colors.orange[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tanggal
                        _buildDateField(),
                        const SizedBox(height: 20),
                        
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
                        const SizedBox(height: 20),
                        
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
                        const SizedBox(height: 20),
                        
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
                        const SizedBox(height: 20),
                        
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
                        const SizedBox(height: 20),
                        
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
                        const SizedBox(height: 20),
                        
                        // Koordinat
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Koordinat GPS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: _getCurrentLocation,
                                  icon: const Icon(Icons.my_location, size: 16),
                                  label: const Text('Ambil GPS'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
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
                                const SizedBox(width: 10),
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
                        const SizedBox(height: 20),
                        
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
                        const SizedBox(height: 20),
                        
                        // Foto
                        _buildPhotoSection(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: _savePerbaikan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Simpan Data Perbaikan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 10),
                Text(
                  DateFormat('dd MMMM yyyy').format(_tanggal),
                  style: const TextStyle(fontSize: 16),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (_fotoPath != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_fotoPath != null) ...[
          const SizedBox(height: 10),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _fotoPath = image.path;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _fotoPath = null;
    });
  }

  Future<void> _getCurrentLocation() async {
    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Mengambil lokasi GPS...'),
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
            const SnackBar(
              content: Text('Lokasi GPS berhasil diambil'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
              backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePerbaikan() async {
    if (_formKey.currentState!.validate()) {
      final perbaikan = Perbaikan(
        tanggal: _tanggal,
        jenisPerbaikan: _jenisPerbaikanController.text,
        jalur: _jalur,
        lajur: _lajur,
        kilometer: _kilometerController.text,
        latitude: _latitudeController.text,
        longitude: _longitudeController.text,
        deskripsi: _deskripsiController.text,
        statusPerbaikan: _statusPerbaikan,
        fotoPath: _fotoPath,
      );

      try {
        await DatabaseHelper().insertPerbaikan(perbaikan);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data perbaikan berhasil disimpan'),
              backgroundColor: Colors.green,
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
              backgroundColor: Colors.red,
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
      _statusPerbaikan = '25%';
      _fotoPath = null;
    });
    _deskripsiController.clear();
    _jenisPerbaikanController.clear();
    _kilometerController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
  }

  Future<void> _exportToPdf() async {
    final config = await showDialog<pdf_config.PdfConfig>(
      context: context,
      builder: (context) => const PdfConfigDialog(),
    );

    if (config != null) {
      try {
        final perbaikanList = await DatabaseHelper().getPerbaikanByDate(_tanggal);
        await PdfService().generatePerbaikanPdf(perbaikanList, config);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF berhasil diekspor'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
