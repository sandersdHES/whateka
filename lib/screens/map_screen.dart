import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/whateka_bottom_nav.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ActivityService _activityService = ActivityService();

  // Position par défaut : Sion, Suisse
  LatLng _currentPosition = const LatLng(46.22935, 7.36204);
  LatLng? _targetPosition; // Position cible passée en argument (activité)
  bool _hasLocation = false;
  bool _isLoading = false;
  List<Activity> _activities = [];

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
            // Si une position cible est fournie, centrer dessus; sinon sur l'utilisateur
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
              // Tuiles CartoDB Voyager : look moderne et colore.
              // Gratuit avec attribution (voir RichAttributionWidget en bas).
              // Les sous-domaines a..d repartissent la charge sur plusieurs
              // serveurs CDN.
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.whateka',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  // Position utilisateur — logo Whateka
                  if (_hasLocation)
                    Marker(
                      point: _currentPosition,
                      width: 48,
                      height: 48,
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
                  // Marqueurs d'activités
                  ..._activities.map((activity) => Marker(
                        point: LatLng(activity.latitude, activity.longitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showActivityDetail(activity),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.orange,
                            size: 40,
                          ),
                        ),
                      )),
                ],
              ),
              // Attribution legale CartoDB + OpenStreetMap (obligatoire).
              // Affichee discretement en bas a droite, cliquable pour ouvrir
              // les conditions d'utilisation.
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

          // Bouton recentrer sur ma position
          Positioned(
            bottom: 16,
            right: 24,
            child: FloatingActionButton(
              onPressed: _determinePosition,
              backgroundColor: AppColors.cyan,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),

          // Indicateur de chargement
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

  void _showActivityDetail(Activity activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 450,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    child: activity.imageUrl != null
                        ? Image.network(
                            activity.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.open_in_full,
                            size: 20, color: AppColors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (activity.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              activity.category!,
                              style: const TextStyle(
                                color: AppColors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            const Icon(Icons.place,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              activity.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
