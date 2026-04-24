import 'package:flutter/material.dart';
import '../main.dart';
import '../models/activity.dart';

/// Carte d'activité réutilisable — photo edge-to-edge, chip catégorie,
/// nom + lieu + prix en surimpression sur un dégradé sombre en bas.
///
/// 3 tailles :
/// - [ActivityCardSize.hero]    : 260px — la recommandation principale
/// - [ActivityCardSize.medium]  : 200px — grille standard
/// - [ActivityCardSize.compact] :  96px — liste dense, map bottom sheet
enum ActivityCardSize { hero, medium, compact }

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final ActivityCardSize size;
  final VoidCallback? onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.size = ActivityCardSize.medium,
    this.onTap,
  });

  static const Map<String, Color> _categoryColors = {
    'culture':     AppColors.brown,
    'nature':      AppColors.green,
    'gastronomy':  AppColors.orange,
    'sport':       AppColors.cyan,
    'adventure':   AppColors.yellow,
    'relax':       Color(0xFFB8A1D9), // lavande douce
    'fun':         AppColors.yellow,
  };

  static String _categoryLabel(String c) {
    switch (c.toLowerCase().trim()) {
      case 'culture':    return 'Culture';
      case 'nature':     return 'Nature';
      case 'gastronomy': return 'Gastro';
      case 'sport':      return 'Sport';
      case 'adventure':  return 'Aventure';
      case 'relax':      return 'Détente';
      case 'fun':        return 'Fun';
      default:           return c;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = switch (size) {
      ActivityCardSize.hero    => 260,
      ActivityCardSize.medium  => 200,
      ActivityCardSize.compact => 96,
    };
    final double titleSize = switch (size) {
      ActivityCardSize.hero    => 24,
      ActivityCardSize.medium  => 16,
      ActivityCardSize.compact => 14,
    };
    final double radius = switch (size) {
      ActivityCardSize.hero    => 24,
      ActivityCardSize.medium  => 20,
      ActivityCardSize.compact => 16,
    };

    final cat = (activity.category ?? '').split(',').first.trim().toLowerCase();
    final chipColor = _categoryColors[cat] ?? AppColors.stone;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // Photo
            SizedBox(
              width: double.infinity,
              height: height,
              child: activity.imageUrl != null && activity.imageUrl!.isNotEmpty
                  ? Image.network(
                      activity.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.line),
                    )
                  : Container(color: const Color(0xFF3E4B5A)),
            ),
            // Gradient sombre en bas pour lisibilité du texte
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Chip catégorie top-left
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _categoryLabel(cat).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            // Info bottom-left
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${activity.location.toUpperCase()} · ${Activity.priceLevelLabel(activity.priceLevel)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
