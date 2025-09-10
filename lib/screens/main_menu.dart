import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'temuan_page.dart';
import 'perbaikan_page.dart';
import 'history_page.dart';
import '../constants/theme_constants.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundWhite,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Text(
            'Jasa Marga Mobile',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ThemeConstants.backgroundWhite,
              fontSize: 20,
            ),
          ),
          backgroundColor: ThemeConstants.primaryBlue,
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingL, vertical: ThemeConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),
                
                const SizedBox(height: ThemeConstants.spacingXL),
                
                // Menu Cards
                _buildMenuCards(context),
                
                const SizedBox(height: ThemeConstants.spacingL),
                
                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingL),
      decoration: ThemeConstants.surfaceDecoration,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConstants.spacingM),
            decoration: BoxDecoration(
              color: ThemeConstants.primaryBlue,
              borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
            ),
            child: const Icon(
              Icons.engineering_outlined,
              size: 32,
              color: ThemeConstants.backgroundWhite,
            ),
          ),
          const SizedBox(height: ThemeConstants.spacingM),
          const Text(
            'Monitoring Jalan Tol MBZ',
            style: ThemeConstants.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ThemeConstants.spacingXS),
          Text(
            'Aplikasi Offline untuk Pencatatan',
            style: TextStyle(
              fontSize: 14,
              color: ThemeConstants.primaryBlue.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu Utama',
          style: ThemeConstants.heading3,
        ),
        const SizedBox(height: ThemeConstants.spacingM),
        
        _buildMenuCard(
          context,
          icon: Icons.search_outlined,
          title: 'Temuan',
          subtitle: 'Pencatatan temuan atau anomali',
          color: ThemeConstants.primaryBlue,
          onTap: () => _navigateWithAnimation(context, const TemuanPage()),
        ),
        
        const SizedBox(height: ThemeConstants.spacingM),
        
        _buildMenuCard(
          context,
          icon: Icons.build_outlined,
          title: 'Perbaikan',
          subtitle: 'Pencatatan perbaikan yang telah dilakukan',
          color: ThemeConstants.secondaryGreen,
          onTap: () => _navigateWithAnimation(context, const PerbaikanPage()),
        ),
        
        const SizedBox(height: ThemeConstants.spacingM),
        
        _buildMenuCard(
          context,
          icon: Icons.history_outlined,
          title: 'History',
          subtitle: 'Lihat riwayat data temuan dan perbaikan',
          color: ThemeConstants.accentYellow,
          onTap: () => _navigateWithAnimation(context, const HistoryPage()),
        ),
        
        const SizedBox(height: ThemeConstants.spacingM),
        
        _buildMenuCard(
          context,
          icon: Icons.exit_to_app_outlined,
          title: 'Keluar',
          subtitle: 'Menutup aplikasi',
          color: ThemeConstants.errorRed,
          onTap: () => _showExitDialog(context),
        ),
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
        borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ThemeConstants.spacingM),
          decoration: BoxDecoration(
            color: ThemeConstants.backgroundWhite,
            borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConstants.spacingM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: ThemeConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.spacingXS),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeConstants.primaryBlue.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConstants.spacingM),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
      ),
      child: Text(
        '© 2024 Jasa Marga - Monitoring Jalan Tol',
        style: TextStyle(
          fontSize: 12,
          color: ThemeConstants.primaryBlue.withOpacity(0.6),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
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

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeConstants.backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.radiusL),
          ),
          title: const Text(
            'Konfirmasi Keluar',
            style: ThemeConstants.heading3,
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              color: ThemeConstants.primaryBlue.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: ThemeConstants.primaryBlue.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => SystemNavigator.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.errorRed,
                foregroundColor: ThemeConstants.backgroundWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.radiusM),
                ),
                padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.spacingL, vertical: ThemeConstants.spacingM),
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}