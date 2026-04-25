import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../models/activity.dart';
import '../models/feedback_question.dart';
import '../models/feedback_submission.dart';
import '../services/feedback_service.dart';
import '../widgets/whateka_bottom_nav.dart';

/// Ecran de feedback "a chaud" affiche apres selection d'une activite.
///
/// Depuis la migration 0001 (avril 2026), les questions sont chargees
/// dynamiquement depuis Supabase (table feedback_questions, type='hot').
/// L'admin peut donc les ajouter/modifier/reorganiser sans avoir a redeployer
/// l'app mobile.
class FeedbackHotScreen extends StatefulWidget {
  final Activity activity;
  final int searchesCount;

  const FeedbackHotScreen({
    super.key,
    required this.activity,
    this.searchesCount = 1,
  });

  @override
  State<FeedbackHotScreen> createState() => _FeedbackHotScreenState();
}

class _FeedbackHotScreenState extends State<FeedbackHotScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  late Future<List<FeedbackAnswerDraft>> _draftsFuture;

  bool _isSubmitting = false;
  // Controllers pour les questions de type texte libre (gardes dans un map
  // pour etre disposes correctement)
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _draftsFuture = _loadDrafts();
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<List<FeedbackAnswerDraft>> _loadDrafts() async {
    final questions =
        await _feedbackService.fetchActiveQuestions(questionnaireType: 'hot');
    return questions.map((q) {
      final draft = FeedbackAnswerDraft(q);
      if (q.answerFormat == FeedbackAnswerFormat.text) {
        _textControllers.putIfAbsent(q.id, () => TextEditingController());
      }
      return draft;
    }).toList();
  }

  Future<void> _submitFeedback(List<FeedbackAnswerDraft> drafts) async {
    // Transferer le contenu des controllers texte dans les drafts
    for (final d in drafts) {
      if (d.question.answerFormat == FeedbackAnswerFormat.text) {
        d.answerText = _textControllers[d.question.id]?.text;
      }
    }

    // Validation des questions obligatoires
    final missing = drafts
        .where((d) => d.question.isRequired && !d.hasAnswer)
        .map((d) => d.question.text)
        .toList();
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${S.current.feedbackPlsAnswer} : ${missing.first}${missing.length > 1 ? " (+${missing.length - 1})" : ""}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _feedbackService.submitFeedback(
      questionnaireType: 'hot',
      activityId: widget.activity.id,
      searchesCount: widget.searchesCount,
      answers: drafts,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.feedbackThanks),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.feedbackSendError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================================
  // Widgets par type de question
  // ==========================================================================

  Widget _buildRating5(FeedbackAnswerDraft draft) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final value = index + 1;
        final selected = draft.answerRating == value;
        return GestureDetector(
          onTap: () => setState(() => draft.answerRating = value),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: selected ? AppColors.orange : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.orange : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildYesNo(FeedbackAnswerDraft draft) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => draft.answerBool = true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  draft.answerBool == true ? AppColors.orange : Colors.grey[200],
              foregroundColor:
                  draft.answerBool == true ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(S.current.yes),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => draft.answerBool = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: draft.answerBool == false
                  ? AppColors.orange
                  : Colors.grey[200],
              foregroundColor:
                  draft.answerBool == false ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(S.current.no),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(FeedbackAnswerDraft draft) {
    final controller = _textControllers[draft.question.id] ??=
        TextEditingController();
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: S.current.feedbackTextHint,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildMultiChoice(FeedbackAnswerDraft draft) {
    if (draft.question.choices.isEmpty) {
      return Text(
        S.current.feedbackNoOptions,
        style: const TextStyle(color: Colors.red),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: draft.question.choices.map((choice) {
        final selected = draft.answerChoice == choice;
        return ChoiceChip(
          label: Text(choice),
          selected: selected,
          onSelected: (_) => setState(() => draft.answerChoice = choice),
          selectedColor: AppColors.orange,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestion(FeedbackAnswerDraft draft) {
    Widget input;
    switch (draft.question.answerFormat) {
      case FeedbackAnswerFormat.rating5:
        input = Column(
          children: [
            _buildRating5(draft),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.current.feedbackRatingNotAtAll,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(S.current.feedbackRatingFully,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        );
        break;
      case FeedbackAnswerFormat.yesNo:
        input = _buildYesNo(draft);
        break;
      case FeedbackAnswerFormat.text:
        input = _buildTextField(draft);
        break;
      case FeedbackAnswerFormat.multiChoice:
        input = _buildMultiChoice(draft);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.question.text +
              (draft.question.isRequired ? ' *' : ''),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        input,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(s.feedbackTitle),
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBar:
              const WhatekBottomNav(currentRoute: '/feedback_hot'),
          body: FutureBuilder<List<FeedbackAnswerDraft>>(
            future: _draftsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          s.feedbackQuestionnaireLoadError,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {
                            _draftsFuture = _loadDrafts();
                          }),
                          icon: const Icon(Icons.refresh),
                          label: Text(s.feedbackRetry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final drafts = snapshot.data ?? [];
              if (drafts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      s.feedbackNoQuestionsActive,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tete activite
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickLocalized(widget.activity.title, widget.activity.titleEn),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.feedbackHeader,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Questions dynamiques
                    ...drafts.map((draft) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildQuestion(draft),
                        )),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.cyan),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(s.feedbackSkip,
                                style: const TextStyle(color: AppColors.cyan)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => _submitFeedback(drafts),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orange,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(s.feedbackSubmit),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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