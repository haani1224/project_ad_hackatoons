import 'package:flutter/material.dart';
import 'package:project_ad_hackatoons/features/auth/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_constants.dart';
import 'core/theme/app_theme.dart';
// import 'features/teachers/teacher_list_page.dart';
// import 'features/auth/login_page.dart';
import '../../presentation/leave/leave_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    publishableKey: SupabaseConstants.supabasePublishableKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginPage(),
    );
  }
}