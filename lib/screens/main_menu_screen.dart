import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../shared/widgets/custom_header.dart';
import '../modules/temuan/screens/temuan_list_screen.dart';
import '../modules/perbaikan/screens/perbaikan_list_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.grey50,
      body: Column(
        children: [
          const CustomHeader(
            title: 'Monitoring Jalan Layang MBZ',
            subtitle: 'Pilih modul yang ingin digunakan',
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.spacing20),
              child: Column(
                children: [
                  const SizedBox(height: ThemeConstants.spacing20),
                  
                  // Temuan Module Card
                  Expanded(
                    child: _buildModuleCard(
                      context,
                      title: 'Temuan',
                      subtitle: 'Inspeksi Harian',
                      description: 'Catat temuan kerusakan yang ditemukan di lapangan secara harian',
                      icon: Icons.search,
                      color: ThemeConstants.primaryBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TemuanListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spacing16),
                  
                  // Perbaikan Module Card
                  Expanded(
                    child: _buildModuleCard(
                      context,
                      title: 'Perbaikan',
                      subtitle: 'Proyek Perbaikan',
                      description: 'Kelola proyek perbaikan dengan dokumentasi progres tahapan',
                      icon: Icons.build,
                      color: ThemeConstants.accentYellow,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PerbaikanListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ThemeConstants.primaryWhite,
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with icon and title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeConstants.spacing24),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ThemeConstants.radiusLarge),
                  topRight: Radius.circular(ThemeConstants.radiusLarge),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                    ),
                    child: Icon(
                      icon,
                      size: ThemeConstants.iconXLarge,
                      color: color == ThemeConstants.accentYellow 
                          ? ThemeConstants.primaryBlue 
                          : ThemeConstants.primaryWhite,
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spacing16),
                  
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color == ThemeConstants.accentYellow 
                          ? ThemeConstants.primaryBlue 
                          : ThemeConstants.primaryWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spacing4),
                  
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: (color == ThemeConstants.accentYellow 
                          ? ThemeConstants.primaryBlue 
                          : ThemeConstants.primaryWhite).withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.spacing24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ThemeConstants.grey700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: ThemeConstants.spacing24),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.spacing20,
                        vertical: ThemeConstants.spacing12,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Buka Modul',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color == ThemeConstants.accentYellow 
                                  ? ThemeConstants.primaryBlue 
                                  : color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: ThemeConstants.spacing8),
                          Icon(
                            Icons.arrow_forward,
                            size: ThemeConstants.iconSmall,
                            color: color == ThemeConstants.accentYellow 
                                ? ThemeConstants.primaryBlue 
                                : color,
                          ),
                        ],
                      ),
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
