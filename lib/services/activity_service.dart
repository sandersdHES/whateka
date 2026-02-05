import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';
import '../models/ai_response.dart';

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

  /// Get AI-powered activity recommendations based on user preferences and context
  Future<AiResponse> getAIRecommendations({
    required Map<String, dynamic> userPrefs,
    required Map<String, dynamic> context,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // 1. Call Supabase Edge Function
      final response = await _supabase.functions.invoke(
        'recommend-activity',
        body: {
          "user_id": userId,
          "user_prefs": userPrefs,
          "context": context,
        },
      );

      final data = response.data;

      // Handle case where AI returns no recommendations
      if (data == null || data['recommendations'] == null) {
        return AiResponse(
          activities: [],
          globalComment: "Aucune suggestion trouvée pour ces critères.",
        );
      }

      final recommendations = data['recommendations'] as List;
      final globalComment = data['global_comment'] as String? ?? "";

      // 2. Extract recommended activity IDs
      final List<int> ids = recommendations.map((r) => r['id'] as int).toList();

      if (ids.isEmpty) {
        return AiResponse(activities: [], globalComment: globalComment);
      }

      // 3. Fetch full activity details from database
      final dbResponse =
          await _supabase.from('activities').select().inFilter('id', ids);

      // 4. Merge DB data with AI reasoning and preserve AI ranking order
      final Map<int, Activity> activityMap = {};

      for (var json in dbResponse as List) {
        final activity = Activity.fromJson(json);
        activityMap[activity.id] = activity;
      }

      // Build final list in the order provided by AI recommendations
      final List<Activity> sortedActivities = [];
      for (var recData in recommendations) {
        final activityId = recData['id'] as int;
        final activity = activityMap[activityId];

        if (activity != null) {
          // Attach AI-generated reasoning to the activity
          activity.aiReason = recData['match_reason'] as String?;
          sortedActivities.add(activity);
        }
      }

      return AiResponse(
        activities: sortedActivities,
        globalComment: globalComment,
      );
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des recommandations IA: $e');
    }
  }
}
