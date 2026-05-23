import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../models/activity.dart';
import 'whateka_verified_badge.dart';

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

  /// Couleurs par catégorie (publique : réutilisée sur la fiche détail).
  /// Palette v2 (mai 2026) : chaque catégorie a une couleur sémantique
  /// distincte avec bon contraste blanc pour les chips.
  static const Map<String, Color> categoryColors = {
    'nature':      Color(0xFF16A34A), // vert forêt
    'culture':     Color(0xFF92400E), // brun terre cuite
    'gastronomy':  Color(0xFFEA580C), // orange épices
    'sport':       Color(0xFF0EA5E9), // bleu énergie
    'adventure':   Color(0xFFCA8A04), // ambre soleil
    'relax':       Color(0xFFA78BFA), // lilas pastel
    'fun':         Color(0xFFEC4899), // rose festif
    'event':       Color(0xFFDC2626), // rouge alerte
    'institution': Color(0xFF475569), // gris ardoise
  };

  /// Label localisé d'une catégorie (publique : réutilisée sur la fiche détail).
  static String categoryLabel(String c, BuildContext context) {
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

  /// Decompose le CSV de categories en liste normalisee :
  /// - 'institution' devient 'event' (cas auto-promu cote algo)
  /// - dedoublonne en preservant l'ordre
  /// - 'event' est promu en premier si present (priorite visuelle)
  static List<String> displayCategories(String? csv) {
    final raw = (csv ?? '')
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty);
    final list = <String>[];
    for (final c in raw) {
      final normalized = (c == 'institution') ? 'event' : c;
      if (!list.contains(normalized)) list.add(normalized);
    }
    if (list.contains('event')) {
      list.remove('event');
      list.insert(0, 'event');
    }
    return list;
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

    // Toutes les catégories à afficher (event en 1er si présent, dédupliquées).
    final displayCats = displayCategories(activity.category);
    // Couleur primaire = celle de la 1re catégorie (utilisée pour le fallback
    // photo et la teinte dominante de la card).
    final primaryCat = displayCats.isNotEmpty ? displayCats.first : '';
    final primaryColor = categoryColors[primaryCat] ?? AppColors.stone;
    // Fallback coloré par catégorie (teinte foncée) quand la photo est
    // absente ou en erreur — plus cohérent visuellement que du gris.
    final fallbackColor = Color.lerp(primaryColor, Colors.black, 0.45)!;

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
            // Chips catégories top-left : un par catégorie sur la même ligne.
            // Wrap permet d'aller à la ligne si trop nombreuses (ex: card
            // compact sur un activite multi-categorie).
            // Le badge "Whateka Verified" est ajoute en dernier child si
            // l'activite est certifiee par l'equipe.
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...displayCats.map((c) {
                    final color = categoryColors[c] ?? AppColors.stone;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        categoryLabel(c, context).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    );
                  }),
                  if (activity.isWhatekaCertified)
                    const WhatekaVerifiedBadge(size: 26),
                ],
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
