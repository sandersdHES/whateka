import 'package:flutter/material.dart';
import '../main.dart';
import '../models/activity.dart'; // Will import activity model once refactored to support favorites

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use global list, refresh on build
    final favorites = mockActivities.where((a) => a.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('Aucun favori pour le moment'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final activity = favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        activity.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      activity.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(activity.location),
                    trailing:
                        const Icon(Icons.favorite, color: AppColors.orange),
                  ),
                );
              },
            ),
    );
  }
}
