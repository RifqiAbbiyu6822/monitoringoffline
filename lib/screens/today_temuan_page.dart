import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/temuan.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../database/database_helper.dart';
import '../utils/error_handler.dart';
import '../constants/theme_constants.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/pdf_config_dialog.dart';
import '../services/pdf_service.dart';
import 'detail_history_page.dart';
import 'temuan_page.dart';

class TodayTemuanPage extends StatefulWidget {
  const TodayTemuanPage({super.key});

  @override
  State<TodayTemuanPage> createState() => _TodayTemuanPageState();
}

class _TodayTemuanPageState extends State<TodayTemuanPage> {
  List<Temuan> _todayTemuanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayTemuan();
  }

  Future<void> _loadTodayTemuan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allTemuan = await DatabaseHelper().getAllTemuan();
      final today = DateTime.now();
      final todayString = DateFormat('yyyy-MM-dd').format(today);
      
      _todayTemuanList = allTemuan.where((temuan) {
        return DateFormat('yyyy-MM-dd').format(temuan.tanggal) == todayString;
      }).toList();
    } catch (e) {
      ErrorHandler.handleError(context, e, customMessage: 'Gagal memuat data temuan hari ini');
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
                  const CircularProgressIndicator(color: ThemeConstants.primary),
                ],
              ),
            )
          : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _buildNavigationButtons(),
    );
  }

  Widget _buildContent() {
    if (_todayTemuanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeConstants.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: ThemeConstants.primary,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            Text(
              'Belum ada temuan hari ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeConstants.textPrimary,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingS),
            Text(
              'Mulai lakukan pencatatan temuan untuk hari ini',
              style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.spacingXL),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TemuanPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Temuan Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primary,
                foregroundColor: ThemeConstants.backgroundWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header dengan informasi hari ini
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeConstants.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                ),
                child: const Icon(
                  Icons.today,
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
                      'Hari Ini - ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeConstants.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_todayTemuanList.length} temuan ditemukan',
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
        ),
        
        // List temuan hari ini
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
            itemCount: _todayTemuanList.length,
            itemBuilder: (context, index) {
              return _buildTemuanCard(_todayTemuanList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemuanCard(Temuan temuan) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: ThemeConstants.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(ThemeConstants.spacingM),
        leading: Container(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: ThemeConstants.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          child: const Icon(
            Icons.search_outlined,
            color: ThemeConstants.primary,
            size: 24,
          ),
        ),
        title: Text(
          temuan.jenisTemuan,
          style: ThemeConstants.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ThemeConstants.spacingXS),
            Text(
              temuan.deskripsi,
              style: ThemeConstants.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: ThemeConstants.spacingXS),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: ThemeConstants.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${temuan.jalur} - ${temuan.lajur} (KM ${temuan.kilometer})',
                  style: ThemeConstants.bodySmall.copyWith(color: ThemeConstants.textSecondary),
                ),
              ],
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
                  DateFormat('HH:mm').format(temuan.tanggal),
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
            if (value == 'view') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailHistoryPage(
                    id: temuan.id!,
                    type: 'temuan',
                  ),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteConfirmation(temuan);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: ThemeConstants.primary),
                  SizedBox(width: 8),
                  Text('Lihat Detail'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: ThemeConstants.errorRed),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: ThemeConstants.errorRed)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailHistoryPage(
                id: temuan.id!,
                type: 'temuan',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(Temuan temuan) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: 'Hapus Temuan',
          message: 'Apakah Anda yakin ingin menghapus temuan ini? Tindakan ini tidak dapat dibatalkan.',
          itemName: temuan.jenisTemuan,
          itemType: 'temuan',
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteTemuan(temuan);
      }
    });
  }

  Future<void> _deleteTemuan(Temuan temuan) async {
    try {
      await DatabaseHelper().deleteTemuan(temuan.id!);
      
      // Remove from local list
      setState(() {
        _todayTemuanList.removeWhere((item) => item.id == temuan.id);
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Temuan berhasil dihapus'),
            backgroundColor: ThemeConstants.successGreen,
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'Gagal menghapus temuan');
      }
    }
  }

  Future<void> _exportToPdf() async {
    final config = await showDialog<pdf_config.PdfConfig>(
      context: context,
      builder: (context) => const PdfConfigDialog(),
    );

    if (config != null) {
      try {
        // Buat informasi tanggal hari ini
        final dateRange = DateFormat('dd/MM/yyyy').format(DateTime.now());
        final filterInfo = 'Temuan Hari Ini';
        
        if (_todayTemuanList.isNotEmpty) {
          await PdfService().generateTemuanPdf(_todayTemuanList, config, dateRange: dateRange, filterInfo: filterInfo);
        } else {
          _showNoDataMessage('Tidak ada data temuan hari ini untuk diekspor');
          return;
        }
        
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

  void _showNoDataMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ThemeConstants.warningOrange,
              behavior: SnackBarBehavior.fixed,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ThemeConstants.radiusM)),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Export PDF Button
          FloatingActionButton(
            heroTag: "export_pdf",
            onPressed: _exportToPdf,
            backgroundColor: ThemeConstants.primary,
            mini: true,
            child: const Icon(Icons.picture_as_pdf, color: ThemeConstants.backgroundWhite),
            tooltip: 'Export PDF',
          ),
          const SizedBox(height: 8),
          // Back Button
          FloatingActionButton(
            heroTag: "back_button",
            onPressed: () => Navigator.pop(context),
            backgroundColor: ThemeConstants.textSecondary,
            mini: true,
            child: const Icon(Icons.arrow_back, color: ThemeConstants.backgroundWhite),
            tooltip: 'Kembali',
          ),
        ],
      ),
    );
  }
}
