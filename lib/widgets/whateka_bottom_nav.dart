import 'package:flutter/material.dart';
import '../main.dart';

class WhatekBottomNav extends StatelessWidget {
  final String currentRoute;

  const WhatekBottomNav({super.key, required this.currentRoute});

  void _navigate(BuildContext context, String route) {
    if (currentRoute == route) return;
    if (route == '/dashboard') {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cyan,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.assignment_outlined,
            isActive: currentRoute == '/quiz',
            onTap: () => _navigate(context, '/quiz'),
          ),
          _NavItem(
            icon: Icons.map_outlined,
            isActive: currentRoute == '/map',
            onTap: () => _navigate(context, '/map'),
          ),
          // Centre : Logo Whateka = bouton Home
          _HomeNavItem(
            isActive: currentRoute == '/dashboard',
            onTap: () => _navigate(context, '/dashboard'),
          ),
          _NavItem(
            icon: Icons.favorite_outline,
            isActive: currentRoute == '/favorites',
            onTap: () => _navigate(context, '/favorites'),
          ),
          _NavItem(
            icon: Icons.person_outline,
            isActive: currentRoute == '/profile',
            onTap: () => _navigate(context, '/profile'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive ? AppColors.cyan : Colors.white,
        ),
      ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _HomeNavItem({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white
              : Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/images/home_icon.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
