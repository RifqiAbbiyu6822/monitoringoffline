import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/theme_constants.dart';
import '../utils/date_utils.dart';

class CommonFormWidgets {
  static Widget buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ThemeConstants.bodyLarge),
        const SizedBox(height: ThemeConstants.spacingS),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            decoration: BoxDecoration(
              border: Border.all(color: ThemeConstants.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              color: ThemeConstants.backgroundWhite,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: ThemeConstants.primary.withOpacity(0.7)),
                const SizedBox(width: ThemeConstants.spacingM),
                Text(AppDateUtils.formatDisplayDate(value), style: ThemeConstants.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ThemeConstants.bodyLarge),
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

  static Widget buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ThemeConstants.bodyLarge),
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

  static Widget buildPhotoSection({
    required String label,
    required String? photoPath,
    required VoidCallback onPickImage,
    required VoidCallback onRemoveImage,
    Color? buttonColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ThemeConstants.bodyLarge),
        const SizedBox(height: ThemeConstants.spacingS),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Ambil Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor ?? ThemeConstants.primary,
                  foregroundColor: ThemeConstants.backgroundWhite,
                  padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                  ),
                ),
              ),
            ),
            if (photoPath != null) ...[
              const SizedBox(width: ThemeConstants.spacingM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRemoveImage,
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
        if (photoPath != null) ...[
          const SizedBox(height: ThemeConstants.spacingM),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: ThemeConstants.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
              child: Image.file(
                File(photoPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Widget buildGpsSection({
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required VoidCallback onGetLocation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Koordinat GPS', style: ThemeConstants.bodyLarge),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: onGetLocation,
              icon: const Icon(Icons.my_location, size: 16),
              label: const Text('Ambil GPS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.secondary,
                foregroundColor: ThemeConstants.backgroundWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.spacingM,
                  vertical: ThemeConstants.spacingS,
                ),
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
              child: buildTextField(
                label: 'Latitude',
                controller: latitudeController,
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
              child: buildTextField(
                label: 'Longitude',
                controller: longitudeController,
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
    );
  }

  static Widget buildFormCard({
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget buildSaveButton({
    required VoidCallback onPressed,
    required String text,
    Color? backgroundColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? ThemeConstants.secondary,
        foregroundColor: ThemeConstants.backgroundWhite,
        padding: const EdgeInsets.symmetric(vertical: ThemeConstants.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
        ),
        elevation: 2,
      ),
      child: Text(
        text,
        style: ThemeConstants.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
