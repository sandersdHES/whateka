import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feedback_hot.dart';

class FeedbackService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Soumettre un feedback à chaud
  Future<bool> submitHotFeedback(FeedbackHot feedback) async {
    try {
      await _supabase.from('feedback_hot').insert(feedback.toJson());
      return true;
    } catch (e) {
      print('Error submitting hot feedback: $e');
      return false;
    }
  }

  /// Vérifier si un feedback a déjà été soumis pour une activité
  Future<bool> hasSubmittedFeedback(int activityId, String? userId) async {
    try {
      if (userId == null) return false;
      
      final response = await _supabase
          .from('feedback_hot')
          .select('id')
          .eq('activity_id', activityId)
          .eq('user_id', userId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('Error checking feedback: $e');
      return false;
    }
  }
}
