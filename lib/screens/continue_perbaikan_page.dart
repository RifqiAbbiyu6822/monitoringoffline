import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/perbaikan.dart';
import '../database/database_helper.dart';
import '../utils/error_handler.dart';
import '../constants/theme_constants.dart';
import 'detail_history_page.dart';
import 'perbaikan_page.dart';
import 'perbaikan_progress_page.dart';
import '../models/pdf_config.dart' as pdf_config;
import '../services/pdf_service.dart';
import '../widgets/pdf_config_dialog.dart';

class ContinuePerbaikanPage extends StatefulWidget {
  const ContinuePerbaikanPage({super.key});

  @override
  State<ContinuePerbaikanPage> createState() => _ContinuePerbaikanPageState();
}

class _ContinuePerbaikanPageState extends State<ContinuePerbaikanPage> {
  Map<String, List<Perbaikan>> _incompletePerbaikanMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIncompletePerbaikan();
  }

  Future<void> _loadIncompletePerbaikan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allPerbaikan = await DatabaseHelper().getAllPerbaikan();
      // Group perbaikan by object ID and filter out completed ones
      _incompletePerbaikanMap = {};
      for (var perbaikan in allPerbaikan) {
        if (perbaikan.statusPerbaikan != '100%') {
          if (!_incompletePerbaikanMap.containsKey(perbaikan.objectId)) {
            _incompletePerbaikanMap[perbaikan.objectId] = [];
          }
          _incompletePerbaikanMap[perbaikan.objectId]!.add(perbaikan);
        }
      }
      
      // Sort each group by date
      for (var repairs in _incompletePerbaikanMap.values) {
        repairs.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      }
    } catch (e) {
      ErrorHandler.handleError(context, e, customMessage: 'Gagal memuat data perbaikan');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: ThemeConstants.backgroundWhite,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: ThemeConstants.secondaryGreen,
            elevation: 0,
            toolbarHeight: 0,
          ),
        ),
        body: Column(
          children: [
            // Custom Header
            Container(
              color: ThemeConstants.secondaryGreen,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Row(
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
                      const Text(
                        'Lanjutkan Perbaikan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ThemeConstants.backgroundWhite,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                        const CircularProgressIndicator(color: ThemeConstants.secondaryGreen),
                      ],
                    ),
                  )
                : _buildContent(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "back_button",
          onPressed: () => Navigator.pop(context),
          backgroundColor: ThemeConstants.textSecondary,
          mini: true,
          child: const Icon(Icons.arrow_back, color: ThemeConstants.backgroundWhite),
          tooltip: 'Kembali',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildObjectCard(String objectId, List<Perbaikan> repairs) {
    final latestRepair = repairs.first; // Repairs are already sorted by date
    return Container(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacingM),
      decoration: ThemeConstants.cardDecoration,
      child: ExpansionTile(
        title: Text(
          'Objek: $objectId',
          style: ThemeConstants.heading3,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: ThemeConstants.spacingXS),
            Text(
              'Status Terakhir: ${latestRepair.statusPerbaikan}',
              style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
            ),
            Text(
              'Lokasi: ${latestRepair.jalur} - ${latestRepair.lajur} (KM ${latestRepair.kilometer})',
              style: ThemeConstants.bodySmall.copyWith(color: ThemeConstants.textSecondary),
            ),
          ],
        ),
        children: repairs.map((repair) => _buildPerbaikanCard(repair)).toList(),
      ),
    );
  }

  Widget _buildContent() {
    if (_incompletePerbaikanMap.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ThemeConstants.secondaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 64,
                color: ThemeConstants.secondaryGreen,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingL),
            Text(
              'Semua perbaikan sudah selesai!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeConstants.textPrimary,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacingS),
            Text(
              'Tidak ada perbaikan yang perlu dilanjutkan',
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
                    builder: (context) => const PerbaikanPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Perbaikan Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.secondaryGreen,
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
        // Header dengan informasi perbaikan yang belum selesai
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(ThemeConstants.spacingM),
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: ThemeConstants.secondaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
            border: Border.all(
              color: ThemeConstants.secondaryGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
              const SizedBox(width: ThemeConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Perbaikan Belum Selesai',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeConstants.secondaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_incompletePerbaikanMap.length} objek memerlukan perbaikan',
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
        
        // List objek yang memerlukan perbaikan
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingM),
            itemCount: _incompletePerbaikanMap.length,
            itemBuilder: (context, index) {
              String objectId = _incompletePerbaikanMap.keys.elementAt(index);
              List<Perbaikan> repairs = _incompletePerbaikanMap[objectId]!;
              return _buildObjectCard(objectId, repairs);
            },
          ),
        ),
      ],
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
                  Icons.trending_up_outlined,
                  size: 16,
                  color: ThemeConstants.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Progress: ${perbaikan.statusPerbaikan}',
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
                  DateFormat('dd MMM yyyy, HH:mm').format(perbaikan.tanggal),
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
            } else if (value == 'continue') {
              _continuePerbaikan(perbaikan);
            } else if (value == 'progress') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PerbaikanProgressPage(perbaikan: perbaikan),
                ),
              );
            } else if (value == 'export') {
              _exportToPdf(perbaikan);
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
              value: 'progress',
              child: Row(
                children: [
                  Icon(Icons.timeline, color: ThemeConstants.primaryBlue),
                  SizedBox(width: 8),
                  Text('Lihat Progress'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'continue',
              child: Row(
                children: [
                  Icon(Icons.edit, color: ThemeConstants.primaryBlue),
                  SizedBox(width: 8),
                  Text('Lanjutkan Perbaikan'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: ThemeConstants.secondaryGreen),
                  SizedBox(width: 8),
                  Text('Export PDF'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          _continuePerbaikan(perbaikan);
        },
      ),
    );
  }

  void _continuePerbaikan(Perbaikan perbaikan) {
    // Navigate to perbaikan page with existing data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerbaikanPage(existingPerbaikan: perbaikan),
      ),
    ).then((_) {
      // Refresh the list when returning
      _loadIncompletePerbaikan();
    });
  }

  Future<void> _exportToPdf(Perbaikan perbaikan) async {
    final config = await showDialog<pdf_config.PdfConfig>(
      context: context,
      builder: (context) => const PdfConfigDialog(),
    );

    if (config != null) {
      try {
        // Create a list with single perbaikan for PDF service
        final perbaikanList = [perbaikan];
        final dateRange = DateFormat('dd/MM/yyyy').format(perbaikan.tanggal);
        final filterInfo = 'Perbaikan Individual - ${perbaikan.jenisPerbaikan}';
        
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
}