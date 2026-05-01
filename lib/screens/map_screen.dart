import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/whateka_bottom_nav.dart';
import '../widgets/activity_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ActivityService _activityService = ActivityService();
  final TextEditingController _searchController = TextEditingController();

  LatLng _currentPosition = const LatLng(46.22935, 7.36204);
  LatLng? _targetPosition;
  bool _hasLocation = false;
  bool _isLoading = false;
  List<Activity> _activities = [];
  String _searchQuery = '';
  bool _locationModeManual = false;
  // Mode d'affichage des marqueurs :
  // false (Tout)  = toutes sauf échues
  // true  (Live)  = uniquement celles proposables maintenant (algo v26)
  bool _liveMode = false;
  // Si on arrive depuis "Voir sur la carte" d'une fiche activite, on garde
  // l'ID pour : (1) garantir que cette activite apparait sur la carte meme
  // si elle echoue le filtre Live/echu, (2) ouvrir auto le bottom sheet
  // de detail, (3) afficher un bouton "Retour a la fiche".
  int? _focusedActivityId;
  bool _focusOpenedDetail = false;

  // Categories selectionnees pour le filtre. Vide = afficher toutes.
  // Les valeurs sont les cles DB ('nature', 'culture', etc.).
  final Set<String> _selectedCategories = {};

  // Liste des categories filtrables avec leur cle DB + label localise.
  static const List<({String key, IconData icon})> _filterCategories = [
    (key: 'nature',     icon: Icons.landscape),
    (key: 'culture',    icon: Icons.museum),
    (key: 'gastronomy', icon: Icons.restaurant),
    (key: 'sport',      icon: Icons.directions_run),
    (key: 'adventure',  icon: Icons.hiking),
    (key: 'relax',      icon: Icons.spa),
    (key: 'fun',        icon: Icons.celebration),
    (key: 'event',      icon: Icons.event),
  ];

  String _categoryLabel(String key) {
    final s = S.current;
    switch (key) {
      case 'nature':     return s.quizCatNature;
      case 'culture':    return s.quizCatCulture;
      case 'gastronomy': return s.quizCatGastronomy;
      case 'sport':      return s.quizCatSport;
      case 'adventure':  return s.quizCatAdventure;
      case 'relax':      return s.quizCatRelax;
      case 'fun':        return s.quizCatFun;
      case 'event':      return s.quizCatEvent;
      default:           return key;
    }
  }

  Color _categoryColor(String key) {
    switch (key) {
      case 'nature':     return AppColors.green;
      case 'culture':    return AppColors.brown;
      case 'gastronomy': return AppColors.orange;
      case 'sport':      return AppColors.cyan;
      case 'adventure':  return AppColors.yellow;
      case 'relax':      return const Color(0xFFB8A1D9);
      case 'fun':        return AppColors.yellow;
      case 'event':      return const Color(0xFFDC2626);
      default:           return AppColors.stone;
    }
  }

  // Zoom par defaut quand on centre sur la position utilisateur :
  // 12 = vue de ville (assez large pour voir le canton alentour).
  static const double _userZoom = 12.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final lat = args['latitude'] as double?;
      final lng = args['longitude'] as double?;
      if (lat != null && lng != null) {
        _targetPosition = LatLng(lat, lng);
      }
      final id = args['activity_id'];
      if (id is int) {
        _focusedActivityId = id;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Lecture synchrone du mode de localisation depuis le profil pour que
    // le premier rendu du MapOptions utilise deja la bonne position (evite
    // le flash sur la position par defaut Sion).
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    final mode = (meta['location_mode'] as String?) ?? 'auto';
    _locationModeManual = mode == 'manual';
    if (_locationModeManual) {
      final lat = (meta['manual_lat'] as num?)?.toDouble();
      final lng = (meta['manual_lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        _currentPosition = LatLng(lat, lng);
        _hasLocation = true;
      }
    }
    _setupUserLocation();
    _fetchActivities();
  }

  /// Applique la logique de localisation :
  /// - Mode manuel : recentre la carte sur la ville choisie (pas de GPS).
  /// - Mode auto : demande le GPS.
  Future<void> _setupUserLocation() async {
    if (_locationModeManual && _hasLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(
            _targetPosition ?? _currentPosition,
            _userZoom,
          );
        } catch (e) {
          debugPrint('Map controller error: $e');
        }
      });
      return;
    }
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _activityService.getActivities();
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
        // Si on est arrives via "Voir sur la carte" d'une fiche, on zoome
        // sur l'activite + on ouvre son detail automatiquement (1 seule
        // fois pour ne pas re-trigger a chaque rebuild).
        if (_focusedActivityId != null && !_focusOpenedDetail) {
          final target = activities.firstWhere(
            (a) => a.id == _focusedActivityId,
            orElse: () => activities.isNotEmpty ? activities.first : Activity(
              id: -1, title: '', location: '', duration: '',
              latitude: 0, longitude: 0, features: const [],
            ),
          );
          if (target.id == _focusedActivityId) {
            _focusOpenedDetail = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              try {
                _mapController.move(LatLng(target.latitude, target.longitude), 16);
              } catch (_) {}
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) _showActivityDetail(target);
              });
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _hasLocation = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(
              _targetPosition ?? _currentPosition,
              _userZoom,
            );
          } catch (e) {
            debugPrint('Map controller error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted && _targetPosition != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(_targetPosition!, _userZoom);
          } catch (e) {
            debugPrint('Map controller error: $e');
          }
        });
      }
    }
  }

  List<Activity> get _filteredActivities {
    final now = DateTime.now();
    final q = _searchQuery.toLowerCase();
    return _activities.where((a) {
      // L'activite focusee depuis "Voir sur la carte" passe TOUJOURS, peu
      // importe les filtres (sinon on cliquerait et rien ne s'afficherait).
      if (_focusedActivityId != null && a.id == _focusedActivityId) return true;
      // Toujours exclure les échues
      if (a.isExpiredAt(now)) return false;
      // En mode Live : seulement les proposables maintenant
      if (_liveMode && !a.isProposableAt(now)) return false;
      // Filtre catégories : si une selection existe, l'activite doit avoir
      // au moins une categorie dans le set selectionne.
      if (_selectedCategories.isNotEmpty) {
        final cats = (a.category ?? '')
            .split(',')
            .map((c) => c.trim().toLowerCase())
            .toSet();
        if (!cats.any((c) => _selectedCategories.contains(c))) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final matchSearch = a.title.toLowerCase().contains(q) ||
            a.location.toLowerCase().contains(q) ||
            (a.category?.toLowerCase().contains(q) ?? false);
        if (!matchSearch) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
    final s = S.of(context);
    final initialCenter = _targetPosition ?? _currentPosition;
    // Zoom de depart : si on a deja une position (manuelle connue des initState
    // OU cible d'une activite), on zoome a _userZoom. Sinon on reste dezoome
    // le temps que la GPS reponde.
    final initialZoom =
        (_locationModeManual && _hasLocation) || _targetPosition != null
            ? _userZoom
            : 11.0;

    return Scaffold(
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/map'),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: initialZoom,
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
                markers: [
                  if (_hasLocation)
                    Marker(
                      point: _currentPosition,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/images/home_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ..._filteredActivities.map((activity) => Marker(
                        point: LatLng(activity.latitude, activity.longitude),
                        width: 48,
                        height: 56,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showActivityDetail(activity),
                            borderRadius: BorderRadius.circular(24),
                            child: _WhatekPin(
                              color: _markerColorFor(activity.category),
                              icon: _markerIconFor(activity.category),
                            ),
                          ),
                        ),
                      )),
                ],
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
                    onTap: () =>
                        launchUrl(Uri.parse('https://carto.com/attributions')),
                  ),
                ],
              ),
            ],
          ),

          // Barre de recherche + toggle Live/Tout flottants en haut
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search,
                                size: 20, color: AppColors.stone),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                decoration: InputDecoration(
                                  hintText: s.mapSearchPlaceholder,
                                  border: InputBorder.none,
                                  filled: false,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: AppColors.stone,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ligne 1 : Toggle Live / Tout
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.06),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildModeChip(
                                  label: s.mapToggleAll,
                                  icon: Icons.public,
                                  selected: !_liveMode,
                                  onTap: () => setState(() => _liveMode = false),
                                ),
                                const SizedBox(width: 4),
                                _buildModeChip(
                                  label: s.mapToggleLive,
                                  icon: Icons.bolt,
                                  selected: _liveMode,
                                  onTap: () => setState(() => _liveMode = true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Ligne 2 : Filtre par catégories (chips horizontaux scrollables)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final cat = _filterCategories[index];
                        final selected = _selectedCategories.contains(cat.key);
                        final color = _categoryColor(cat.key);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selected) {
                              _selectedCategories.remove(cat.key);
                            } else {
                              _selectedCategories.add(cat.key);
                            }
                          }),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? color
                                      : Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: selected
                                        ? color
                                        : Colors.black.withValues(alpha: 0.06),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cat.icon,
                                      size: 14,
                                      color: selected ? Colors.white : color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _categoryLabel(cat.key),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            selected ? Colors.white : AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton "Retour a la fiche" : visible uniquement quand on arrive
          // depuis "Voir sur la carte" d'une activite, sinon Navigator.pop()
          // sortirait vers le HomeScreen (la stack est home -> activite -> map).
          if (_focusedActivityId != null && Navigator.of(context).canPop())
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.06),
                                width: 0.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Bouton "+" pour proposer une activité (au-dessus du recentrer)
          Positioned(
            bottom: 88,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'submit_activity_fab',
              onPressed: () =>
                  Navigator.pushNamed(context, '/submit_activity'),
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              elevation: 3,
              tooltip: s.mapSubmitTooltip,
              child: const Icon(Icons.add, size: 28),
            ),
          ),

          // Bouton recentrer — en mode manuel, retour a la ville choisie ;
          // en mode auto, relance la geoloc GPS.
          Positioned(
            bottom: 20,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'recenter_fab',
              onPressed: _locationModeManual && _hasLocation
                  ? () {
                      try {
                        _mapController.move(_currentPosition, _userZoom);
                      } catch (_) {}
                    }
                  : _determinePosition,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.ink,
              elevation: 2,
              child: Icon(
                _locationModeManual
                    ? Icons.location_city_outlined
                    : Icons.my_location,
              ),
            ),
          ),

          if (_isLoading)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.cyan),
              ),
            ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.cyan : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? Colors.white : AppColors.ink),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _markerColorFor(String? category) {
    final cats = (category ?? '').split(',').map((s) => s.trim().toLowerCase()).toList();
    // 'institution' est automatiquement traité comme event (rouge).
    if (cats.contains('event') || cats.contains('institution')) {
      return const Color(0xFFDC2626);
    }
    final c = cats.isNotEmpty ? cats.first : '';
    switch (c) {
      case 'culture':    return AppColors.brown;
      case 'nature':     return AppColors.green;
      case 'gastronomy': return AppColors.orange;
      case 'sport':      return AppColors.cyan;
      case 'adventure':  return AppColors.yellow;
      case 'relax':      return const Color(0xFFB8A1D9);
      case 'fun':        return AppColors.yellow;
      default:           return AppColors.orange;
    }
  }

  static IconData _markerIconFor(String? category) {
    final cats = (category ?? '').split(',').map((s) => s.trim().toLowerCase()).toList();
    // 'institution' est automatiquement traité comme event.
    if (cats.contains('event') || cats.contains('institution')) return Icons.event;
    final c = cats.isNotEmpty ? cats.first : '';
    switch (c) {
      case 'culture':    return Icons.museum;
      case 'nature':     return Icons.landscape;
      case 'gastronomy': return Icons.restaurant;
      case 'sport':      return Icons.directions_run;
      case 'adventure':  return Icons.hiking;
      case 'relax':      return Icons.spa;
      case 'fun':        return Icons.celebration;
      default:           return Icons.place;
    }
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
            // Drag handle
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
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/activity_detail',
                      arguments: {
                        'activity': activity,
                        'searches_count': 1,
                      },
                    );
                  },
                  child: Text(S.current.activityViewMap),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pin de carte — cercle solide coloré avec icône catégorielle blanche,
/// bordure blanche + ombre portée, et petite tige façon Google Maps moderne.
class _WhatekPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _WhatekPin({required this.color, required this.icon});

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
