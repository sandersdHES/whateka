import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_menu_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/favorites_screen.dart';

import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/questionnaire_screen.dart';
import 'screens/activity_list_screen.dart';
import 'screens/single_activity_screen.dart';
import 'screens/ai_result_screen.dart';
import 'screens/update_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/submit_activity_screen.dart';
import 'i18n/strings.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://pqywriedvxsdngypplpg.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_KzcTKvqLTbWoECaUkD--xw_xJ8A35K6',
    ),
  );

  runApp(const MyApp());
}

class AppColors {
  // Nouvelle palette Whateka — épurée, fond beige sable
  static const Color paper   = Color(0xFFF7F2E9); // fond principal (beige sable)
  static const Color surface = Color(0xFFFFFFFF); // cartes blanches
  static const Color ink     = Color(0xFF0A0A0B); // texte principal
  static const Color stone   = Color(0xFF86868B); // texte secondaire
  static const Color line    = Color(0xFFE5E5E7); // séparateurs

  // Couleurs de marque Whateka (conservées)
  static const Color cyan    = Color(0xFF00B8D9); // accent primaire, logo
  static const Color orange  = Color(0xFFFF6F61); // CTA secondaire, chip gastronomie
  static const Color green   = Color(0xFF97C45F); // chip nature, succès
  static const Color brown   = Color(0xFF926335); // chip culture
  static const Color yellow  = Color(0xFFF6AE2D); // chip adventure, warnings

  // Alias rétrocompat pour les fichiers non refactorés
  static const Color black   = ink;
  static const Color white   = surface;
  static const Color teal    = cyan;
  static const Color coral   = orange;
  static const Color lightBg = paper;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Init locale au demarrage (lit user_metadata.locale ou fallback FR)
    LocaleProvider.instance.init();
    LocaleProvider.instance.addListener(() {
      if (mounted) setState(() {});
    });
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.pushNamed('/update_password');
      }
      // Re-sync locale apres login
      if (data.event == AuthChangeEvent.signedIn) {
        LocaleProvider.instance.init();
      }
    });
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.interTextTheme();

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cyan,
        primary: AppColors.cyan,
        secondary: AppColors.orange,
        tertiary: AppColors.green,
        surface: AppColors.surface,
        onPrimary: AppColors.surface,
        onSecondary: AppColors.surface,
        onSurface: AppColors.ink,
        error: const Color(0xFFE53935),
      ),
      scaffoldBackgroundColor: AppColors.paper,

      textTheme: baseTextTheme.copyWith(
        // Display : grands titres (34-40px, bold, serré)
        displayLarge: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: AppColors.ink),
        displayMedium: GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: AppColors.ink),
        displaySmall: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: AppColors.ink),
        // Headlines
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: AppColors.ink),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: AppColors.ink),
        headlineSmall: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: AppColors.ink),
        // Body
        bodyLarge: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.ink, height: 1.5),
        bodyMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink, height: 1.5),
        bodySmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.stone, height: 1.4),
        // Labels (boutons, chips)
        labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
        labelMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.stone),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.stone, letterSpacing: 0.5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,   // CTA principal = cyan, pas orange
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(color: AppColors.stone, fontWeight: FontWeight.w400),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line, width: 0.5),
        ),
        color: AppColors.surface,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Whateka',
      theme: theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/login': (_) => const LoginScreen(),
        '/verification': (_) => const EmailVerificationScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/dashboard': (_) => const HomeMenuScreen(),
        // Ecran d'intro avec logo (3s hold + 1s fade) avant d'arriver sur /map
        '/splash': (_) => const SplashScreen(),
        '/maintenance': (_) => const MaintenanceScreen(),
        '/access_success': (_) => const AccessSuccessScreen(),
        '/map': (_) => const MapScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/quiz': (_) => const QuestionnaireScreen(),
        '/activity': (_) => const ActivityListScreen(),
        '/activity_detail': (_) => const SingleActivityScreen(),
        '/update_password': (_) => const UpdatePasswordScreen(),
        '/submit_activity': (_) => const SubmitActivityScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/ai_result') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            return MaterialPageRoute(
              builder: (_) => AiResultScreen(
                userPrefs: args['prefs'] as Map<String, dynamic>,
                contextData: args['context'] as Map<String, dynamic>,
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
