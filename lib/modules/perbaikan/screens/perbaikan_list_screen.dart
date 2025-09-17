import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/theme_constants.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/perbaikan_provider.dart';
import '../models/perbaikan_model.dart';
import 'add_perbaikan_screen.dart';
import 'perbaikan_detail_screen.dart';

class PerbaikanListScreen extends StatefulWidget {
  const PerbaikanListScreen({super.key});

  @override
  State<PerbaikanListScreen> createState() => _PerbaikanListScreenState();
}

class _PerbaikanListScreenState extends State<PerbaikanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerbaikanProvider>().loadAllPerbaikan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.grey50,
      body: Column(
        children: [
          CustomHeader(
            title: 'Proyek Perbaikan',
            subtitle: 'Kelola proyek perbaikan dengan dokumentasi progres',
            onBackPressed: () => Navigator.pop(context),
          ),
          
          Expanded(
            child: Consumer<PerbaikanProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Memuat proyek perbaikan...');
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
                            provider.loadAllPerbaikan();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.perbaikanList.isEmpty) {
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
                            Icons.build_circle_outlined,
                            size: ThemeConstants.iconXLarge,
                            color: ThemeConstants.grey500,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacing24),
                        Text(
                          'Belum ada proyek perbaikan',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: ThemeConstants.grey600,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacing8),
                        Text(
                          'Mulai dengan membuat proyek perbaikan pertama',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ThemeConstants.grey500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadAllPerbaikan(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(ThemeConstants.spacing16),
                    itemCount: provider.perbaikanList.length,
                    itemBuilder: (context, index) {
                      final perbaikan = provider.perbaikanList[index];
                      return _buildPerbaikanCard(context, perbaikan, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPerbaikanScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Proyek'),
      ),
    );
  }

  Widget _buildPerbaikanCard(BuildContext context, PerbaikanModel perbaikan, PerbaikanProvider provider) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    
    return Card(
      margin: const EdgeInsets.only(bottom: ThemeConstants.spacing12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PerbaikanDetailScreen(perbaikanId: perbaikan.id!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(ThemeConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and menu
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perbaikan.namaProyek,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (perbaikan.deskripsi != null && perbaikan.deskripsi!.isNotEmpty) ...[
                          const SizedBox(height: ThemeConstants.spacing4),
                          Text(
                            perbaikan.deskripsi!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: ThemeConstants.grey600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context, perbaikan, provider);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: ThemeConstants.error),
                            SizedBox(width: ThemeConstants.spacing8),
                            Text('Hapus Proyek'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: ThemeConstants.spacing16),
              
              // Progress indicator
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progres',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: ThemeConstants.grey600,
                              ),
                            ),
                            Text(
                              perbaikan.statusText,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(perbaikan.status),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: ThemeConstants.spacing8),
                        LinearProgressIndicator(
                          value: perbaikan.progressPercentage / 100,
                          backgroundColor: ThemeConstants.grey200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(perbaikan.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ThemeConstants.spacing16),
                  
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConstants.spacing12,
                      vertical: ThemeConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(perbaikan.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                      border: Border.all(
                        color: _getStatusColor(perbaikan.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusText(perbaikan.status),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(perbaikan.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: ThemeConstants.spacing12),
              
              // Footer with dates
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: ThemeConstants.iconSmall,
                    color: ThemeConstants.grey500,
                  ),
                  const SizedBox(width: ThemeConstants.spacing4),
                  Text(
                    'Dibuat: ${dateFormat.format(perbaikan.createdDateTime)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ThemeConstants.grey500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: ThemeConstants.iconSmall,
                    color: ThemeConstants.grey400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return ThemeConstants.error;
      case 1:
        return ThemeConstants.warning;
      case 2:
        return ThemeConstants.success;
      default:
        return ThemeConstants.grey500;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Mulai';
      case 1:
        return 'Progres';
      case 2:
        return 'Selesai';
      default:
        return 'Unknown';
    }
  }

  void _showDeleteDialog(BuildContext context, PerbaikanModel perbaikan, PerbaikanProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Proyek'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus proyek "${perbaikan.namaProyek}"?'),
            const SizedBox(height: ThemeConstants.spacing8),
            const Text(
              'Semua foto dan data terkait akan ikut terhapus.',
              style: TextStyle(
                color: ThemeConstants.error,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deletePerbaikan(perbaikan.id!);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Proyek berhasil dihapus'),
                    backgroundColor: ThemeConstants.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
