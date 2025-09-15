import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/perbaikan.dart';
import '../models/perbaikan_progress.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../database/database_helper.dart';
import '../services/location_service.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_config_dialog.dart';
import '../constants/theme_constants.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import '../widgets/reusable_navigation_buttons.dart';

class PerbaikanProgressPage extends StatefulWidget {
  final Perbaikan perbaikan;
  
  const PerbaikanProgressPage({super.key, required this.perbaikan});

  @override
  State<PerbaikanProgressPage> createState() => _PerbaikanProgressPageState();
}

class _PerbaikanProgressPageState extends State<PerbaikanProgressPage> {
  List<PerbaikanProgress> _progressList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final progressList = await DatabaseHelper().getPerbaikanProgressByPerbaikanId(widget.perbaikan.id!);
      setState(() {
        _progressList = progressList;
      });
    } catch (e) {
      ErrorHandler.handleError(context, e, customMessage: 'Gagal memuat progress perbaikan');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundWhite,
      appBar: null,
      body: Column(
        children: [
          // Content
          Expanded(
            child: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo_jjcnormal.png',
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: ThemeConstants.secondary),
                ],
              ),
            )
          : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: ReusableNavigationButtons(
        onBack: () => Navigator.pop(context),
        onExport: () => _exportToPdf(),
        backTooltip: 'Kembali',
        exportTooltip: 'Export PDF',
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header dengan informasi perbaikan
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(ThemeConstants.spacingM),
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: ThemeConstants.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            border: Border.all(
              color: ThemeConstants.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                    ),
                    child: const Icon(
                      Icons.build_outlined,
                      color: ThemeConstants.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.perbaikan.jenisPerbaikan,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeConstants.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.perbaikan.jalur} - ${widget.perbaikan.lajur} (KM ${widget.perbaikan.kilometer})',
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConstants.spacingM),
              Text(
                'Status Saat Ini: ${widget.perbaikan.statusPerbaikan}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeConstants.primary,
                ),
              ),
            ],
          ),
        ),
        
        // List progress
        Expanded(
          child: _progressList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: ThemeConstants.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.timeline_outlined,
                          size: 64,
                          color: ThemeConstants.secondary,
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.spacingL),
                      const Text(
                        'Belum ada progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.spacingS),
                      Text(
                        'Tambahkan progress perbaikan untuk melacak perkembangan',
                        style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeConstants.spacingXL),
                      ElevatedButton.icon(
                        onPressed: _showAddProgressDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Progress'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConstants.secondary,
                          foregroundColor: ThemeConstants.backgroundWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
                  itemCount: _progressList.length,
                  itemBuilder: (context, index) {
                    return _buildProgressCard(_progressList[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(PerbaikanProgress progress, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: ThemeConstants.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(ThemeConstants.spacingM),
        leading: Container(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: _getProgressColor(progress.statusProgress).withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          child: Icon(
            _getProgressIcon(progress.statusProgress),
            color: _getProgressColor(progress.statusProgress),
            size: 24,
          ),
        ),
        title: Text(
          'Progress ${progress.statusProgress}',
          style: ThemeConstants.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ThemeConstants.spacingXS),
            Text(
              progress.deskripsiProgress,
              style: ThemeConstants.bodyMedium,
            ),
            const SizedBox(height: ThemeConstants.spacingXS),
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 16,
                  color: ThemeConstants.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(progress.tanggal),
                  style: ThemeConstants.bodySmall.copyWith(color: ThemeConstants.textSecondary),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: ThemeConstants.textSecondary,
          ),
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(progress);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: ThemeConstants.errorRed),
                  SizedBox(width: 8),
                  Text('Hapus'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(String status) {
    switch (status) {
      case '0%':
        return Colors.grey;
      case '25%':
        return Colors.orange;
      case '50%':
        return Colors.blue;
      case '75%':
        return Colors.purple;
      case '100%':
        return ThemeConstants.successGreen;
      default:
        return ThemeConstants.textSecondary;
    }
  }

  IconData _getProgressIcon(String status) {
    switch (status) {
      case '0%':
        return Icons.play_circle_outline;
      case '25%':
        return Icons.trending_up;
      case '50%':
        return Icons.hourglass_empty;
      case '75%':
        return Icons.near_me;
      case '100%':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  void _showAddProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProgressDialog(
        perbaikan: widget.perbaikan,
        onProgressAdded: () {
          _loadProgress();
        },
      ),
    );
  }

  Future<void> _exportToPdf() async {
    final config = await showDialog<pdf_config.PdfConfig>(
      context: context,
      builder: (context) => const PdfConfigDialog(),
    );

    if (config != null) {
      try {
        // Create a list with single perbaikan for PDF service
        final perbaikanList = [widget.perbaikan];
        final dateRange = DateFormat('dd/MM/yyyy').format(widget.perbaikan.tanggal);
        final filterInfo = 'Progress Perbaikan - ${widget.perbaikan.jenisPerbaikan}';
        
        await PdfService().generatePerbaikanPdf(perbaikanList, config, dateRange: dateRange, filterInfo: filterInfo);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF berhasil diekspor'),
              backgroundColor: ThemeConstants.successGreen,
              behavior: SnackBarBehavior.fixed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(ThemeConstants.radiusM)),
              ),
            ),
          );
        }
      } catch (e) {
        ErrorHandler.handleError(context, e, customMessage: 'Gagal membuat PDF');
      }
    }
  }

  void _showDeleteConfirmation(PerbaikanProgress progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus progress ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProgress(progress);
            },
            child: const Text('Hapus', style: TextStyle(color: ThemeConstants.errorRed)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProgress(PerbaikanProgress progress) async {
    try {
      await DatabaseHelper().deletePerbaikanProgress(progress.id!);
      _loadProgress();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress berhasil dihapus'),
            backgroundColor: ThemeConstants.successGreen,
          ),
        );
      }
    } catch (e) {
      ErrorHandler.handleError(context, e, customMessage: 'Gagal menghapus progress');
    }
  }

}

