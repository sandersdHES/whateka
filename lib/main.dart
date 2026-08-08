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
import 'screens/submit_activity_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/promo_code_screen.dart';
import 'screens/thanks_for_interest_screen.dart';
import 'i18n/strings.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase n'est configure que pour Android (cf. firebase_options.dart) et
  // n'est de toute facon utilise nulle part ailleurs dans l'app (auth =
  // Supabase). Sur web / iOS / desktop, DefaultFirebaseOptions.currentPlatform
  // leve une UnsupportedError : appelee sans garde, cette exception remonte
  // dans main() AVANT runApp(), l'app ne se monte jamais -> page blanche (web)
  // et crash au lancement (iOS, d'ou le rejet App Store). On garde donc l'init
  // derriere un try/catch pour ne JAMAIS bloquer le demarrage.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init ignoree (non configuree pour cette plateforme): $e');
  }

  // SUPABASE_URL et SUPABASE_ANON_KEY doivent etre passes via
  //   flutter build/run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // ou via le workflow GitHub Actions (Secrets).
  // On NE met PLUS de defaultValue en clair dans le code source : meme une
  // anon key permet d'enumerer le schema et de probe les RLS — autant ne
  // pas la versionner. Cf. audit 2026-05.
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL et SUPABASE_ANON_KEY doivent etre fournis via --dart-define. '
      'Voir BUILD.md et .github/workflows/deploy-web.yml.',
    );
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Observabilite : init Sentry si SENTRY_DSN est defini. Sans DSN, no-op
  // total (pas de network, pas de wrap d'erreurs). Voir BUILD.md.
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.1;
        // PII off par defaut : on veut pas capturer les emails users.
        options.sendDefaultPii = false;
        options.environment = const String.fromEnvironment(
          'SENTRY_ENV',
          defaultValue: 'production',
        );
      },
      appRunner: () => runApp(const MyApp()),
    );
  } else {
    runApp(const MyApp());
  }
}

class AppColors {
  // Palette officielle Whateka (brand board)
  static const Color surface = Color(0xFFFFFFFF); // fond principal blanc
  static const Color paper   = Color(0xFFF7F2E9); // alias conservé (non utilisé pour le scaffold)
  static const Color ink     = Color(0xFF000000); // texte principal
  static const Color stone   = Color(0xFF86868B); // texte secondaire
  static const Color line    = Color(0xFFE5E5E7); // séparateurs

  // Couleurs de marque Whateka (#00B8D9 / #FF6F61 / #97C45F / #926335 / #F6AE2D)
  static const Color cyan    = Color(0xFF00B8D9); // identité visuelle, bouton outlined
  static const Color orange  = Color(0xFFFF6F61); // CTA principal, chip gastronomie
  static const Color green   = Color(0xFF97C45F); // chip nature, succès
  static const Color brown   = Color(0xFF926335); // chip culture
  static const Color yellow  = Color(0xFFF6AE2D); // chip aventure, avertissements

  // Alias de compatibilité
  static const Color black   = ink;
  static const Color white   = surface;
  static const Color teal    = cyan;
  static const Color coral   = orange;
  static const Color lightBg = surface;
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
      // Logout / token expire : retour au home pour reconnexion.
      if (data.event == AuthChangeEvent.signedOut) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (r) => false);
      }
    });
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // Polices principales : Concert One (titres) + Montserrat (corps)
    final baseTextTheme = GoogleFonts.montserratTextTheme();

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cyan,
        primary: AppColors.orange,
        secondary: AppColors.cyan,
        tertiary: AppColors.green,
        surface: AppColors.surface,
        onPrimary: AppColors.surface,
        onSecondary: AppColors.surface,
        onSurface: AppColors.ink,
        error: const Color(0xFFE53935),
      ),
      scaffoldBackgroundColor: AppColors.surface,

      textTheme: baseTextTheme.copyWith(
        // Display & Headlines : Concert One (police principale de marque)
        displayLarge:  GoogleFonts.concertOne(fontSize: 40, color: AppColors.ink),
        displayMedium: GoogleFonts.concertOne(fontSize: 34, color: AppColors.ink),
        displaySmall:  GoogleFonts.concertOne(fontSize: 28, color: AppColors.ink),
        headlineLarge:  GoogleFonts.concertOne(fontSize: 24, color: AppColors.ink),
        headlineMedium: GoogleFonts.concertOne(fontSize: 20, color: AppColors.ink),
        headlineSmall:  GoogleFonts.concertOne(fontSize: 17, color: AppColors.ink),
        // Body & Labels : Montserrat (police corps de texte)
        bodyLarge:  GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.ink, height: 1.5),
        bodyMedium: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink, height: 1.5),
        bodySmall:  GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.stone, height: 1.4),
        labelLarge:  GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
        labelMedium: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.stone),
        labelSmall:  GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.stone, letterSpacing: 0.5),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.concertOne(fontSize: 20, color: AppColors.ink),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,  // CTA principal = orange (brand board)
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          elevation: 0,
          textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyan,
          side: const BorderSide(color: AppColors.cyan, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.montserrat(color: AppColors.stone, fontWeight: FontWeight.w400),
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

    // Persistance de session : Supabase garde la session dans le storage
    // local (shared_preferences). Si une session existe au demarrage, on
    // saute le HomeScreen et on va directement au splash puis sur /map.
    // L'utilisateur ne se reconnecte donc PAS a chaque ouverture de l'app.
    final hasSession = Supabase.instance.client.auth.currentSession != null;
    final initialRoute = hasSession ? '/splash' : '/';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Whateka',
      theme: theme,
      initialRoute: initialRoute,
      routes: {
        '/': (_) => const HomeScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/login': (_) => const LoginScreen(),
        '/verification': (_) => const EmailVerificationScreen(),
        '/forgot_password': (_) => const ForgotPasswordScreen(),
        '/dashboard': (_) => const HomeMenuScreen(),
        // Ecran d'intro avec logo (3s hold + 1s fade) avant d'arriver sur /map
        '/splash': (_) => const SplashScreen(),
        '/map': (_) => const MapScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/quiz': (_) => const QuestionnaireScreen(),
        '/activity': (_) => const ActivityListScreen(),
        '/activity_detail': (_) => const SingleActivityScreen(),
        '/update_password': (_) => const UpdatePasswordScreen(),
        '/submit_activity': (_) => const SubmitActivityScreen(),
        '/subscription': (_) => const SubscriptionScreen(),
        '/promo_code': (_) => const PromoCodeScreen(),
        '/thanks_for_interest': (_) => const ThanksForInterestScreen(),
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
