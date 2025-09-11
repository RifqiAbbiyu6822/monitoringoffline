import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/temuan.dart';
import '../models/perbaikan.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../database/database_helper.dart';
import '../utils/error_handler.dart';
import '../constants/theme_constants.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/pdf_config_dialog.dart';
import '../services/pdf_service.dart';
import 'detail_history_page.dart';

class DateHistoryPage extends StatefulWidget {
  final DateTime selectedDate;
  final String type; // 'temuan' or 'perbaikan'

  const DateHistoryPage({
    super.key,
    required this.selectedDate,
    required this.type,
  });

  @override
  State<DateHistoryPage> createState() => _DateHistoryPageState();
}

class _DateHistoryPageState extends State<DateHistoryPage> {
  List<Temuan> _temuanList = [];
  List<Perbaikan> _perbaikanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.type == 'temuan') {
        final allTemuan = await DatabaseHelper().getAllTemuan();
        _temuanList = allTemuan.where((temuan) {
          return DateFormat('yyyy-MM-dd').format(temuan.tanggal) == 
                 DateFormat('yyyy-MM-dd').format(widget.selectedDate);
        }).toList();
      } else {
        final allPerbaikan = await DatabaseHelper().getAllPerbaikan();
        _perbaikanList = allPerbaikan.where((perbaikan) {
          return DateFormat('yyyy-MM-dd').format(perbaikan.tanggal) == 
                 DateFormat('yyyy-MM-dd').format(widget.selectedDate);
        }).toList();
      }
    } catch (e) {
      ErrorHandler.handleError(context, e, customMessage: 'Gagal memuat data');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final isToday = DateFormat('yyyy-MM-dd').format(widget.selectedDate) == 
                   DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isYesterday = DateFormat('yyyy-MM-dd').format(widget.selectedDate) == 
                       DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));
    
    String dateText;
    if (isToday) {
      dateText = 'Hari Ini';
    } else if (isYesterday) {
      dateText = 'Kemarin';
    } else {
      dateText = dateFormat.format(widget.selectedDate);
    }

    return Scaffold(
      backgroundColor: ThemeConstants.backgroundWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/logoJJCWhite.png',
                height: 24,
                width: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Data $dateText',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ThemeConstants.backgroundWhite,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          backgroundColor: widget.type == 'temuan' 
              ? ThemeConstants.primaryBlue 
              : ThemeConstants.secondaryGreen,
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: ThemeConstants.backgroundWhite),
              onPressed: _exportToPdf,
              tooltip: 'Export PDF',
            ),
          ],
        ),
      ),
      body: _isLoading
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
                  CircularProgressIndicator(
                    color: widget.type == 'temuan' 
                        ? ThemeConstants.primaryBlue 
                        : ThemeConstants.secondaryGreen,
                  ),
                ],
              ),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final dataCount = widget.type == 'temuan' ? _temuanList.length : _perbaikanList.length;
    
    if (dataCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: ThemeConstants.textSecondary,
            ),
            const SizedBox(height: ThemeConstants.spacingM),
            Text(
              'Tidak ada data ${widget.type == 'temuan' ? 'temuan' : 'perbaikan'} pada tanggal ini',
              style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header dengan informasi tanggal dan jumlah data
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(ThemeConstants.spacingM),
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: widget.type == 'temuan' 
                ? ThemeConstants.primaryBlue.withOpacity(0.1)
                : ThemeConstants.secondaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            border: Border.all(
              color: widget.type == 'temuan' 
                  ? ThemeConstants.primaryBlue.withOpacity(0.3)
                  : ThemeConstants.secondaryGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.type == 'temuan' ? Icons.search_outlined : Icons.build_outlined,
                color: widget.type == 'temuan' ? ThemeConstants.primaryBlue : ThemeConstants.secondaryGreen,
                size: 24,
              ),
              const SizedBox(width: ThemeConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(widget.selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.type == 'temuan' ? ThemeConstants.primaryBlue : ThemeConstants.secondaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dataCount ${widget.type == 'temuan' ? 'temuan' : 'perbaikan'} ditemukan',
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
        
        // List data
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
            itemCount: dataCount,
            itemBuilder: (context, index) {
              if (widget.type == 'temuan') {
                return _buildTemuanCard(_temuanList[index]);
              } else {
                return _buildPerbaikanCard(_perbaikanList[index]);
              }
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
            color: ThemeConstants.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          child: const Icon(
            Icons.search_outlined,
            color: ThemeConstants.primaryBlue,
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
              _showDeleteTemuanConfirmation(temuan);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: ThemeConstants.primaryBlue),
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

  Widget _buildPerbaikanCard(Perbaikan perbaikan) {
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: ThemeConstants.cardDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.all(ThemeConstants.spacingM),
        leading: Container(
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: ThemeConstants.secondaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
          ),
          child: const Icon(
            Icons.build_outlined,
            color: ThemeConstants.secondaryGreen,
            size: 24,
          ),
        ),
        title: Text(
          perbaikan.jenisPerbaikan,
          style: ThemeConstants.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ThemeConstants.spacingXS),
            Text(
              perbaikan.deskripsi,
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
                  '${perbaikan.jalur} - ${perbaikan.lajur} (KM ${perbaikan.kilometer})',
                  style: ThemeConstants.bodySmall.copyWith(color: ThemeConstants.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacingXS),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: ThemeConstants.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Status: ${perbaikan.statusPerbaikan}',
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
                  DateFormat('HH:mm').format(perbaikan.tanggal),
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
                    id: perbaikan.id!,
                    type: 'perbaikan',
                  ),
                ),
              );
            } else if (value == 'delete') {
              _showDeletePerbaikanConfirmation(perbaikan);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: ThemeConstants.secondaryGreen),
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
                id: perbaikan.id!,
                type: 'perbaikan',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteTemuanConfirmation(Temuan temuan) {
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

  void _showDeletePerbaikanConfirmation(Perbaikan perbaikan) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: 'Hapus Perbaikan',
          message: 'Apakah Anda yakin ingin menghapus perbaikan ini? Tindakan ini tidak dapat dibatalkan.',
          itemName: perbaikan.jenisPerbaikan,
          itemType: 'perbaikan',
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _deletePerbaikan(perbaikan);
      }
    });
  }

  Future<void> _deleteTemuan(Temuan temuan) async {
    try {
      await DatabaseHelper().deleteTemuan(temuan.id!);
      
      // Remove from local list
      setState(() {
        _temuanList.removeWhere((item) => item.id == temuan.id);
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Temuan berhasil dihapus'),
            backgroundColor: ThemeConstants.successGreen,
            behavior: SnackBarBehavior.floating,
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

  Future<void> _deletePerbaikan(Perbaikan perbaikan) async {
    try {
      await DatabaseHelper().deletePerbaikan(perbaikan.id!);
      
      // Remove from local list
      setState(() {
        _perbaikanList.removeWhere((item) => item.id == perbaikan.id);
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perbaikan berhasil dihapus'),
            backgroundColor: ThemeConstants.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'Gagal menghapus perbaikan');
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
        // Buat informasi tanggal
        final dateRange = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
        
        if (widget.type == 'temuan') {
          if (_temuanList.isNotEmpty) {
            await PdfService().generateTemuanPdf(_temuanList, config, dateRange: dateRange);
          } else {
            _showNoDataMessage('Tidak ada data temuan untuk tanggal ini');
            return;
          }
        } else if (widget.type == 'perbaikan') {
          if (_perbaikanList.isNotEmpty) {
            await PdfService().generatePerbaikanPdf(_perbaikanList, config, dateRange: dateRange);
          } else {
            _showNoDataMessage('Tidak ada data perbaikan untuk tanggal ini');
            return;
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF berhasil diekspor'),
              backgroundColor: ThemeConstants.successGreen,
              behavior: SnackBarBehavior.floating,
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
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(ThemeConstants.radiusM)),
        ),
      ),
    );
  }
}
