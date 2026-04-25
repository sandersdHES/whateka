import 'package:flutter/material.dart';
import '../i18n/strings.dart';
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
    'event':       Color(0xFFDC2626), // rouge événement
    'institution': Color(0xFF475569), // gris foncé institution
  };

  static String _categoryLabel(String c, BuildContext context) {
    final s = S.of(context);
    switch (c.toLowerCase().trim()) {
      case 'culture':    return s.quizCatCulture;
      case 'nature':     return s.quizCatNature;
      case 'gastronomy': return s.quizCatGastronomy;
      case 'sport':      return s.quizCatSport;
      case 'adventure':  return s.quizCatAdventure;
      case 'relax':      return s.quizCatRelax;
      case 'fun':        return s.quizCatFun;
      case 'event':      return s.quizCatEvent;
      case 'institution':return s.quizCatEvent;
      default:           return c;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = switch (size) {
      ActivityCardSize.hero    => 260.0,
      ActivityCardSize.medium  => 200.0,
      ActivityCardSize.compact => 96.0,
    };
    final double titleSize = switch (size) {
      ActivityCardSize.hero    => 24.0,
      ActivityCardSize.medium  => 16.0,
      ActivityCardSize.compact => 14.0,
    };
    final double radius = switch (size) {
      ActivityCardSize.hero    => 24.0,
      ActivityCardSize.medium  => 20.0,
      ActivityCardSize.compact => 16.0,
    };

    final allCats = (activity.category ?? '')
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    // 'event' (et 'institution' qui est automatiquement event) a la priorité.
    final cat = (allCats.contains('event') || allCats.contains('institution'))
        ? 'event'
        : (allCats.isNotEmpty ? allCats.first : '');
    final chipColor = _categoryColors[cat] ?? AppColors.stone;
    // Fallback coloré par catégorie (teinte foncée) quand la photo est
    // absente ou en erreur — plus cohérent visuellement que du gris.
    final fallbackColor = Color.lerp(chipColor, Colors.black, 0.45)!;

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
                      errorBuilder: (_, __, ___) =>
                          Container(color: fallbackColor),
                    )
                  : Container(color: fallbackColor),
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
                  _categoryLabel(cat, context).toUpperCase(),
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
                    pickLocalized(activity.title, activity.titleEn),
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
