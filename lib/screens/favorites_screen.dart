import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/activity_card.dart';
import '../widgets/responsive_center.dart';
import '../widgets/whateka_bottom_nav.dart';
import '../widgets/whateka_map_pin.dart';

/// Mode d'affichage de la page Favoris.
enum FavoritesViewMode { list, map }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ActivityService _activityService = ActivityService();
  late Future<List<Activity>> _favoritesFuture;
  FavoritesViewMode _viewMode = FavoritesViewMode.list;

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = _activityService.getFavoriteActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(s.navFavorites),
            centerTitle: true,
            // Pas de fleche back : la navigation se fait via la bottom nav
            // (Map / Quiz / Favoris / Profil).
            automaticallyImplyLeading: false,
          ),
          bottomNavigationBar:
              const WhatekBottomNav(currentRoute: '/favorites'),
          body: FutureBuilder<List<Activity>>(
            future: _favoritesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.cyan));
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '${s.errorWithDetails}: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 56, color: AppColors.stone),
                        const SizedBox(height: 16),
                        Text(
                          s.emptyNoFavorites,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.emptyNoFavoritesHint,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.stone,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final favorites = snapshot.data!;

              return Column(
                children: [
                  // Toggle Liste / Carte + compteur
                  _FavoritesToolbar(
                    count: favorites.length,
                    viewMode: _viewMode,
                    onChanged: (m) => setState(() => _viewMode = m),
                  ),
                  Expanded(
                    child: _viewMode == FavoritesViewMode.list
                        ? _buildList(favorites)
                        : _buildMap(favorites),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildList(List<Activity> favorites) {
    return ResponsiveCenter(
      maxWidth: 560,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 200,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final activity = favorites[index];
                  return Stack(
                    children: [
                      ActivityCard(
                        activity: activity,
                        size: ActivityCardSize.medium,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/activity_detail',
                            arguments: {
                              'activity': activity,
                              'searches_count': 1,
                            },
                          ).then((_) => _refreshFavorites());
                        },
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              favorites.removeAt(index);
                            });
                            try {
                              await _activityService
                                  .toggleFavorite(activity.id);
                            } catch (e) {
                              if (!mounted) return;
                              _refreshFavorites();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        S.current.favoriteRemoveError)),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite,
                                size: 16, color: AppColors.orange),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                childCount: favorites.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List<Activity> favorites) {
    // Filtre les activités sans coordonnées valides.
    final geoFavorites = favorites
        .where((a) => a.latitude != 0 || a.longitude != 0)
        .toList();

    if (geoFavorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            S.current.emptyNoFavoritesHint,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.stone),
          ),
        ),
      );
    }

    // Centre et zoom calculés depuis l'enveloppe des favoris.
    final bounds = _computeBounds(geoFavorites);
    final center = LatLng(
      (bounds.$1 + bounds.$2) / 2,
      (bounds.$3 + bounds.$4) / 2,
    );
    // Zoom heuristique : si tous les favoris sont proches → zoom 12,
    // sinon dezoom raisonnable pour tout englober.
    final latSpan = (bounds.$2 - bounds.$1).abs();
    final lngSpan = (bounds.$4 - bounds.$3).abs();
    final maxSpan = latSpan > lngSpan ? latSpan : lngSpan;
    final double zoom = maxSpan < 0.05
        ? 13
        : maxSpan < 0.2
            ? 11
            : maxSpan < 0.8
                ? 9
                : 7.5;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.whateka',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: geoFavorites
                  .map((a) => Marker(
                        point: LatLng(a.latitude, a.longitude),
                        width: 48,
                        height: 56,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showActivityDetail(a),
                            borderRadius: BorderRadius.circular(24),
                            child: WhatekaMapPin(
                              color: whatekaMapPinColorFor(a.category),
                              icon: whatekaMapPinIconFor(a.category),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap',
                  onTap: () => launchUrl(
                      Uri.parse('https://openstreetmap.org/copyright')),
                ),
                TextSourceAttribution(
                  'CARTO',
                  onTap: () => launchUrl(
                      Uri.parse('https://carto.com/attributions')),
                ),
              ],
            ),
          ],
        ),
        // Hint en bas
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app_outlined,
                    size: 16, color: AppColors.cyan),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.favoritesEmptyMap,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.ink,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Retourne (minLat, maxLat, minLng, maxLng) pour le set d'activités.
  (double, double, double, double) _computeBounds(List<Activity> list) {
    double minLat = list.first.latitude;
    double maxLat = list.first.latitude;
    double minLng = list.first.longitude;
    double maxLng = list.first.longitude;
    for (final a in list.skip(1)) {
      if (a.latitude < minLat) minLat = a.latitude;
      if (a.latitude > maxLat) maxLat = a.latitude;
      if (a.longitude < minLng) minLng = a.longitude;
      if (a.longitude > maxLng) maxLng = a.longitude;
    }
    return (minLat, maxLat, minLng, maxLng);
  }

  void _showActivityDetail(Activity activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ActivityCard(
                activity: activity,
                size: ActivityCardSize.medium,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/activity_detail',
                    arguments: {
                      'activity': activity,
                      'searches_count': 1,
                    },
                  ).then((_) => _refreshFavorites());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Toolbar haut de page : compteur + toggle Liste/Carte.
class _FavoritesToolbar extends StatelessWidget {
  final int count;
  final FavoritesViewMode viewMode;
  final ValueChanged<FavoritesViewMode> onChanged;

  const _FavoritesToolbar({
    required this.count,
    required this.viewMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          // Compteur à gauche
          Expanded(
            child: Text(
              '$count ${count > 1 ? s.favoritesCountPlural : s.favoritesCountSingle}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          // Segmented toggle à droite
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.line.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleChip(
                  label: s.favoritesViewList,
                  icon: Icons.view_agenda_outlined,
                  selected: viewMode == FavoritesViewMode.list,
                  onTap: () => onChanged(FavoritesViewMode.list),
                ),
                const SizedBox(width: 2),
                _ToggleChip(
                  label: s.favoritesViewMap,
                  icon: Icons.map_outlined,
                  selected: viewMode == FavoritesViewMode.map,
                  onTap: () => onChanged(FavoritesViewMode.map),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.cyan : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16, color: selected ? Colors.white : AppColors.ink),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
