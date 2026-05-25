import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../models/activity.dart';
import '../models/ai_response.dart';

class ActivityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Activity>> getActivities({
    int? limit,
    int offset = 0,
    List<int> excludeIds = const [],
    /// Si true, applique le filtre temporel isProposableAt(now) cote client
    /// (pour le bouton "Plus d'idees" qui sinon proposait des foires d'octobre
    /// en mai et du ski en juillet). On sur-fetche 4x le limit demande pour
    /// compenser les activites filtrees, puis on tronque.
    bool proposableOnly = false,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // 1. Fetch activities (exclut les ids deja affiches cote serveur pour
      //    eviter d'avoir un offset cassé et des doublons en pagination).
      var filter = _supabase
          .from('activities')
          .select()
          // v37 : toujours exclure les activites archivees (etait un trou,
          // "Plus d'idees" pouvait remonter des fiches retirees).
          .eq('archived', false);
      if (excludeIds.isNotEmpty) {
        filter = filter.not('id', 'in', '(${excludeIds.join(',')})');
      }
      var query = filter.order('created_at', ascending: false);

      // Sur-fetch quand proposableOnly pour compenser le filtre client.
      // Heuristique : x4 + 5 pour avoir une marge meme si 75% sont filtrees.
      final fetchLimit = limit != null && proposableOnly ? (limit * 4) + 5 : limit;
      if (fetchLimit != null) {
        query = query.range(offset, offset + fetchLimit - 1);
      }
      final List<dynamic> data = await query;
      var activities = data.map((json) => Activity.fromJson(json)).toList();

      if (proposableOnly) {
        final now = DateTime.now();
        activities = activities.where((a) => a.isProposableAt(now)).toList();
        if (limit != null && activities.length > limit) {
          activities = activities.sublist(0, limit);
        }
      }

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

  /// Recupere N activites supplementaires APRES un quiz, en utilisant les
  /// memes preferences (categories, budget, environnement, duree, social,
  /// region, rayon) + meteo que le quiz initial. Appelle la RPC SQL
  /// `score_activities` qui :
  ///   - filtre temporellement (is_activity_proposable_now)
  ///   - filtre par categorie / budget / region / environnement
  ///   - score selon les memes regles que le quiz (pertinence + qualite +
  ///     meteo + recence + profil de gout)
  ///   - retourne triees par score DESC
  ///
  /// Utilise par le bouton "Plus d'idees" sur AiResultScreen pour proposer
  /// des activites coherentes avec ce que l'user vient de demander.
  Future<List<Activity>> getMoreScoredActivities({
    required Map<String, dynamic> userPrefs,
    required Map<String, dynamic> contextData,
    required List<int> excludeIds,
    int limit = 3,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    final location = contextData['location'];
    final weather = contextData['weather'];
    final lat = (location is Map) ? location['latitude'] : null;
    final lng = (location is Map) ? location['longitude'] : null;

    final List<dynamic> recentIdsRaw = (userPrefs['recent_recommendations']
            as List<dynamic>?) ??
        const [];

    // On demande plus pour avoir une marge apres filtre des excludeIds.
    final fetchLimit = limit + excludeIds.length + 10;

    final response = await _supabase.rpc('score_activities', params: {
      'p_categories':
          (userPrefs['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      'p_price_levels':
          (userPrefs['price_levels'] as List<dynamic>?)?.cast<int>() ?? [],
      'p_price_max': userPrefs['price_max'] ?? 5,
      'p_environment': (userPrefs['environment'] as String?) ?? '',
      'p_region': (userPrefs['region'] as String?) ?? '',
      'p_duration': (userPrefs['duration'] as String?) ?? '',
      'p_social': (userPrefs['social'] as String?) ?? '',
      'p_radius_km': userPrefs['radius_km'],
      'p_user_lat': lat,
      'p_user_lng': lng,
      'p_user_id': userId,
      'p_recent_ids': recentIdsRaw.cast<int>(),
      'p_weather_code': (weather is Map) ? weather['weather_code'] : null,
      'p_weather_temp': (weather is Map) ? weather['temperature'] : null,
      'p_limit': fetchLimit,
    });

    if (response is! List) return [];
    final excludeSet = excludeIds.toSet();
    final picked = <Activity>[];
    for (final row in response) {
      if (row is! Map) continue;
      final id = row['id'];
      if (id is int && excludeSet.contains(id)) continue;
      picked.add(Activity.fromJson(Map<String, dynamic>.from(row)));
      if (picked.length >= limit) break;
    }
    return picked;
  }

  Future<List<Activity>> getFavoriteActivities() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Fetch favorites with related activity data
      // 1. Fetch favorite activity IDs first (robust against join errors)
      final favoritesResponse = await _supabase
          .from('favorites')
          .select('activity_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<int> ids = (favoritesResponse as List)
          .map((e) => e['activity_id'] as int)
          .toList();

      if (ids.isEmpty) return [];

      // 2. Fetch the actual activities
      final activitiesResponse =
          await _supabase.from('activities').select().inFilter('id', ids);

      final activitiesMap = {
        for (var item in (activitiesResponse as List))
          item['id'] as int: Activity.fromJson(item)
      };

      // 3. Reconstruct list in correct order (most recently favorited first)
      final List<Activity> activities = [];
      for (var id in ids) {
        final activity = activitiesMap[id];
        if (activity != null) {
          activity.isFavorite = true;
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

  /// v31 (Smart Recommender) : memorise les nouvelles recommandations dans
  /// user_metadata.recent_recommendations en mode "FIFO" capee a 30. Les
  /// nouvelles entrees passent devant. Sert a l'algo edge function pour
  /// penaliser les activites deja vues (anti-repetition).
  Future<void> _persistRecentRecommendations(List<int> newIds) async {
    final user = _supabase.auth.currentUser;
    if (user == null || newIds.isEmpty) return;
    final meta = user.userMetadata ?? {};
    final raw = meta['recent_recommendations'];
    final existing = raw is List
        ? raw.whereType<int>().toList()
        : <int>[];
    // Prepend nouveaux IDs, deduplique en gardant l'ordre, cap a 30.
    final merged = <int>[...newIds];
    for (final id in existing) {
      if (!merged.contains(id)) merged.add(id);
    }
    if (merged.length > 30) merged.removeRange(30, merged.length);
    await _supabase.auth.updateUser(
      UserAttributes(data: {
        ...meta,
        'recent_recommendations': merged,
      }),
    );
  }

  /// Get AI-powered activity recommendations based on user preferences and context
  Future<AiResponse> getAIRecommendations({
    required Map<String, dynamic> userPrefs,
    required Map<String, dynamic> context,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // 1. Call Supabase Edge Function
      // Locale courante (fr/en) pour que Gemini genere match_reason et
      // global_comment dans la bonne langue.
      final user = _supabase.auth.currentUser;
      final locale = (user?.userMetadata?['locale'] as String?) ?? 'fr';
      final response = await _supabase.functions.invoke(
        'recommend-activity',
        body: {
          "user_id": userId,
          "user_prefs": userPrefs,
          "context": context,
          "locale": locale,
        },
      );

      final data = response.data;

      // Handle case where AI returns no recommendations
      if (data == null || data['recommendations'] == null) {
        return AiResponse(
          activities: [],
          globalComment: S.current.aiNoSuggestionsFound,
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

      // v31 (Smart Recommender Phase 1.2) : memorise les IDs recommandes
      // dans user_metadata.recent_recommendations pour que la prochaine
      // requete penalise les activites deja vues. Les plus recents en
      // premier, capees a 30 entrees pour eviter de gonfler indefiniment.
      // Echec silencieux : si l'ecriture rate, l'algo continuera juste
      // sans la penalite recence.
      try {
        await _persistRecentRecommendations(ids);
      } catch (_) {
        // ignore : pas critique
      }

      return AiResponse(
        activities: sortedActivities,
        globalComment: globalComment,
      );
    } on FunctionException catch (e) {
      if (e.status == 429 ||
          (e.details != null && e.details.toString().contains('429'))) {
        throw Exception(S.current.aiServerOverloaded);
      }
      throw Exception(
          '${S.current.aiErrorPrefix} (${e.status}): ${e.reasonPhrase ?? e.details ?? S.current.aiUnknownError}');
    } catch (e) {
      if (e.toString().contains('429')) {
        throw Exception(S.current.aiServerOverloaded);
      }
      throw Exception('${S.current.aiFetchError}: $e');
    }
  }
}
