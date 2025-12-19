import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ActivityService _activityService = ActivityService();

  // Default location: Sion, Switzerland
  LatLng _currentPosition = const LatLng(46.22935, 7.36204);
  bool _hasLocation = false;
  bool _isLoading = false;
  List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];
  double _radiusInKm = 10.0;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final activities = await _activityService.getActivities();
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
          // Initial filter based on user location if available, otherwise just show all or none
          if (_hasLocation) {
            _filterActivities(_currentPosition);
          } else {
            _filterActivities(_mapController.camera.center);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _searchThisArea() {
    // Re-fetch (optional if data is static, but requested by user)
    // Then filter based on MAP CENTER
    _fetchActivities().then((_) {
      if (mounted) {
        _filterActivities(_mapController.camera.center);
      }
    });
  }

  void _filterActivities(LatLng centerPoint) {
    if (_activities.isEmpty) {
      _filteredActivities = [];
      return;
    }

    final distance = const Distance();

    setState(() {
      _filteredActivities = _activities.where((activity) {
        final activityPos = LatLng(activity.latitude, activity.longitude);
        final d = distance.as(LengthUnit.Kilometer, centerPoint, activityPos);
        return d <= _radiusInKm;
      }).toList();
    });
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
          // Initial filter on load
          _filterActivities(_currentPosition);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(_currentPosition, 13.0);
          } catch (e) {
            debugPrint('Map controller error: $e');
          }
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de récupérer la position')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 11.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.whateka',
              ),
              MarkerLayer(
                markers: [
                  // Current User Position
                  if (_hasLocation)
                    Marker(
                      point: _currentPosition,
                      width: 50,
                      height: 50,
                      child: const Column(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: AppColors.cyan,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  // Activity Markers
                  ..._filteredActivities.map((activity) => Marker(
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
            ],
          ),

          // Radius Filter Panel
          Positioned(
            top: 100, // Below AppBar
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rayon de recherche',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${_radiusInKm.toInt()} km',
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _radiusInKm,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    activeColor: AppColors.cyan,
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) {
                      setState(() {
                        _radiusInKm = value;
                        // Don't auto filter heavily, let user decide when to search
                        // OR we can auto-update based on curent center?
                        // Let's stick to "Search" button philosophy but giving visual feedback is nice.
                        // For now, update ONLY if they haven't moved the map significantly?
                        // Let's keep it simple: Slider just updates value. Button applies it.
                        // But user expects visual Feedback usually.
                        // Let's make the button update.
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchThisArea,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.search),
                      label: Text(_isLoading
                          ? 'Recherche...'
                          : 'Rechercher dans cette zone'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Removed manual FAB for location since we want to focus on map interaction mostly,
          // but keeping it is harmless.
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton(
              onPressed: _determinePosition,
              backgroundColor: AppColors.cyan,
              child: const Icon(Icons.my_location, color: Colors.white),
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
            // Image Section
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
                        // Close bottom sheet and navigate to full details
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          '/activity_detail',
                          arguments: activity,
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
            // Info Section
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
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.pushNamed(
                            context,
                            '/activity_detail',
                            arguments: activity,
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
