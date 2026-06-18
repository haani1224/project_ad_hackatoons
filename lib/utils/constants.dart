import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E4365); // police blue
  static const Color accent = Color(0xFFF3D58D);  // marigold

  static const Color background = Color(0xFFF5F5F5);

  static const Color active = Colors.green;
  static const Color pending = Colors.orange;
  static const Color inactive = Colors.grey;
}

class AppStyles {
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
}

class AppConstants {
  // Supabase — fill these in from your Supabase project settings
  static const String supabaseUrl = 'https://pfeywemicycpsgidebpo.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmZXl3ZW1pY3ljcHNnaWRlYnBvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2ODg0NDAsImV4cCI6MjA5NzI2NDQ0MH0.2_Wki6RAABADNVDSMvfhJYDC3aEjnCxN2IWu_Cj8Qug';

  // User roles stored in profiles table
  static const String roleTeacher = 'teacher';
  static const String rolePrincipal = 'principal';

  // Training categories (matches PDF)
  static const List<String> trainingCategories = [
    'Teaching Skills',
    'Child Development',
    'Safety and First Aid',
    'Islamic Education',
    'Classroom Management',
    'ICT/Technology',
    'Others',
  ];

  // Training modes
  static const List<String> trainingModes = ['Online', 'Physical'];
}