import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';
import 'constants/app_theme.dart';
import 'modules/temuan/providers/temuan_provider.dart';
import 'modules/perbaikan/providers/perbaikan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemuanProvider()),
        ChangeNotifierProvider(create: (_) => PerbaikanProvider()),
      ],
      child: MaterialApp(
        title: 'Monitoring Jalan Layang MBZ',
        theme: AppTheme.light,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
