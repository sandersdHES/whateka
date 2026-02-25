import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/feedback_hot.dart';
import '../services/feedback_service.dart';

class FeedbackHotScreen extends StatefulWidget {
  final Activity activity;

  const FeedbackHotScreen({super.key, required this.activity});

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

    final feedback = FeedbackHot(
      activityId: widget.activity.id,
      userId: 'anonymous_user', // TODO: Remplacer par l'ID utilisateur réel
      recommendationSatisfaction: _recommendationSatisfaction,
      discoveredNewActivities: _discoveredNewActivities,
      personalizationSatisfaction: _personalizationSatisfaction,
      informationLevelSatisfaction: _informationLevelSatisfaction,
      comments: _commentsController.text.isNotEmpty 
          ? _commentsController.text 
          : null,
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
        // Retourner à l'accueil en supprimant toutes les routes précédentes
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

  Widget _buildRatingScale(String question, int currentValue, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                      ? const Color(0xFF1E3A8A) 
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentValue == value 
                        ? const Color(0xFF1E3A8A) 
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
                      color: currentValue == value ? Colors.white : Colors.black87,
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
            Text(
              'Pas du tout',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Tout à fait',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
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
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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

            // Question 1
            _buildRatingScale(
              'La recommandation personnalisée correspond à vos attentes ?',
              _recommendationSatisfaction,
              (value) => setState(() => _recommendationSatisfaction = value),
            ),
            const SizedBox(height: 24),

            // Question 2
            const Text(
              'Avez-vous découvert de nouvelles activités grâce à l\'application ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _discoveredNewActivities = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _discoveredNewActivities 
                          ? const Color(0xFF1E3A8A) 
                          : Colors.grey[200],
                      foregroundColor: _discoveredNewActivities 
                          ? Colors.white 
                          : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Oui'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _discoveredNewActivities = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_discoveredNewActivities 
                          ? const Color(0xFF1E3A8A) 
                          : Colors.grey[200],
                      foregroundColor: !_discoveredNewActivities 
                          ? Colors.white 
                          : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Non'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Question 3
            _buildRatingScale(
              'Le niveau de personnalisation est satisfaisant ?',
              _personalizationSatisfaction,
              (value) => setState(() => _personalizationSatisfaction = value),
            ),
            const SizedBox(height: 24),

            // Question 4
            _buildRatingScale(
              'Le niveau d\'information de l\'activité est suffisant ?',
              _informationLevelSatisfaction,
              (value) => setState(() => _informationLevelSatisfaction = value),
            ),
            const SizedBox(height: 24),

            // Question 5
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
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 32),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Passer',
                      style: TextStyle(color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Envoyer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
