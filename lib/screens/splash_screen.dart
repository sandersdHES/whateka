import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

/// Ecran d'intro affiche apres la connexion (ou le reset du mot de passe).
///
/// Sequence :
///   - T=0s  : logo Whateka affiche en plein milieu, opacite 100 %
///   - T=3s  : debut du fade-out (duree 1 seconde)
///   - T=4s  : navigation vers l'ecran /map en remplacant la pile
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
    // Apres le hold, on declenche le fade-out.
    _fadeTimer = Timer(_holdDuration, () {
      if (!mounted) return;
      setState(() => _opacity = 0.0);
    });
    // Une fois le fade termine, on navigue vers la carte.
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
      backgroundColor: AppColors.white,
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
