import 'package:flutter/material.dart';
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
              'Merci de repondre a : ${missing.first}${missing.length > 1 ? " (+${missing.length - 1} autre(s))" : ""}'),
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
        const SnackBar(
          content: Text('Merci pour votre feedback !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de l'envoi du feedback"),
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
            child: const Text('Oui'),
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
            child: const Text('Non'),
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
        hintText: 'Votre reponse...',
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildMultiChoice(FeedbackAnswerDraft draft) {
    if (draft.question.choices.isEmpty) {
      return const Text(
        '(Aucune option configuree)',
        style: TextStyle(color: Colors.red),
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
                Text('Pas du tout',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text('Tout à fait',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre avis compte !'),
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
                      'Impossible de charger le questionnaire.',
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
                      label: const Text('Reessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final drafts = snapshot.data ?? [];
          if (drafts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Aucune question de feedback n'est active pour le moment. Merci !",
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
                  padd