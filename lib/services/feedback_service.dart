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
        .