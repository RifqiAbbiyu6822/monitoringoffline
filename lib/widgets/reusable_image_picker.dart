import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/theme_constants.dart';

class ReusableImagePicker extends StatefulWidget {
  final String? imagePath;
  final Function(String?) onImageChanged;
  final String label;
  final Color? buttonColor;
  final double? imageHeight;
  final double? imageWidth;
  final BoxFit imageFit;

  const ReusableImagePicker({
    super.key,
    this.imagePath,
    required this.onImageChanged,
    required this.label,
    this.buttonColor = ThemeConstants.primary,
    this.imageHeight = 200,
    this.imageWidth = double.infinity,
    this.imageFit = BoxFit.cover,
  });

  @override
  State<ReusableImagePicker> createState() => _ReusableImagePickerState();
}

class _ReusableImagePickerState extends State<ReusableImagePicker> {
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
          widget.onImageChanged(image.path);
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
  }

  void _removeImage() {
    widget.onImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
                  backgroundColor: widget.buttonColor,
                  foregroundColor: ThemeConstants.backgroundWhite,
                  padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  ),
                ),
              ),
            ),
            if (widget.imagePath != null) ...[
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
        if (widget.imagePath != null) ...[
          const SizedBox(height: ThemeConstants.spacingM),
          Container(
            height: widget.imageHeight,
            width: widget.imageWidth,
            decoration: BoxDecoration(
              border: Border.all(color: widget.buttonColor!.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              child: Image.file(
                File(widget.imagePath!),
                fit: widget.imageFit,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
