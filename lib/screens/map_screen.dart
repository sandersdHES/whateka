import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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
    _determinePosition();
    _fetchActivities();
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
            _mapController.move(_targetPosition ?? _currentPosition, 13.0);
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
            _mapController.move(_targetPosition!, 14.0);
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

    return Scaffold(
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/map'),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 11.0,
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
                        width: 44,
                        height: 54,
                        child: GestureDetector(
                          onTap: () => _showActivityDetail(activity),
                          child: _WhatekPin(
                            color: _markerColorFor(activity.category),
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

          // Bouton recentrer
          Positioned(
            bottom: 20,
            right: 24,
            child: FloatingActionButton(
              onPressed: _determinePosition,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.ink,
              elevation: 2,
              child: const Icon(Icons.my_location),
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

/// Pin façon Mapbox — cercle coloré avec logo Whateka au centre + tige.
class _WhatekPin extends StatelessWidget {
  final Color color;
  const _WhatekPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PinPainter(color: color),
      child: SizedBox(
        width: 44,
        height: 54,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 18),
          child: Image.asset(
            'assets/images/home_icon.png',
            fit: BoxFit.contain,
            color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  _PinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // Pointe (triangle vers le bas)
    final path = Path()
      ..moveTo(radius - 6, size.width - 2)
      ..lineTo(radius, size.height)
      ..lineTo(radius + 6, size.width - 2)
      ..close();
    canvas.drawPath(path, paint);

    // Cercle principal
    canvas.drawCircle(center, radius - 2, paint);
    canvas.drawCircle(center, radius - 2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) =>
      oldDelegate.color != color;
}
