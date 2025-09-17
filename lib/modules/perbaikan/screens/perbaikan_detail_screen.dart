import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/theme_constants.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/photo_viewer.dart';
import '../../../core/services/pdf_service.dart';
import '../providers/perbaikan_provider.dart';
import '../models/perbaikan_foto_model.dart';

class PerbaikanDetailScreen extends StatefulWidget {
  final int perbaikanId;

  const PerbaikanDetailScreen({
    super.key,
    required this.perbaikanId,
  });

  @override
  State<PerbaikanDetailScreen> createState() => _PerbaikanDetailScreenState();
}

class _PerbaikanDetailScreenState extends State<PerbaikanDetailScreen> {
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerbaikanProvider>().loadPerbaikanDetail(widget.perbaikanId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.grey50,
      body: Consumer<PerbaikanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Column(
              children: [
                CustomHeader(title: 'Detail Proyek'),
                Expanded(
                  child: LoadingWidget(message: 'Memuat detail proyek...'),
                ),
              ],
            );
          }

          if (provider.error != null) {
            return Column(
              children: [
                const CustomHeader(title: 'Detail Proyek'),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: ThemeConstants.iconXLarge,
                          color: ThemeConstants.error,
                        ),
                        const SizedBox(height: ThemeConstants.spacing16),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ThemeConstants.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ThemeConstants.spacing16),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.loadPerbaikanDetail(widget.perbaikanId);
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final perbaikan = provider.currentPerbaikan;
          if (perbaikan == null) {
            return const Column(
              children: [
                CustomHeader(title: 'Detail Proyek'),
                Expanded(
                  child: Center(
                    child: Text('Proyek tidak ditemukan'),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              CustomHeader(
                title: perbaikan.namaProyek,
                subtitle: perbaikan.deskripsi ?? 'Proyek perbaikan',
                onBackPressed: () => Navigator.pop(context),
                trailing: provider.canExportPdf()
                    ? IconButton(
                        onPressed: _isExporting ? null : () => _exportPdf(provider),
                        icon: _isExporting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeConstants.primaryWhite,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.picture_as_pdf,
                                color: ThemeConstants.primaryWhite,
                              ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          minimumSize: const Size(48, 48),
                        ),
                      )
                    : null,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ThemeConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Overview
                      _buildProgressOverview(perbaikan),
                      
                      const SizedBox(height: ThemeConstants.spacing20),
                      
                      // Progress Sections
                      _buildProgressSection(provider, 0, 'Progres 0%', 'Kondisi awal sebelum perbaikan'),
                      const SizedBox(height: ThemeConstants.spacing16),
                      
                      _buildProgressSection(provider, 50, 'Progres 50%', 'Kondisi saat perbaikan berlangsung'),
                      const SizedBox(height: ThemeConstants.spacing16),
                      
                      _buildProgressSection(provider, 100, 'Progres 100%', 'Kondisi setelah perbaikan selesai'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressOverview(dynamic perbaikan) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics,
                  color: ThemeConstants.primaryBlue,
                  size: ThemeConstants.iconMedium,
                ),
                const SizedBox(width: ThemeConstants.spacing8),
                Text(
                  'Overview Proyek',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacing16),
            
            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progres Keseluruhan',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  perbaikan.statusText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(perbaikan.status),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacing8),
            
            LinearProgressIndicator(
              value: perbaikan.progressPercentage / 100,
              backgroundColor: ThemeConstants.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(perbaikan.status),
              ),
            ),
            
            const SizedBox(height: ThemeConstants.spacing16),
            
            // Project info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dibuat',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeConstants.grey600,
                        ),
                      ),
                      Text(
                        dateFormat.format(perbaikan.createdDateTime),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terakhir Update',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeConstants.grey600,
                        ),
                      ),
                      Text(
                        dateFormat.format(perbaikan.updatedDateTime),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(PerbaikanProvider provider, int progres, String title, String description) {
    final fotos = provider.getFotoByProgres(progres);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ThemeConstants.spacing8),
                  decoration: BoxDecoration(
                    color: _getProgressColor(progres).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                  ),
                  child: Icon(
                    _getProgressIcon(progres),
                    color: _getProgressColor(progres),
                    size: ThemeConstants.iconMedium,
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeConstants.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _addPhoto(provider, progres),
                  icon: const Icon(Icons.add_a_photo),
                  style: IconButton.styleFrom(
                    backgroundColor: ThemeConstants.accentYellow.withOpacity(0.1),
                    foregroundColor: ThemeConstants.primaryBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacing16),
            
            // Photos grid
            if (fotos.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ThemeConstants.spacing24),
                decoration: BoxDecoration(
                  color: ThemeConstants.grey100,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                  border: Border.all(
                    color: ThemeConstants.grey300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: ThemeConstants.iconLarge,
                      color: ThemeConstants.grey500,
                    ),
                    const SizedBox(height: ThemeConstants.spacing8),
                    Text(
                      'Belum ada foto untuk $title',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ThemeConstants.grey600,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacing4),
                    Text(
                      'Ketuk tombol + untuk menambah foto',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeConstants.grey500,
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: ThemeConstants.spacing8,
                  mainAxisSpacing: ThemeConstants.spacing8,
                ),
                itemCount: fotos.length,
                itemBuilder: (context, index) {
                  final foto = fotos[index];
                  return _buildFotoCard(foto, provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoCard(PerbaikanFotoModel foto, PerbaikanProvider provider) {
    final timeFormat = DateFormat('dd/MM HH:mm', 'id_ID');
    
    return PhotoViewer(
      imagePath: foto.fotoPath,
      title: foto.deskripsi ?? 'Foto ${foto.progresText}',
      subtitle: '${timeFormat.format(foto.dateTime)}\n${foto.locationString}',
      onDelete: () => _showDeleteFotoDialog(foto, provider),
      onTap: () => _showFotoDetail(foto),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return ThemeConstants.error;
      case 1:
        return ThemeConstants.warning;
      case 2:
        return ThemeConstants.success;
      default:
        return ThemeConstants.grey500;
    }
  }

  Color _getProgressColor(int progres) {
    switch (progres) {
      case 0:
        return ThemeConstants.error;
      case 50:
        return ThemeConstants.warning;
      case 100:
        return ThemeConstants.success;
      default:
        return ThemeConstants.grey500;
    }
  }

  IconData _getProgressIcon(int progres) {
    switch (progres) {
      case 0:
        return Icons.play_circle_outline;
      case 50:
        return Icons.update;
      case 100:
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _addPhoto(PerbaikanProvider provider, int progres) async {
    final foto = await provider.takePicture();
    if (foto == null) {
      if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: ThemeConstants.error,
          ),
        );
        provider.clearError();
      }
      return;
    }

    if (mounted) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _AddPhotoDialog(progres: progres),
      );

      if (result != null) {
        final success = await provider.addFotoPerbaikan(
          perbaikanId: widget.perbaikanId,
          foto: foto,
          progres: progres,
          deskripsi: result['deskripsi'],
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto berhasil ditambahkan'),
                backgroundColor: ThemeConstants.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.error ?? 'Gagal menambahkan foto'),
                backgroundColor: ThemeConstants.error,
              ),
            );
            provider.clearError();
          }
        }
      }
    }
  }

