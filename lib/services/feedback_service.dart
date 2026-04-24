import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/feedback_question.dart';
import '../models/feedback_submission.dart';

/// Service d'acces aux questionnaires de feedback dynamiques.
///
/// Depuis la migration 0001, les questions sont stockees en BDD
/// (table feedback_questions) et les reponses dans un schema flexible
/// (feedback_submissions + feedback_answers). Le service ci-dessous
/// masque ces details a l'UI.
class FeedbackService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Recupere la liste ordonnee des questions actives pour un type de
  /// questionnaire donne ('hot' ou 'cold').
  Future<List<FeedbackQuestion>> fetchActiveQuestions(
      {required String questionnaireType}) async {
    final data = await _supabase
        .from('feedback_questions')
        .select()
        .eq('questionnaire_type', questionnaireType)
        .eq('is_active', true)
        .order('order_index', ascending: true);

    return (data as List)
        .map((row) => FeedbackQuestion.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Enregistre une soumission complete : cree la ligne feedback_submissions
  /// puis insere les N reponses associees dans feedback_answers.
  Future<bool> submitFeedback({
    required String questionnaireType,
    required int activityId,
    required int searchesCount,
    required List<FeedbackAnswerDraft> answers,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      final submission = await _supabase
          .from('feedback_submissions')
          .insert({
            'user_id': userId,
            'activity_id': activityId,
            'questionnaire_type': questionnaireType,
            'searches_count': searchesCount,
          })
          .select('id')
          .single();

      final submissionId = submission['id'] as String;

      final answerRows = answers
          .where((d) => d.hasAnswer)
          .map((d) => d.toAnswerRow(submissionId))
          .toList();

      if (answerRows.isNotEmpty) {
        await _supabase.from('feedback_answers').insert(answerRows);
      }
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error submitting feedback: $e');
      return false;
    }
  }
}
