import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
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
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Votre avis compte'),
          content: const Text(
            'Souhaitez-vous partager votre expérience avec cette activité ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Plus tard'),
            ),
            ElevatedButton(
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

  String _siteName() {
    if (activity.activityUrl == null || activity.activityUrl!.isEmpty) {
      return 'le site';
    }
    try {
      final host = Uri.parse(activity.activityUrl!).host;
      return host.replaceFirst('www.', '');
    } catch (_) {
      return 'le site';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero photo
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.42,
                  width: double.infinity,
                  child: activity.imageUrl != null
                      ? Image.network(
                          activity.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.line,
                            child: const Icon(Icons.broken_image,
                                size: 50, color: AppColors.stone),
                          ),
                        )
                      : Container(
                          color: AppColors.line,
                          child: const Icon(Icons.image_not_supported,
                              size: 50, color: AppColors.stone),
                        ),
                ),
              ),

              // Panneau blanc qui overlap légèrement la photo
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Catégorie
                        if (activity.category != null) ...[
                          Text(
                            activity.category!.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8),
                        ],
                        // Titre
                        Text(
                          activity.title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        // Lieu + Durée
                        Row(
                          children: [
                            const Icon(Icons.place_outlined,
                                size: 16, color: AppColors.stone),
                            const SizedBox(width: 6),
                            Text(
                              activity.location,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.schedule,
                                size: 16, color: AppColors.stone),
                            const SizedBox(width: 6),
                            Text(
                              activity.duration,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          activity.description ??
                              'Aucune description disponible.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 28),

                        // Informations utiles
                        if (activity.features.isNotEmpty) ...[
                          Text(
                            'Informations utiles',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: activity.features
                                .map((feature) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: AppColors.line,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        feature,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(color: AppColors.ink),
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // Mini carte
                        GestureDetector(
                          onTap: _goToMap,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: 180,
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                          activity.latitude,
                                          activity.longitude),
                                      initialZoom: 13.0,
                                      interactionOptions:
                                          const InteractionOptions(
                                        flags: InteractiveFlag.none,
                                      ),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                                        subdomains: const ['a', 'b', 'c', 'd'],
                                        userAgentPackageName:
                                            'com.example.whateka',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(activity.latitude,
                                                activity.longitude),
                                            width: 36,
                                            height: 36,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.orange,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.map_outlined,
                                              size: 14,
                                              color: AppColors.ink),
                                          SizedBox(width: 5),
                                          Text(
                                            'Voir sur la carte',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.ink,
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
                        const SizedBox(height: 24),

                        // CTA principal pleine largeur
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _openActivityUrl,
                            child: Text('Voir sur ${_siteName()}'),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Boutons back + favori flottants en verre dépoli
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  _GlassIconButton(
                    icon: activity.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    iconColor: activity.isFavorite
                        ? AppColors.orange
                        : AppColors.ink,
                    onTap: _toggleFavorite,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
            child: Icon(icon, size: 18, color: iconColor ?? AppColors.ink),
          ),
        ),
      ),
    );
  }
}
