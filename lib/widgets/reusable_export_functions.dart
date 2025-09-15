import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../database/database_helper.dart';
import '../services/pdf_service.dart';
import '../widgets/pdf_config_dialog.dart';
import '../widgets/export_confirmation_dialog.dart';
import '../widgets/export_dialog.dart';
import 'reusable_snackbar_helper.dart';
import '../utils/date_utils.dart';

class ReusableExportFunctions {
  static Future<void> exportTemuanToPdf(
    BuildContext context,
    DateTime selectedDate,
  ) async {
    try {
      // Ambil data temuan untuk tanggal yang dipilih
      final temuanList = await DatabaseHelper().getTemuanByDate(selectedDate);
      
      // Tampilkan dialog konfirmasi export
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ExportConfirmationDialog(
          temuanList: temuanList,
          exportType: 'temuan',
          dateRange: AppDateUtils.formatShortDate(selectedDate),
        ),
      );

      if (confirmed == true) {
        // Tampilkan dialog konfigurasi PDF
        final config = await showDialog(
          context: context,
          builder: (context) => const PdfConfigDialog(),
        );

        if (config != null) {
          // Generate PDF
          await PdfService().generateTemuanPdf(
            temuanList, 
            config,
            dateRange: AppDateUtils.formatShortDate(selectedDate),
          );
          
          if (context.mounted) {
            ReusableSnackbarHelper.showSuccess(
              context,
              'PDF berhasil diekspor (${temuanList.length} data)',
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ReusableSnackbarHelper.showError(
          context,
          'Gagal membuat PDF: ${e.toString()}',
        );
      }
    }
  }

  static Future<void> exportPerbaikanToPdf(
    BuildContext context,
    DateTime selectedDate,
  ) async {
    try {
      // Ambil data perbaikan untuk tanggal yang dipilih
      final perbaikanList = await DatabaseHelper().getPerbaikanByDate(selectedDate);
      
      // Tampilkan dialog konfirmasi export
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ExportConfirmationDialog(
          perbaikanList: perbaikanList,
          exportType: 'perbaikan',
          dateRange: DateFormat('dd/MM/yyyy').format(selectedDate),
        ),
      );

      if (confirmed == true) {
        // Tampilkan dialog konfigurasi PDF
        final config = await showDialog(
          context: context,
          builder: (context) => const PdfConfigDialog(),
        );

        if (config != null) {
          // Generate PDF
          await PdfService().generatePerbaikanPdf(
            perbaikanList, 
            config,
            dateRange: DateFormat('dd/MM/yyyy').format(selectedDate),
          );
          
          if (context.mounted) {
            ReusableSnackbarHelper.showSuccess(
              context,
              'PDF berhasil diekspor (${perbaikanList.length} data)',
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ReusableSnackbarHelper.showError(
          context,
          'Gagal membuat PDF: ${e.toString()}',
        );
      }
    }
  }

  static void showExportDialog(
    BuildContext context,
    List<Temuan> temuanList,
    List<Perbaikan> perbaikanList,
  ) {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(
        temuanList: temuanList,
        perbaikanList: perbaikanList,
      ),
    );
  }

  static Future<void> exportAllDataToPdf(
    BuildContext context,
    List<Temuan> temuanList,
    List<Perbaikan> perbaikanList,
  ) async {
    try {
      // Tampilkan dialog konfigurasi PDF
      final config = await showDialog(
        context: context,
        builder: (context) => const PdfConfigDialog(),
      );

      if (config != null) {
        // Generate PDF untuk temuan dan perbaikan secara terpisah
        if (temuanList.isNotEmpty) {
          await PdfService().generateTemuanPdf(
            temuanList,
            config,
            dateRange: 'Semua Data',
          );
        }
        
        if (perbaikanList.isNotEmpty) {
          await PdfService().generatePerbaikanPdf(
            perbaikanList,
            config,
            dateRange: 'Semua Data',
          );
        }
        
        if (context.mounted) {
          ReusableSnackbarHelper.showSuccess(
            context,
            'PDF berhasil diekspor (${temuanList.length + perbaikanList.length} data)',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ReusableSnackbarHelper.showError(
          context,
          'Gagal membuat PDF: ${e.toString()}',
        );
      }
    }
  }
}
