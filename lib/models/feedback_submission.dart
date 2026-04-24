import 'feedback_question.dart';

/// Une reponse a une question, en memoire avant envoi.
class FeedbackAnswerDraft {
  final FeedbackQuestion question;
  int? answerRating; // pour rating_5
  bool? answerBool; // pour yes_no
  String? answerText; // pour text
  String? answerChoice; // pour multi_choice

  FeedbackAnswerDraft(this.question);

  /// True si l'utilisateur a donne une reponse valide pour cette question.
  bool get hasAnswer {
    switch (question.answerFormat) {
      case FeedbackAnswerFormat.rating5:
        return answerRating != null && answerRating! >= 1 && answerRating! <= 5;
      case FeedbackAnswerFormat.yesNo:
        return answerBool != null;
      case FeedbackAnswerFormat.text:
        return answerText != null && answerText!.trim().isNotEmpty;
      case FeedbackAnswerFormat.multiChoice:
        return answerChoice != null && answerChoice!.isNotEmpty;
    }
  }

  /// Payload pour l'insertion dans la table feedback_answers.
  Map<String, dynamic> toAnswerRow(String submissionId) {
    return {
      'submission_id': submissionId,
      'question_id': question.id,
      'question_text_snapshot': question.text,
      'question_format_snapshot': question.answerFormat.toDb(),
      if (question.answerFormat == FeedbackAnswerFormat.rating5)
        'answer_rating': answerRating,
      if (question.answerFormat == FeedbackAnswerFormat.yesNo)
        'answer_bool': answerBool,
      if (question.answerFormat == FeedbackAnswerFormat.text)
        'answer_text': answerText?.trim(),
      if (question.answerFormat == FeedbackAnswerFormat.multiChoice)
        'answer_choice': answerChoice,
    };
  }
}
