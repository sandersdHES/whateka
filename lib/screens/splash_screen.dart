import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
/// Ecran d'intro affiche apres la connexion (ou le reset du mot de passe).
///
/// Sequence :
///   - T=0s   : logo Whateka affiche
///   - T=3s   : debut du fade-out
///   - T=4s   : navigation -> /map
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _holdDuration = Duration(seconds: 3);
  static const Duration _fadeDuration = Duration(seconds: 1);

  double _opacity = 1.0;
  Timer? _fadeTimer;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    // Garde-fou : si on arrive sur le splash sans session (edge case
    // logout / token expire), on retourne au home.
    final supabase = Supabase.instance.client;
    if (supabase.auth.currentSession == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
      });
      return;
    }
    _fadeTimer = Timer(_holdDuration, () {
      if (!mounted) return;
      setState(() => _opacity = 0.0);
    });
    _navigateTimer = Timer(_holdDuration + _fadeDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/map', (r) => false);
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _navigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: _fadeDuration,
          curve: Curves.easeInOut,
          child: Image.asset(
            'assets/images/home_icon.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
