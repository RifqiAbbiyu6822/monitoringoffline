import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/theme_constants.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/temuan_provider.dart';

class AddTemuanScreen extends StatefulWidget {
  const AddTemuanScreen({super.key});

  @override
  State<AddTemuanScreen> createState() => _AddTemuanScreenState();
}

class _AddTemuanScreenState extends State<AddTemuanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deskripsiController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
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
            title: 'Tambah Temuan',
            subtitle: 'Catat temuan kerusakan yang ditemukan',
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
                    // Photo Section
                    _buildPhotoSection(),
                    
                    const SizedBox(height: ThemeConstants.spacing24),
                    
                    // Description Section
                    _buildDescriptionSection(),
                    
                    const SizedBox(height: ThemeConstants.spacing32),
                    
                    // Save Button
                    if (_isLoading)
                      const LoadingWidget(message: 'Menyimpan temuan...')
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedImage != null ? _saveTemuan : null,
                          child: const Text('Simpan Temuan'),
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

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: ThemeConstants.primaryBlue,
                  size: ThemeConstants.iconMedium,
                ),
                const SizedBox(width: ThemeConstants.spacing8),
                Text(
                  'Foto Temuan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: ThemeConstants.spacing16),
            
            if (_selectedImage != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _takePicture,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Ambil Ulang'),
                        ),
                      ),
                      const SizedBox(width: ThemeConstants.spacing12),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const Icon(Icons.delete_outline, color: ThemeConstants.error),
                          label: const Text('Hapus', style: TextStyle(color: ThemeConstants.error)),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: ThemeConstants.grey100,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                  border: Border.all(
                    color: ThemeConstants.grey300,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: _takePicture,
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: ThemeConstants.iconXLarge,
                        color: ThemeConstants.grey500,
                      ),
                      SizedBox(height: ThemeConstants.spacing8),
                      Text(
                        'Ketuk untuk mengambil foto',
                        style: TextStyle(
                          color: ThemeConstants.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
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
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: ThemeConstants.info,
                    size: ThemeConstants.iconSmall,
                  ),
                  const SizedBox(width: ThemeConstants.spacing8),
                  Expanded(
                    child: Text(
                      'Foto akan otomatis menyimpan data GPS dan waktu pengambilan',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ThemeConstants.info,
                      ),
                    ),
                  ),
                ],
              ),
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
                  'Deskripsi Temuan',
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
                labelText: 'Deskripsi singkat temuan',
                hintText: 'Contoh: Retak di permukaan jalan, Lubang kecil, Marka jalan pudar',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Deskripsi temuan harus diisi';
                }
                if (value.trim().length < 10) {
                  return 'Deskripsi minimal 10 karakter';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    final provider = context.read<TemuanProvider>();
    final image = await provider.takePicture();
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    } else if (provider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: ThemeConstants.error,
          ),
        );
        provider.clearError();
      }
    }
  }

  Future<void> _saveTemuan() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<TemuanProvider>();
    final success = await provider.addTemuan(
      deskripsi: _deskripsiController.text.trim(),
      foto: _selectedImage!,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Temuan berhasil disimpan'),
            backgroundColor: ThemeConstants.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Gagal menyimpan temuan'),
            backgroundColor: ThemeConstants.error,
          ),
        );
        provider.clearError();
      }
    }
  }
}
