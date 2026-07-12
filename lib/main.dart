import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_page.dart';
import 'services/notification_service.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://cglpopnrinpghbuvckrx.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNnbHBvcG5yaW5wZ2hidXZja3J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3MTM0MzAsImV4cCI6MjA5NzI4OTQzMH0.rzcw0u7QD5leMj8SNweo5A2fylvDiCq0bBaU5-BbOhc',
    );
  } catch (error, stackTrace) {
    debugPrint('SUPABASE INITIALIZATION ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const GeniusAqilOS());
}

class GeniusAqilOS extends StatefulWidget {
  const GeniusAqilOS({super.key});

  @override
  State<GeniusAqilOS> createState() => _GeniusAqilOSState();
}

class _GeniusAqilOSState extends State<GeniusAqilOS> {
  @override
  void initState() {
    super.initState();

    // Initialize notifications after the first screen starts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.instance
          .initialize()
          .timeout(const Duration(seconds: 10));

      debugPrint('NOTIFICATIONS INITIALIZED');
    } catch (error, stackTrace) {
      debugPrint('NOTIFICATION INITIALIZATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genius Aqil OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        textTheme: TextTheme(
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.body,
          titleLarge: AppTextStyles.heading,
        ),
      ),
      home: const LoginPage(),
    );
  }
}