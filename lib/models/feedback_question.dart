/// Format de reponse attendu pour une question.
/// Doit rester aligne avec le CHECK constraint cote BDD.
enum FeedbackAnswerFormat {
  rating5, // Bareme 1-5
  yesNo, // Oui / Non
  text, // Texte libre
  multiChoice; // Choix parmi une liste predefinie

  static FeedbackAnswerFormat fromDb(String raw) {
    switch (raw) {
      case 'rating_5':
        return FeedbackAnswerFormat.rating5;
      case 'yes_no':
        return FeedbackAnswerFormat.yesNo;
      case 'text':
        return FeedbackAnswerFormat.text;
      case 'multi_choice':
        return FeedbackAnswerFormat.multiChoice;
      default:
        throw ArgumentError('Format de reponse inconnu: $raw');
    }
  }

  String toDb() {
    switch (this) {
      case FeedbackAnswerFormat.rating5:
        return 'rating_5';
      case FeedbackAnswerFormat.yesNo:
        return 'yes_no';
      case FeedbackAnswerFormat.text:
        return 'text';
      case FeedbackAnswerFormat.multiChoice:
        return 'multi_choice';
    }
  }
}

/// Une question de questionnaire telle que definie en BDD.
class FeedbackQuestion {
  final String id;
  final String questionnaireType; // 'hot' ou 'cold'
  final int orderIndex;
  final String text;
  final FeedbackAnswerFormat answerFormat;
  final List<String> choices; // vide sauf pour multi_choice
  final bool isRequired;
  final bool isActive;

  FeedbackQuestion({
    required this.id,
    required this.questionnaireType,
    required this.orderIndex,
    required this.text,
    required this.answerFormat,
    required this.choices,
    required this.isRequired,
    required this.isActive,
  });

  factory FeedbackQuestion.fromJson(Map<String, dynamic> json) {
    final rawChoices = json['choices'];
    final List<String> parsedChoices = rawChoices is List
        ? rawChoices.map((e) => e.toString()).toList()
        : const [];
    return FeedbackQuestion(
      id: json['id'] as String,
      questionnaireType: json['questionnaire_type'] as String,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      text: json['text'] as String,
      answerFormat: FeedbackAnswerFormat.fromDb(json['answer_format'] as String),
      choices: parsedChoices,
      isRequired: json['is_required'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
