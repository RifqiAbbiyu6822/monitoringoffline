import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'temuan_page.dart';
import 'perbaikan_page.dart';
import 'history_page.dart';
import 'today_temuan_page.dart';
import 'continue_perbaikan_page.dart';
import '../constants/theme_constants.dart';
import '../widgets/temuan_option_dialog.dart';
import '../widgets/perbaikan_option_dialog.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.surfaceGrey,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                decoration: ThemeConstants.cardDecoration.copyWith(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeConstants.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'lib/assets/logo_jjcnormal.png',
                        height: 60,
                        width: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.engineering_outlined,
                            size: 60,
                            color: ThemeConstants.primary,
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    const Text(
                      'Monitoring Jalan Layang MBZ',
                      style: ThemeConstants.heading1,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'Sistem pencatatan dan pelaporan terintegrasi',
                      style: ThemeConstants.bodyMedium.copyWith(color: ThemeConstants.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Menu Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: _buildMenuSection(context),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildExitButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu Utama', style: ThemeConstants.heading3),
        
        const SizedBox(height: 24),
        
        // Menu Grid
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.search_rounded,
                    title: 'Temuan',
                    subtitle: 'Pencatatan anomali',
                    color: ThemeConstants.primary,
                    onTap: () => _showTemuanOptions(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.build_rounded,
                    title: 'Perbaikan',
                    subtitle: 'Pencatatan perbaikan',
                    color: ThemeConstants.secondary,
                    onTap: () => _showPerbaikanOptions(context),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    context,
                    icon: Icons.history_rounded,
                    title: 'History',
                    subtitle: 'Riwayat data',
                    color: ThemeConstants.accentYellow,
                    onTap: () => _navigateWithAnimation(context, const HistoryPage()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200, width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          height: 130, // Increased height to accommodate content
          padding: const EdgeInsets.all(16), // Reduced padding
          decoration: ThemeConstants.cardDecoration.copyWith(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added to prevent expansion
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              
              const Spacer(),
              
              Text(
                title,
                style: ThemeConstants.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1, // Added to prevent text overflow
                overflow: TextOverflow.ellipsis, // Added to handle long text
              ),
              
              const SizedBox(height: 4),
              
              Text(
                subtitle,
                style: ThemeConstants.bodySmall.copyWith(height: 1.2),
                maxLines: 1, // Limit to one line
                overflow: TextOverflow.ellipsis, // Handle text overflow
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showTemuanOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return const TemuanOptionDialog();
      },
    ).then((result) {
      if (result != null) {
        if (result == 'new') {
          _navigateWithAnimation(context, const TemuanPage());
        } else if (result == 'today') {
          _navigateWithAnimation(context, const TodayTemuanPage());
        }
      }
    });
  }

  void _showPerbaikanOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return const PerbaikanOptionDialog();
      },
    ).then((result) {
      if (result != null) {
        if (result == 'new') {
          _navigateWithAnimation(context, const PerbaikanPage());
        } else if (result == 'continue') {
          _navigateWithAnimation(context, const ContinuePerbaikanPage());
        }
      }
    });
  }

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showExitDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            child: Icon(
              Icons.close_rounded,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: const Text(
            'Keluar Aplikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D29),
              letterSpacing: -0.3,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => SystemNavigator.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.errorRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}