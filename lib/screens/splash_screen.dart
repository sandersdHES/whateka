import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/access_service.dart';

/// Ecran d'intro affiche apres la connexion (ou le reset du mot de passe).
///
/// Sequence :
///   - T=0s   : logo Whateka affiche, verification d'acces en parallele
///   - T=3s   : debut du fade-out
///   - T=4s   : navigation -> /map (si acces) ou /maintenance (sinon)
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
  bool? _hasAccess;

  @override
  void initState() {
    super.initState();
    // Verification d'acces en parallele du splash (imperceptible).
    AccessService().hasAccess().then((value) {
      if (!mounted) return;
      _hasAccess = value;
    });
    _fadeTimer = Timer(_holdDuration, () {
      if (!mounted) return;
      setState(() => _opacity = 0.0);
    });
    _navigateTimer = Timer(_holdDuration + _fadeDuration, () async {
      if (!mounted) return;
      // Si la verification n'est pas encore terminee, on attend (max 2s).
      var waited = 0;
      while (_hasAccess == null && waited < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        waited++;
      }
      if (!mounted) return;
      final route = (_hasAccess == true) ? '/map' : '/maintenance';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
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
