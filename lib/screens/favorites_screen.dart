import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/activity_card.dart';
import '../widgets/responsive_center.dart';
import '../widgets/whateka_bottom_nav.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ActivityService _activityService = ActivityService();
  late Future<List<Activity>> _favoritesFuture;

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/favorites'),
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
                  'Erreur: ${snapshot.error}',
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
                      'Aucun favori pour le moment',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tapez sur le cœur d\'une activité pour la retrouver ici.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.stone,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          final favorites = snapshot.data!;

          return ResponsiveCenter(
            maxWidth: 560,
            child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    '${favorites.length} ${favorites.length > 1 ? "activités" : "activité"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
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
                                    const SnackBar(
                                        content: Text(
                                            'Erreur lors de la suppression')),
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
        },
      ),
    );
      },
    );
  }
}
