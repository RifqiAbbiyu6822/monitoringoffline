import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../constants/app_constants.dart';
import 'common_form_widgets.dart';
import 'reusable_image_picker.dart';

class ReusableFormSections {
  static Widget buildTemuanForm({
    required GlobalKey<FormState> formKey,
    required DateTime tanggal,
    required String jenisTemuan,
    required String jalur,
    required String lajur,
    required TextEditingController kilometerController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required TextEditingController deskripsiController,
    required String? fotoPath,
    required Function(DateTime) onDateChanged,
    required Function(String) onJenisTemuanChanged,
    required Function(String) onJalurChanged,
    required Function(String) onLajurChanged,
    required Function(String?) onImageChanged,
    required VoidCallback onGetLocation,
  }) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal
          CommonFormWidgets.buildDateField(
            label: 'Tanggal',
            value: tanggal,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: formKey.currentContext!,
                initialDate: tanggal,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != tanggal) {
                onDateChanged(picked);
              }
            },
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Jenis Temuan
          CommonFormWidgets.buildDropdownField(
            label: 'Jenis Temuan',
            value: jenisTemuan,
            items: AppConstants.jenisTemuanOptions,
            onChanged: (value) => onJenisTemuanChanged(value!),
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Jalur
          CommonFormWidgets.buildDropdownField(
            label: 'Jalur',
            value: jalur,
            items: AppConstants.jalurOptions,
            onChanged: (value) => onJalurChanged(value!),
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Lajur
          CommonFormWidgets.buildDropdownField(
            label: 'Lajur',
            value: lajur,
            items: AppConstants.lajurOptions,
            onChanged: (value) => onLajurChanged(value!),
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Kilometer
          CommonFormWidgets.buildTextField(
            label: 'Kilometer',
            controller: kilometerController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kilometer harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Koordinat
          CommonFormWidgets.buildGpsSection(
            latitudeController: latitudeController,
            longitudeController: longitudeController,
            onGetLocation: onGetLocation,
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Deskripsi
          CommonFormWidgets.buildTextField(
            label: 'Deskripsi',
            controller: deskripsiController,
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
          ReusableImagePicker(
            imagePath: fotoPath,
            onImageChanged: onImageChanged,
            label: 'Foto Temuan',
            buttonColor: ThemeConstants.primary,
          ),
        ],
      ),
    );
  }

  static Widget buildPerbaikanForm({
    required GlobalKey<FormState> formKey,
    required DateTime tanggal,
    required String jalur,
    required String lajur,
    required String statusPerbaikan,
    required TextEditingController objectIdController,
    required TextEditingController jenisPerbaikanController,
    required TextEditingController kilometerController,
    required TextEditingController latitudeController,
    required TextEditingController longitudeController,
    required TextEditingController deskripsiController,
    required String? fotoPath,
    required Function(DateTime) onDateChanged,
    required Function(String) onJalurChanged,
    required Function(String) onLajurChanged,
    required Function(String) onStatusChanged,
    required Function(String?) onImageChanged,
    required VoidCallback onGetLocation,
  }) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal
          CommonFormWidgets.buildDateField(
            label: 'Tanggal',
            value: tanggal,
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: formKey.currentContext!,
                initialDate: tanggal,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != tanggal) {
                onDateChanged(picked);
              }
            },
          ),
          const SizedBox(height: ThemeConstants.spacingL),

          // ID Objek
          CommonFormWidgets.buildTextField(
            label: 'ID Objek',
            controller: objectIdController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ID objek harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Jenis Perbaikan
          CommonFormWidgets.buildTextField(
            label: 'Jenis Perbaikan',
            controller: jenisPerbaikanController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jenis perbaikan harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Jalur
          CommonFormWidgets.buildDropdownField(
            label: 'Jalur',
            value: jalur,
            items: AppConstants.jalurOptions,
            onChanged: (value) => onJalurChanged(value!),
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Lajur
          CommonFormWidgets.buildDropdownField(
            label: 'Lajur',
            value: lajur,
            items: AppConstants.lajurOptions,
            onChanged: (value) => onLajurChanged(value!),
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Kilometer
          CommonFormWidgets.buildTextField(
            label: 'Kilometer',
            controller: kilometerController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kilometer harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Status Perbaikan
          CommonFormWidgets.buildDropdownField(
            label: 'Status Perbaikan',
            value: statusPerbaikan,
            items: AppConstants.statusPerbaikanOptions,
            onChanged: (value) => onStatusChanged(value!),
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Koordinat
          CommonFormWidgets.buildGpsSection(
            latitudeController: latitudeController,
            longitudeController: longitudeController,
            onGetLocation: onGetLocation,
          ),
          const SizedBox(height: ThemeConstants.spacingL),
          
          // Deskripsi
          CommonFormWidgets.buildTextField(
            label: 'Deskripsi',
            controller: deskripsiController,
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
          ReusableImagePicker(
            imagePath: fotoPath,
            onImageChanged: onImageChanged,
            label: 'Foto Perbaikan',
            buttonColor: ThemeConstants.secondary,
          ),
        ],
      ),
    );
  }
}
