import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/activity.dart';
import '../models/feedback_hot.dart';
import '../services/feedback_service.dart';
import '../widgets/whateka_bottom_nav.dart';

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
  final TextEditingController _commentsController = TextEditingController();

  int _recommendationSatisfaction = 3;
  bool _discoveredNewActivities = false;
  int _personalizationSatisfaction = 3;
  int _informationLevelSatisfaction = 3;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;

    final feedback = FeedbackHot(
      activityId: widget.activity.id,
      userId: userId,
      recommendationSatisfaction: _recommendationSatisfaction,
      discoveredNewActivities: _discoveredNewActivities,
      personalizationSatisfaction: _personalizationSatisfaction,
      informationLevelSatisfaction: _informationLevelSatisfaction,
      comments: _commentsController.text.isNotEmpty
          ? _commentsController.text
          : null,
      searchesCount: widget.searchesCount,
    );

    final success = await _feedbackService.submitHotFeedback(feedback);

    setState(() => _isSubmitting = false);

    if (mounted) {
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
            content: Text('Erreur lors de l\'envoi du feedback'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildRatingScale(
      String question, int currentValue, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final value = index + 1;
            return GestureDetector(
              onTap: () => onChanged(value),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: currentValue == value
                      ? AppColors.orange
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentValue == value
                        ? AppColors.orange
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: currentValue == value
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pas du tout',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('Tout à fait',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête activité
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Merci de prendre quelques instants pour nous donner votre avis !',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Q1
            _buildRatingScale(
              'La recommandation personnalisée correspond à vos attentes ?',
              _recommendationSatisfaction,
              (value) =>
                  setState(() => _recommendationSatisfaction = value),
            ),
            const SizedBox(height: 24),

            // Q2
            const Text(
              'Avez-vous découvert de nouvelles activités grâce à l\'application ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _discoveredNewActivities = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _discoveredNewActivities
                          ? AppColors.orange
                          : Colors.grey[200],
                      foregroundColor: _discoveredNewActivities
                          ? Colors.white
                          : Colors.black87,
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
                    onPressed: () =>
                        setState(() => _discoveredNewActivities = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_discoveredNewActivities
                          ? AppColors.orange
                          : Colors.grey[200],
                      foregroundColor: !_discoveredNewActivities
                          ? Colors.white
                          : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Non'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Q3
            _buildRatingScale(
              'Le niveau de personnalisation est satisfaisant ?',
              _personalizationSatisfaction,
              (value) =>
                  setState(() => _personalizationSatisfaction = value),
            ),
            const SizedBox(height: 24),

            // Q4
            _buildRatingScale(
              'Le niveau d\'information de l\'activité est suffisant ?',
              _informationLevelSatisfaction,
              (value) =>
                  setState(() => _informationLevelSatisfaction = value),
            ),
            const SizedBox(height: 24),

            // Q5 — Commentaire libre
            const Text(
              'Avez-vous une remarque, suggestion ou autre ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez vos commentaires ici...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 32),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.cyan),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Passer',
                        style: TextStyle(color: AppColors.cyan)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text('Envoyer'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
