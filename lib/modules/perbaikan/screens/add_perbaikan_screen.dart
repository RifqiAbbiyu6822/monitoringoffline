import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme_constants.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/perbaikan_provider.dart';

class AddPerbaikanScreen extends StatefulWidget {
  const AddPerbaikanScreen({super.key});

  @override
  State<AddPerbaikanScreen> createState() => _AddPerbaikanScreenState();
}

class _AddPerbaikanScreenState extends State<AddPerbaikanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaProyekController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaProyekController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.grey50,
      body: Column(
        children: [
          CustomHeader(
            title: 'Buat Proyek Baru',
            subtitle: 'Buat proyek perbaikan dengan dokumentasi progres',
            onBackPressed: () => Navigator.pop(context),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.spacing20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Name Section
                    _buildProjectNameSection(),
                    
                    const SizedBox(height: ThemeConstants.spacing20),
                    
                    // Description Section
                    _buildDescriptionSection(),
                    
                    const SizedBox(height: ThemeConstants.spacing20),
                    
                    // Info Section
                    _buildInfoSection(),
                    
                    const SizedBox(height: ThemeConstants.spacing32),
                    
                    // Create Button
                    if (_isLoading)
                      const LoadingWidget(message: 'Membuat proyek...')
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createProject,
                          child: const Text('Buat Proyek'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectNameSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.build,
                  color: ThemeConstants.primaryBlue,
                  size: ThemeConstants.iconMedium,
                ),
                const SizedBox(width: ThemeConstants.spacing8),
                Text(
                  'Nama Proyek',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacing16),
            
            TextFormField(
              controller: _namaProyekController,
              decoration: const InputDecoration(
                labelText: 'Nama proyek perbaikan',
                hintText: 'Contoh: Perbaikan Jalan Layang KM 15',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama proyek harus diisi';
                }
                if (value.trim().length < 5) {
                  return 'Nama proyek minimal 5 karakter';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description,
                  color: ThemeConstants.primaryBlue,
                  size: ThemeConstants.iconMedium,
                ),
                const SizedBox(width: ThemeConstants.spacing8),
                Text(
                  'Deskripsi (Opsional)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacing16),
            
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi proyek',
                hintText: 'Jelaskan detail perbaikan yang akan dilakukan',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: ThemeConstants.info,
                  size: ThemeConstants.iconMedium,
                ),
                const SizedBox(width: ThemeConstants.spacing8),
                Text(
                  'Informasi Proyek',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.info,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacing12),
            
            Container(
              padding: const EdgeInsets.all(ThemeConstants.spacing12),
              decoration: BoxDecoration(
                color: ThemeConstants.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                border: Border.all(
                  color: ThemeConstants.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setelah proyek dibuat, Anda dapat:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeConstants.info,
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing8),
                  
                  ...[
                    '• Menambahkan foto untuk progres 0%, 50%, dan 100%',
                    '• Setiap foto akan otomatis menyimpan lokasi GPS dan waktu',
                    '• Mengekspor laporan PDF setelah progres mencapai 100%',
                    '• Mengelola dokumentasi lengkap proyek perbaikan',
                  ].map((text) => Padding(
                    padding: const EdgeInsets.only(bottom: ThemeConstants.spacing4),
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeConstants.info,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<PerbaikanProvider>();
    final success = await provider.createPerbaikan(
      namaProyek: _namaProyekController.text.trim(),
      deskripsi: _deskripsiController.text.trim().isEmpty 
          ? null 
          : _deskripsiController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proyek berhasil dibuat'),
            backgroundColor: ThemeConstants.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal membuat proyek'),
            backgroundColor: ThemeConstants.error,
          ),
        );
        provider.clearError();
      }
    }
  }
}
