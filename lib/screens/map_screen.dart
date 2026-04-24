import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
    if (_searchQuery.isEmpty) return _activities;
    final q = _searchQuery.toLowerCase();
    return _activities.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q) ||
          (a.category?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                        child: GestureDetector(
                          onTap: () => _showActivityDetail(activity),
                          child: _WhatekPin(
                            color: _markerColorFor(activity.category),
                            icon: _markerIconFor(activity.category),
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

          // Barre de recherche flottante en haut (verre dépoli)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ClipRRect(
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
                            decoration: const InputDecoration(
                              hintText: 'Rechercher une activité',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
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
              tooltip: 'Proposer une activité',
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
  }

  static Color _markerColorFor(String? category) {
    final c = (category ?? '').split(',').first.trim().toLowerCase();
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
    final c = (category ?? '').split(',').first.trim().toLowerCase();
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
                  child: const Text('Voir les détails'),
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
