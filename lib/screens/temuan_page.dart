import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/temuan.dart';
import '../database/database_helper.dart';
import '../constants/theme_constants.dart';
import '../utils/ui_helpers.dart';
import '../widgets/reusable_header_widget.dart';
import '../widgets/reusable_navigation_buttons.dart';
import '../widgets/reusable_form_sections.dart';
import '../widgets/reusable_location_service.dart';
import '../widgets/reusable_snackbar_helper.dart';
import '../widgets/reusable_export_functions.dart';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      ReusableHeaderWidget(
                        title: 'Input Data Temuan',
                        subtitle: 'Pencatatan temuan atau anomali jalan tol',
                        icon: Icons.search_outlined,
                        iconColor: ThemeConstants.primary,
                      ),
                      UIHelpers.vXL,
                      // Form Card
                      Container(
                        padding: const EdgeInsets.all(ThemeConstants.spacingL),
                        decoration: ThemeConstants.cardDecoration,
                        child: ReusableFormSections.buildTemuanForm(
                          formKey: _formKey,
                          tanggal: _tanggal,
                          jenisTemuan: _jenisTemuan,
                          jalur: _jalur,
                          lajur: _lajur,
                          kilometerController: _kilometerController,
                          latitudeController: _latitudeController,
                          longitudeController: _longitudeController,
                          deskripsiController: _deskripsiController,
                          fotoPath: _fotoPath,
                          onDateChanged: (date) => setState(() => _tanggal = date),
                          onJenisTemuanChanged: (value) => setState(() => _jenisTemuan = value),
                          onJalurChanged: (value) => setState(() => _jalur = value),
                          onLajurChanged: (value) => setState(() => _lajur = value),
                          onImageChanged: (path) => setState(() => _fotoPath = path),
                          onGetLocation: _getCurrentLocation,
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
        ],
      ),
      floatingActionButton: ReusableNavigationButtons(
        onBack: () => Navigator.pop(context),
        onExport: () => ReusableExportFunctions.exportTemuanToPdf(context, _tanggal),
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
          ReusableSnackbarHelper.showSuccess(
            context,
            'Data temuan berhasil disimpan',
          );
          
          // Reset form
          _resetForm();
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

}