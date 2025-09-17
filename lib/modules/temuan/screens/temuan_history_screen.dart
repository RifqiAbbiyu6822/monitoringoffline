import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/theme_constants.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/photo_viewer.dart';
import '../../../core/services/pdf_service.dart';
import '../providers/temuan_provider.dart';
import '../models/temuan_model.dart';

class TemuanHistoryScreen extends StatefulWidget {
  const TemuanHistoryScreen({super.key});

  @override
  State<TemuanHistoryScreen> createState() => _TemuanHistoryScreenState();
}

class _TemuanHistoryScreenState extends State<TemuanHistoryScreen> {
  String? _selectedDate;
  int _selectedLayout = 4; // Default 2x2
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemuanProvider>().loadAllTemuan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.grey50,
      body: Column(
        children: [
          CustomHeader(
            title: 'Riwayat Temuan',
            subtitle: 'Lihat dan ekspor temuan berdasarkan tanggal',
            onBackPressed: () => Navigator.pop(context),
          ),
          
          Expanded(
            child: Consumer<TemuanProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Memuat riwayat temuan...');
                }

                if (provider.error != null) {
                  return Center(
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
                            provider.loadAllTemuan();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final availableDates = provider.getAvailableDates();
                
                if (availableDates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: ThemeConstants.grey200,
                            borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                          ),
                          child: const Icon(
                            Icons.history,
                            size: ThemeConstants.iconXLarge,
                            color: ThemeConstants.grey500,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacing24),
                        Text(
                          'Belum ada riwayat temuan',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: ThemeConstants.grey600,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacing8),
                        Text(
                          'Riwayat akan muncul setelah Anda menambahkan temuan',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ThemeConstants.grey500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Date Filter and Export Options
                    _buildFilterSection(availableDates, provider),
                    
                    // Temuan List
                    Expanded(
                      child: _buildTemuanList(provider),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<String> availableDates, TemuanProvider provider) {
    return Container(
      margin: const EdgeInsets.all(ThemeConstants.spacing16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Selection
              Text(
                'Filter Tanggal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacing12),
              
              DropdownButtonFormField<String>(
                value: _selectedDate,
                decoration: const InputDecoration(
                  labelText: 'Pilih Tanggal',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Semua Tanggal'),
                  ),
                  ...availableDates.map((date) {
                    final dateTime = DateTime.parse(date);
                    final formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
                    return DropdownMenuItem<String>(
                      value: date,
                      child: Text(formattedDate),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDate = value;
                  });
                },
              ),
              
              if (_selectedDate != null) ...[
                const SizedBox(height: ThemeConstants.spacing16),
                
                // Export Section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Layout PDF',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: ThemeConstants.spacing8),
                          DropdownButtonFormField<int>(
                            value: _selectedLayout,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: ThemeConstants.spacing12,
                                vertical: ThemeConstants.spacing8,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1x1 (1 foto/halaman)')),
                              DropdownMenuItem(value: 2, child: Text('1x2 (2 foto/halaman)')),
                              DropdownMenuItem(value: 4, child: Text('2x2 (4 foto/halaman)')),
                              DropdownMenuItem(value: 6, child: Text('2x3 (6 foto/halaman)')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedLayout = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spacing16),
                    
                    // Export Button
                    Column(
                      children: [
                        const SizedBox(height: ThemeConstants.spacing20),
                        _isExporting
                            ? const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              )
                            : ElevatedButton.icon(
                                onPressed: () => _exportPdf(provider),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Ekspor PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemeConstants.accentYellow,
                                  foregroundColor: ThemeConstants.primaryBlue,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemuanList(TemuanProvider provider) {
    List<TemuanModel> temuanList;
    
    if (_selectedDate != null) {
      final selectedDateTime = DateTime.parse(_selectedDate!);
      temuanList = provider.getTemuanByDate(selectedDateTime);
    } else {
      temuanList = provider.temuanList;
    }

    if (temuanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: ThemeConstants.iconXLarge,
              color: ThemeConstants.grey500,
            ),
            const SizedBox(height: ThemeConstants.spacing16),
            Text(
              _selectedDate != null 
                  ? 'Tidak ada temuan pada tanggal ini'
                  : 'Belum ada temuan',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: ThemeConstants.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(ThemeConstants.spacing16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: ThemeConstants.spacing12,
        mainAxisSpacing: ThemeConstants.spacing12,
      ),
      itemCount: temuanList.length,
      itemBuilder: (context, index) {
        final temuan = temuanList[index];
        return _buildTemuanCard(temuan);
      },
    );
  }

  Widget _buildTemuanCard(TemuanModel temuan) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');
    
    return PhotoViewer(
      imagePath: temuan.fotoPath,
      title: temuan.deskripsi,
      subtitle: '${dateFormat.format(temuan.dateTime)}\n${temuan.locationString}',
      onTap: () => _showTemuanDetail(temuan),
    );
  }

  void _showTemuanDetail(TemuanModel temuan) {
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
                      'Detail Temuan',
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
                      child: PhotoViewer(imagePath: temuan.fotoPath),
                    ),
                    
                    const SizedBox(height: ThemeConstants.spacing16),
                    
                    // Description
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacing8),
                    Text(
                      temuan.deskripsi,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    
                    const SizedBox(height: ThemeConstants.spacing16),
                    
                    // Location
                    Text(
                      'Lokasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacing8),
                    Text(
                      temuan.locationString,
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
                      dateFormat.format(temuan.dateTime),
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

  Future<void> _exportPdf(TemuanProvider provider) async {
    if (_selectedDate == null) return;

    setState(() => _isExporting = true);

    try {
      final selectedDateTime = DateTime.parse(_selectedDate!);
      final temuanList = provider.getTemuanByDate(selectedDateTime);
      
      if (temuanList.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada temuan untuk diekspor'),
              backgroundColor: ThemeConstants.warning,
            ),
          );
        }
        return;
      }

      final pdfService = PdfService();
      final pdfFile = await pdfService.generateTemuanPdf(
        temuanList: temuanList.map((t) => t.toMap()).toList(),
        date: _selectedDate!,
        layout: _selectedLayout,
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
