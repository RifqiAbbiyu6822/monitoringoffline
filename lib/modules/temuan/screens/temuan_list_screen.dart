import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/theme_constants.dart';
import '../../../shared/widgets/custom_header.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/photo_viewer.dart';
import '../providers/temuan_provider.dart';
import '../models/temuan_model.dart';
import 'add_temuan_screen.dart';
import 'temuan_history_screen.dart';

class TemuanListScreen extends StatefulWidget {
  const TemuanListScreen({super.key});

  @override
  State<TemuanListScreen> createState() => _TemuanListScreenState();
}

class _TemuanListScreenState extends State<TemuanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemuanProvider>().loadTodayTemuan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.grey50,
      body: Column(
        children: [
          CustomHeader(
            title: 'Temuan Hari Ini',
            subtitle: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
            onBackPressed: () => Navigator.pop(context),
            trailing: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TemuanHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.history,
                color: ThemeConstants.primaryWhite,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
          
          Expanded(
            child: Consumer<TemuanProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Memuat data temuan...');
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
                            provider.loadTodayTemuan();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.todayTemuanList.isEmpty) {
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
                            Icons.search_off,
                            size: ThemeConstants.iconXLarge,
                            color: ThemeConstants.grey500,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacing24),
                        Text(
                          'Belum ada temuan hari ini',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: ThemeConstants.grey600,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacing8),
                        Text(
                          'Mulai dengan menambahkan temuan pertama',
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
                  onRefresh: () => provider.loadTodayTemuan(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(ThemeConstants.spacing16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: ThemeConstants.spacing12,
                      mainAxisSpacing: ThemeConstants.spacing12,
                    ),
                    itemCount: provider.todayTemuanList.length,
                    itemBuilder: (context, index) {
                      final temuan = provider.todayTemuanList[index];
                      return _buildTemuanCard(context, temuan, provider);
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
              builder: (context) => const AddTemuanScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Tambah Temuan'),
      ),
    );
  }

  Widget _buildTemuanCard(BuildContext context, TemuanModel temuan, TemuanProvider provider) {
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    
    return PhotoViewer(
      imagePath: temuan.fotoPath,
      title: temuan.deskripsi,
      subtitle: '${timeFormat.format(temuan.dateTime)}\n${temuan.locationString}',
      onDelete: () => _showDeleteDialog(context, temuan, provider),
      onTap: () => _showTemuanDetail(context, temuan),
    );
  }

  void _showDeleteDialog(BuildContext context, TemuanModel temuan, TemuanProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Temuan'),
        content: const Text('Apakah Anda yakin ingin menghapus temuan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteTemuan(temuan.id!, temuan.fotoPath);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Temuan berhasil dihapus'),
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

  void _showTemuanDetail(BuildContext context, TemuanModel temuan) {
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
}
