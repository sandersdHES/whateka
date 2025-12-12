import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';

import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/questionnaire_screen.dart';
import 'screens/activity_list_screen.dart';
import 'screens/single_activity_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pqywriedvxsdngypplpg.supabase.co',
    anonKey: 'sb_publishable_KzcTKvqLTbWoECaUkD--xw_xJ8A35K6',
  );

  runApp(const MyApp());
}

class AppColors {
  // Brand palette
  static const Color black = Color(0xFF000000);
  static const Color brown = Color(0xFF926335);
  static const Color cyan = Color(0xFF00B8D9); // primary
  static const Color green = Color(0xFF97C45F);
  static const Color orange = Color(0xFFF26419); // CTA / secondary
  static const Color yellow = Color(0xFFF6AE2D);
  static const Color white = Color(0xFFFFFFFF);

  // Backwards-compat aliases used across screens
  static const Color teal = cyan;
  static const Color coral = orange;
  static const Color lightBg = white;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.montserratTextTheme();
    final displayTextTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.concertOne(
        fontSize: baseTextTheme.displayLarge?.fontSize,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: GoogleFonts.concertOne(
        fontSize: baseTextTheme.displayMedium?.fontSize,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.concertOne(
        fontSize: baseTextTheme.displaySmall?.fontSize,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: GoogleFonts.concertOne(
        fontSize: baseTextTheme.headlineLarge?.fontSize,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: GoogleFonts.concertOne(
        fontSize: baseTextTheme.headlineMedium?.fontSize,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: GoogleFonts.concertOne(
        fontSize: baseTextTheme.headlineSmall?.fontSize,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: GoogleFonts.concertOne(
        fontSize: baseTextTheme.titleLarge?.fontSize,
        fontWeight: FontWeight.w400,
      ),
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cyan,
        primary: AppColors.cyan,
        secondary: AppColors.orange,
        tertiary: AppColors.green,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        error: const Color(0xFFE53935),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFB), // Very light cool grey
      textTheme: displayTextTheme.apply(
        bodyColor: AppColors.black,
        displayColor: AppColors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.concertOne(
          fontSize: 24,
          color: AppColors.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 4,
          shadowColor: AppColors.orange.withValues(alpha: 0.4),
          textStyle: GoogleFonts.concertOne(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyan,
          side: const BorderSide(color: AppColors.cyan, width: 2),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.concertOne(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        hintStyle: TextStyle(
          color: AppColors.black.withValues(alpha: 0.3),
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whateka',
      theme: theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/login': (_) => const LoginScreen(),
        '/verification': (_) => const EmailVerificationScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/quiz': (_) => const QuestionnaireScreen(),
        '/activity': (_) => const ActivityListScreen(),
        '/activity_detail': (_) => const SingleActivityScreen(),
      },
    );
  }
}
