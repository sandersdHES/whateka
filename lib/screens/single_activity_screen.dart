import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/whateka_bottom_nav.dart';
import 'feedback_hot_screen.dart';

class SingleActivityScreen extends StatefulWidget {
  const SingleActivityScreen({super.key});

  @override
  State<SingleActivityScreen> createState() => _SingleActivityScreenState();
}

class _SingleActivityScreenState extends State<SingleActivityScreen> {
  late Activity activity;
  int _searchesCount = 1;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is Map<String, dynamic>) {
        activity = args['activity'] as Activity;
        _searchesCount = (args['searches_count'] as int?) ?? 1;
      } else {
        // Rétrocompatibilité si argument direct Activity
        activity = args as Activity;
      }
      _initialized = true;
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      activity.isFavorite = !activity.isFavorite;
    });
    try {
      await ActivityService().toggleFavorite(activity.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          activity.isFavorite = !activity.isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _openActivityUrl() async {
    if (activity.activityUrl == null || activity.activityUrl!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucune URL disponible pour cette activité')),
        );
      }
      return;
    }

    final Uri url = Uri.parse(activity.activityUrl!);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Impossible d\'ouvrir l\'URL');
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _showFeedbackDialog();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ouverture du lien: $e')),
        );
      }
    }
  }

  void _goToMap() {
    Navigator.pushNamed(
      context,
      '/map',
      arguments: {
        'latitude': activity.latitude,
        'longitude': activity.longitude,
      },
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Votre avis compte !',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Souhaitez-vous partager votre expérience avec cette activité ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Plus tard',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackHotScreen(
                      activity: activity,
                      searchesCount: _searchesCount,
                    ),
                  ),
                );
              },
              child: const Text('Donner mon avis'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/activity_detail'),
      body: CustomScrollView(
        slivers: [
          // Image collapsible en haut
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: AppColors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    activity.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: AppColors.orange,
                    size: 22,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: activity.imageUrl != null
                  ? Image.network(
                      activity.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.cyan),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
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
          ),

          // Contenu scrollable
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge catégorie
                  if (activity.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        activity.category!.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),

                  // Titre
                  Text(
                    activity.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),

                  // Lieu + Durée
                  Row(
                    children: [
                      const Icon(Icons.place,
                          color: AppColors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        activity.location,
                        style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.schedule,
                          color: AppColors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        activity.duration,
                        style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      activity.description ?? 'Aucune description disponible.',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags features
                  if (activity.features.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activity.features
                          .map((feature) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.cyan
                                          .withValues(alpha: 0.4)),
                                  borderRadius: BorderRadius.circular(16),
                                  color:
                                      AppColors.cyan.withValues(alpha: 0.07),
                                ),
                                child: Text(
                                  feature,
                                  style: const TextStyle(
                                      color: AppColors.cyan, fontSize: 13),
                                ),
                              ))
                          .toList(),
                    ),
                  if (activity.features.isNotEmpty) const SizedBox(height: 24),

                  // Mini carte (cliquable → écran Map)
                  GestureDetector(
                    onTap: _goToMap,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                    activity.latitude, activity.longitude),
                                initialZoom: 13.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.whateka',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(activity.latitude,
                                          activity.longitude),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: AppColors.orange,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Overlay "Voir sur la carte"
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.map_outlined,
                                        size: 15, color: AppColors.cyan),
                                    SizedBox(width: 5),
                                    Text(
                                      'Voir sur la carte',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.cyan,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Bouton principal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _openActivityUrl,
                      child: const Text('Visiter le site officiel'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
