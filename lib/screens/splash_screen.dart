import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';
import '../shared/widgets/loading_widget.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainMenu();
  }

  _navigateToMainMenu() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.primaryBlue,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryWhite,
                      borderRadius: BorderRadius.circular(ThemeConstants.radiusXLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.construction,
                      size: ThemeConstants.iconXLarge + 16,
                      color: ThemeConstants.primaryBlue,
                    ),
                  ),
                  
                  const SizedBox(height: ThemeConstants.spacing32),
                  
                  // App Title
                  Text(
                    'Monitoring Jalan Layang MBZ',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: ThemeConstants.primaryWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: ThemeConstants.spacing8),
                  
                  Text(
                    'Sistem Pemeliharaan Jalan Tol',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ThemeConstants.primaryWhite.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          // Loading indicator
          const Padding(
            padding: EdgeInsets.all(ThemeConstants.spacing32),
            child: LoadingWidget(
              message: 'Memuat aplikasi...',
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
