import 'package:flutter/material.dart';
import '../main.dart';

/// Pin de carte — cercle solide coloré avec icône catégorielle blanche,
/// bordure blanche + ombre portée, et petite tige façon Google Maps moderne.
/// Utilisé sur la map principale ainsi que sur la vue Favoris "map".
class WhatekaMapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  const WhatekaMapPin({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Tige triangulaire sous le cercle
          Positioned(
            top: 38,
            child: CustomPaint(
              size: const Size(10, 12),
              painter: _PinTailPainter(color: color),
            ),
          ),
          // Cercle principal avec icône
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Helpers de coloration / icône partagés (palette v2 mai 2026).
/// Doit rester synchronisé avec ActivityCard.categoryColors.
Color whatekaMapPinColorFor(String? category) {
  final cats = (category ?? '').split(',').map((s) => s.trim().toLowerCase()).toList();
  // 'institution' est traité comme event (rouge).
  if (cats.contains('event') || cats.contains('institution')) {
    return const Color(0xFFDC2626);
  }
  final c = cats.isNotEmpty ? cats.first : '';
  switch (c) {
    case 'nature':     return const Color(0xFF16A34A);
    case 'culture':    return const Color(0xFF92400E);
    case 'gastronomy': return const Color(0xFFEA580C);
    case 'sport':      return const Color(0xFF0EA5E9);
    case 'adventure':  return const Color(0xFFCA8A04);
    case 'relax':      return const Color(0xFFA78BFA);
    case 'fun':        return const Color(0xFFEC4899);
    default:           return AppColors.stone;
  }
}

IconData whatekaMapPinIconFor(String? category) {
  final cats = (category ?? '').split(',').map((s) => s.trim().toLowerCase()).toList();
  if (cats.contains('event') || cats.contains('institution')) return Icons.event;
  final c = cats.isNotEmpty ? cats.first : '';
  switch (c) {
    case 'culture':    return Icons.museum;
    case 'nature':     return Icons.landscape;
    case 'gastronomy': return Icons.restaurant;
    case 'sport':      return Icons.directions_run;
    case 'adventure':  return Icons.explore_off;
    case 'relax':      return Icons.spa;
    case 'fun':        return Icons.celebration;
    default:           return Icons.place;
  }
}
