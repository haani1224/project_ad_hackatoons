import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF2E4365);
  static const Color primaryDark = Color(0xFF1B2E4B);
  static const Color primaryLight = Color(0xFF455F86);

  static const Color accent = Color(0xFFE59D2C);
  static const Color accentLight = Color(0xFFFFF0CC);

  static const Color background = Color(0xFFF3F5F9);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF23344F);
  static const Color textSecondary = Color(0xFF8A93A3);

  static const Color success = Color(0xFF4CAF62);
  static const Color successLight = Color(0xFFE5F4E9);

  static const Color warning = Color(0xFFF3A51F);
  static const Color warningLight = Color(0xFFFFF2D9);

  static const Color danger = Color(0xFFEF4C4C);
  static const Color dangerLight = Color(0xFFFBE5E8);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF0EAFE);

  static const Color divider = Color(0xFFE7EAF0);

  // Backward-compatible names used by older pages.
  static const Color active = success;
  static const Color pending = warning;
  static const Color inactive = textSecondary;
  static const Color rejected = danger;
  static const Color deleted = danger;
}

class AppTextStyles {
  static TextStyle pageTitle = GoogleFonts.poppins(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}

// Backward-compatible class used by older widgets.
class AppStyles {
  static TextStyle title = AppTextStyles.cardTitle;

  static TextStyle subtitle = AppTextStyles.caption;

  static TextStyle heading = AppTextStyles.heading;

  static TextStyle body = AppTextStyles.body;

  static TextStyle button = AppTextStyles.button;
}

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.055),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
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