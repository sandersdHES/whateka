import 'dart:ui';
import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../main.dart';

/// Barre de navigation inferieure commune a tous les ecrans "logges".
///
/// Refonte avril 2026 — pilule flottante en verre dépoli :
/// - 4 boutons, ordre : Map | Logo -> /quiz | Favorites | Profile
/// - Backdrop blur + fond blanc semi-transparent
/// - La Map est l'ecran d'atterrissage par defaut apres connexion (via /splash)
/// - Le logo Whateka est un raccourci vers le questionnaire
class WhatekBottomNav extends StatelessWidget {
  final String currentRoute;

  const WhatekBottomNav({super.key, required this.currentRoute});

  void _navigate(BuildContext context, String route) {
    if (currentRoute == route) return;
    // pushReplacementNamed evite que la stack gonfle a chaque clic d'onglet.
    // Avant : naviguer entre Map -> Quiz -> Profil -> Favoris empilait 4 ecrans.
    // /map reste avec pushNamedAndRemoveUntil pour garantir d'y retomber au back.
    if (route == '/map') {
      Navigator.pushNamedAndRemoveUntil(context, '/map', (r) => false);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavIcon(
                  Icons.map_outlined,
                  currentRoute == '/map',
                  () => _navigate(context, '/map'),
                  tooltip: s.navMap,
                ),
                _LogoNavItem(
                  onTap: () => _navigate(context, '/quiz'),
                  tooltip: s.navQuiz,
                ),
                _NavIcon(
                  Icons.favorite_outline,
                  currentRoute == '/favorites',
                  () => _navigate(context, '/favorites'),
                  tooltip: s.navFavorites,
                ),
                _NavIcon(
                  Icons.person_outline,
                  currentRoute == '/profile',
                  () => _navigate(context, '/profile'),
                  tooltip: s.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _NavIcon(this.icon, this.isActive, this.onTap,
      {required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.ink : AppColors.stone,
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;

  const _LogoNavItem({required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              'assets/images/home_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