  void _showDeleteFotoDialog(PerbaikanFotoModel foto, PerbaikanProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteFotoPerbaikan(
                foto.id!,
                foto.fotoPath,
                widget.perbaikanId,
              );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Foto berhasil dihapus'),
                    backgroundColor: ThemeConstants.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showFotoDetail(PerbaikanFotoModel foto) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeConstants.spacing16),
              decoration: const BoxDecoration(
                color: ThemeConstants.primaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ThemeConstants.radiusMedium),
                  topRight: Radius.circular(ThemeConstants.radiusMedium),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detail Foto ${foto.progresText}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ThemeConstants.primaryWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: ThemeConstants.primaryWhite,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ThemeConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                      child: PhotoViewer(imagePath: foto.fotoPath),
                    ),
                    
                    const SizedBox(height: ThemeConstants.spacing16),
                    
                    if (foto.deskripsi != null && foto.deskripsi!.isNotEmpty) ...[
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.spacing8),
                      Text(
                        foto.deskripsi!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: ThemeConstants.spacing16),
                    ],
                    
                    // Location
                    Text(
                      'Lokasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacing8),
                    Text(
                      foto.locationString,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    
                    const SizedBox(height: ThemeConstants.spacing16),
                    
                    // Timestamp
                    Text(
                      'Waktu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacing8),
                    Text(
                      dateFormat.format(foto.dateTime),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf(PerbaikanProvider provider) async {
    setState(() => _isExporting = true);

    try {
      final perbaikan = provider.currentPerbaikan;
      final fotos = provider.currentFotoList;

      if (perbaikan == null || fotos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada data untuk diekspor'),
              backgroundColor: ThemeConstants.warning,
            ),
          );
        }
        return;
      }

      final pdfService = PdfService();
      final pdfFile = await pdfService.generatePerbaikanPdf(
        perbaikan: perbaikan.toMap(),
        fotoList: fotos.map((f) => f.toMap()).toList(),
        layout: 4, // Default 2x2
      );

      if (mounted) {
        if (pdfFile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF berhasil dibuat: ${pdfFile.path}'),
              backgroundColor: ThemeConstants.success,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membuat PDF'),
              backgroundColor: ThemeConstants.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: ThemeConstants.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}

class _AddPhotoDialog extends StatefulWidget {
  final int progres;

  const _AddPhotoDialog({required this.progres});

  @override
  State<_AddPhotoDialog> createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<_AddPhotoDialog> {
  final _deskripsiController = TextEditingController();

  @override
  void dispose() {
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Foto ${widget.progres}%'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _deskripsiController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi foto (opsional)',
              hintText: 'Jelaskan kondisi pada foto ini',
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'deskripsi': _deskripsiController.text.trim().isEmpty 
                  ? null 
                  : _deskripsiController.text.trim(),
            });
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
