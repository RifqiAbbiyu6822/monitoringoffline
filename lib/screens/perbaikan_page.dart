import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/perbaikan.dart';
import '../database/database_helper.dart';
import '../constants/theme_constants.dart';
import '../widgets/reusable_header_widget.dart';
import '../widgets/reusable_navigation_buttons.dart';
import '../widgets/reusable_form_sections.dart';
import '../widgets/reusable_location_service.dart';
import '../widgets/reusable_snackbar_helper.dart';
import '../widgets/reusable_export_functions.dart';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      ReusableHeaderWidget(
                        title: 'Input Data Perbaikan',
                        subtitle: 'Pencatatan perbaikan jalan tol',
                        icon: Icons.build_outlined,
                        iconColor: ThemeConstants.secondary,
                      ),
                      
                      const SizedBox(height: ThemeConstants.spacingXL),
                      
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(ThemeConstants.spacingL),
                        decoration: ThemeConstants.cardDecoration,
                        child: ReusableFormSections.buildPerbaikanForm(
                          formKey: _formKey,
                          tanggal: _tanggal,
                          jalur: _jalur,
                          lajur: _lajur,
                          statusPerbaikan: _statusPerbaikan,
                          objectIdController: _objectIdController,
                          jenisPerbaikanController: _jenisPerbaikanController,
                          kilometerController: _kilometerController,
                          latitudeController: _latitudeController,
                          longitudeController: _longitudeController,
                          deskripsiController: _deskripsiController,
                          fotoPath: _fotoPath,
                          onDateChanged: (date) => setState(() => _tanggal = date),
                          onJalurChanged: (value) => setState(() => _jalur = value),
                          onLajurChanged: (value) => setState(() => _lajur = value),
                          onStatusChanged: (value) => setState(() => _statusPerbaikan = value),
                          onImageChanged: (path) => setState(() => _fotoPath = path),
                          onGetLocation: _getCurrentLocation,
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
        ],
      ),
      floatingActionButton: ReusableNavigationButtons(
        onBack: () => Navigator.pop(context),
        onExport: () => ReusableExportFunctions.exportPerbaikanToPdf(context, _tanggal),
        backTooltip: 'Kembali',
        exportTooltip: 'Ekspor ke PDF',
      ),
    );
  }


  Future<void> _getCurrentLocation() async {
    await ReusableLocationService.updateLocationFields(
      context,
      _latitudeController,
      _longitudeController,
    );
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
          ReusableSnackbarHelper.showSuccess(
            context,
            _editingId != null 
                ? 'Data perbaikan berhasil diperbarui' 
                : 'Data perbaikan berhasil disimpan',
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
          ReusableSnackbarHelper.showError(
            context,
            'Error: $e',
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

}