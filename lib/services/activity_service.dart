import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Activity>> getActivities({int? limit}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // 1. Fetch activities
      var query = _supabase
          .from('activities')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }
      final List<dynamic> data = await query;
      final activities = data.map((json) => Activity.fromJson(json)).toList();

      // 2. Fetch user favorites if logged in
      if (userId != null) {
        final favoritesResponse = await _supabase
            .from('favorites')
            .select('activity_id')
            .eq('user_id', userId);

        final favoriteIds = (favoritesResponse as List)
            .map((e) => e['activity_id'] as int)
            .toSet();

        for (var activity in activities) {
          if (favoriteIds.contains(activity.id)) {
            activity.isFavorite = true;
          }
        }
      }

      return activities;
    } catch (e) {
      throw Exception('Error fetching activities: $e');
    }
  }

  Future<List<Activity>> getFavoriteActivities() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Fetch favorites with related activity data
      // Note: This relies on Supabase detecting the Foreign Key relation between favorites.activity_id and activities.id
      final response = await _supabase
          .from('favorites')
          .select('activities(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<Activity> activities = [];
      for (var item in response as List) {
        if (item['activities'] != null) {
          final activity = Activity.fromJson(item['activities']);
          activity.isFavorite =
              true; // It's in the favorites table, so it is true
          activities.add(activity);
        }
      }
      return activities;
    } catch (e) {
      throw Exception('Error fetching favorites: $e');
    }
  }

  Future<void> toggleFavorite(int activityId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // Check if already favorite
      final existing = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('activity_id', activityId)
          .maybeSingle();

      if (existing != null) {
        // Remove
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('activity_id', activityId);
      } else {
        // Add
        await _supabase.from('favorites').insert({
          'user_id': userId,
          'activity_id': activityId,
        });
      }
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
  }
}
