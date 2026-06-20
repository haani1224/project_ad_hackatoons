import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'screens/auth/login_screen.dart';
import 'screens/teacher/teacher_main_page.dart';
// import 'screens/teacher/teacher_home.dart';
// import 'screens/principal/principal_home.dart';
// <<<<<<< Updated upstream
// import '../features/auth/login_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// =======
// import 'package:supabase_flutter/supabase_flutter.dart';
// >>>>>>> Stashed changes
// import 'core/constants/supabase_constants.dart';
// import 'core/theme/app_theme.dart';
// // import 'features/teachers/teacher_list_page.dart';
// //import 'features/auth/login_page.dart';
// import '../../presentation/leave/leave_list_page.dart';
// import '../models/teacher_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cglpopnrinpghbuvckrx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNnbHBvcG5yaW5wZ2hidXZja3J4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3MTM0MzAsImV4cCI6MjA5NzI4OTQzMH0.rzcw0u7QD5leMj8SNweo5A2fylvDiCq0bBaU5-BbOhc',
  );

  runApp(const GeniusAqilOS());
}

// Minimal TeacherModel to satisfy constructor type requirement.
// If a more complete model exists elsewhere, remove this and import it.

class GeniusAqilOS extends StatelessWidget {
  const GeniusAqilOS({super.key});

  static const Color primaryBlue = Color(0xFF2E4365);
  static const Color accentYellow = Color(0xFFE59D2C);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Teacher Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryBlue,
          secondary: accentYellow,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: LoginPage(), // Start with the login page
      
    );
  }
}

