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
      backgroundColor: ThemeConstants.backgroundWhite,
       appBar: PreferredSize(
         preferredSize: const Size.fromHeight(70),
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
               const Text(
                 'Jasa Marga Mobile',
                 style: TextStyle(
                   fontWeight: FontWeight.w500,
                   color: ThemeConstants.backgroundWhite,
                   fontSize: 18,
                   letterSpacing: 0.2,
                 ),
               ),
             ],
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
            padding: const EdgeInsets.all(ThemeConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: ThemeConstants.spacingM),
                
                // Header Section
                _buildHeaderSection(),
                
                const SizedBox(height: 32),
                
                // Menu Cards
                _buildMenuCards(context),
                
                const SizedBox(height: 40),
                
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: ThemeConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        children: [
          Image.asset(
            'lib/assets/logo_jjcnormal.png',
            height: 100,
            width: 160,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.engineering_outlined,
                size: 80,
                color: ThemeConstants.primaryBlue,
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitoring Jalan Layang MBZ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Aplikasi untuk pencatatan dan pelaporan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        _buildMenuCard(
          context,
          icon: Icons.search_rounded,
          title: 'Temuan',
          subtitle: 'Pencatatan temuan atau anomali',
          color: ThemeConstants.primaryBlue,
          onTap: () => _showTemuanOptions(context),
        ),
        
        const SizedBox(height: 16),
        
        _buildMenuCard(
          context,
          icon: Icons.build_rounded,
          title: 'Perbaikan',
          subtitle: 'Pencatatan perbaikan yang telah dilakukan',
          color: ThemeConstants.secondaryGreen,
          onTap: () => _showPerbaikanOptions(context),
        ),
        
        const SizedBox(height: 16),
        
        _buildMenuCard(
          context,
          icon: Icons.history_rounded,
          title: 'History',
          subtitle: 'Lihat riwayat data temuan dan perbaikan',
          color: ThemeConstants.accentYellow,
          onTap: () => _navigateWithAnimation(context, const HistoryPage()),
        ),
        
        const SizedBox(height: 16),
        
        _buildMenuCard(
          context,
          icon: Icons.logout_rounded,
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
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeConstants.backgroundWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 6,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade600,
                  size: 14,
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.copyright_rounded,
            size: 14,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 6),
          Text(
            '2024 Jasa Marga - Monitoring Jalan Tol',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  void _showTemuanOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
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
      barrierColor: Colors.black.withOpacity(0.4),
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

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeConstants.backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Text(
            'Konfirmasi Keluar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: -0.1,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => SystemNavigator.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.errorRed,
                foregroundColor: ThemeConstants.backgroundWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}