class AddProgressDialog extends StatefulWidget {
  final Perbaikan perbaikan;
  final VoidCallback onProgressAdded;

  const AddProgressDialog({
    super.key,
    required this.perbaikan,
    required this.onProgressAdded,
  });

  @override
  State<AddProgressDialog> createState() => _AddProgressDialogState();
}

class _AddProgressDialogState extends State<AddProgressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  String _statusProgress = '25%';
  String? _fotoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await LocationService().getCurrentLocation();
      setState(() {
        _latitudeController.text = location['latitude'].toString();
        _longitudeController.text = location['longitude'].toString();
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeConstants.backgroundWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeConstants.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 32,
                  color: ThemeConstants.secondary,
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Tambah Progress Perbaikan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 24),
              
              // Status Progress Dropdown
              DropdownButtonFormField<String>(
                value: _statusProgress,
                decoration: const InputDecoration(
                  labelText: 'Status Progress',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_up),
                ),
                items: AppConstants.statusPerbaikanOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _statusProgress = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih status progress';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Deskripsi Progress
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Progress',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan deskripsi progress';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Location
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan latitude';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan longitude';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Foto
              if (_fotoPath != null)
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_fotoPath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Tombol Foto
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(_fotoPath != null ? 'Ganti Foto' : 'Ambil Foto'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tombol
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProgress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.secondary,
                        foregroundColor: ThemeConstants.backgroundWhite,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.backgroundWhite),
                              ),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            SnackBar(
              content: Text('Gagal mengambil foto: $e'),
              backgroundColor: ThemeConstants.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveProgress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final progress = PerbaikanProgress(
          perbaikanId: widget.perbaikan.id!,
          tanggal: DateTime.now(),
          statusProgress: _statusProgress,
          deskripsiProgress: _deskripsiController.text,
          fotoPath: _fotoPath,
          latitude: _latitudeController.text,
          longitude: _longitudeController.text,
        );

        await DatabaseHelper().insertPerbaikanProgress(progress);
        
        if (mounted) {
          Navigator.pop(context);
          widget.onProgressAdded();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progress berhasil ditambahkan'),
              backgroundColor: ThemeConstants.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan progress: $e'),
              backgroundColor: ThemeConstants.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
