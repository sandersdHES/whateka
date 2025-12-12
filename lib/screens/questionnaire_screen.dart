import 'package:flutter/material.dart';
import '../main.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _Option {
  final String label;
  final IconData icon;
  const _Option(this.label, this.icon);
}

class _QuestionQuestionData {
  final String question;
  final List<_Option> options;
  const _QuestionQuestionData(this.question, this.options);
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int currentStep = 0;
  final List<int> selections = [0, 0, 0, 0, 0];

  final List<_QuestionQuestionData> questions = const [
    _QuestionQuestionData(
      "Avec qui partez-vous ?",
      [
        _Option('Solo', Icons.person),
        _Option('En couple', Icons.favorite),
        _Option('En famille', Icons.family_restroom),
        _Option('Entre amis', Icons.groups),
      ],
    ),
    _QuestionQuestionData(
      "Quelle est votre envie du moment ?",
      [
        _Option('Nature', Icons.landscape),
        _Option('Culture', Icons.museum),
        _Option('Détente', Icons.spa),
        _Option('Sport', Icons.directions_run),
      ],
    ),
    _QuestionQuestionData(
      "Quel type d'ambiance ?",
      [
        _Option('Calme', Icons.nights_stay),
        _Option('Animé', Icons.local_activity),
        _Option('Culturel', Icons.auto_stories),
        _Option('Aventure', Icons.explore),
      ],
    ),
    _QuestionQuestionData(
      "Quel est votre budget ?",
      [
        _Option('Gratuit', Icons.money_off),
        _Option('Éco', Icons.attach_money),
        _Option('Modéré', Icons.currency_exchange),
        _Option('Luxe', Icons.diamond),
      ],
    ),
    _QuestionQuestionData(
      "Combien de temps ?",
      [
        _Option('Quelques h.', Icons.timer),
        _Option('Demi-journée', Icons.wb_sunny),
        _Option('Journée', Icons.calendar_today),
        _Option('Week-end', Icons.weekend),
      ],
    ),
  ];

  void _nextStep() {
    if (currentStep < questions.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.pushNamed(context, '/activity');
    }
  }

  void _handleBack() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentStep];
    final progress = (currentStep + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Étape ${currentStep + 1}/${questions.length}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _handleBack,
        ),
      ),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withValues(alpha: 0.03),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      color: AppColors.cyan,
                      backgroundColor: AppColors.cyan.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Question Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    question.question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          height: 1.3,
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // Options Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: question.options.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = selections[currentStep] == index;
                      return _OptionCard(
                        option: question.options[index],
                        selected: isSelected,
                        onTap: () =>
                            setState(() => selections[currentStep] = index),
                      );
                    },
                  ),
                ),

                // Bottom Button
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(currentStep == questions.length - 1
                          ? 'Terminer'
                          : 'Continuer'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final _Option option;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.cyan : const Color(0xFFE6ECEA),
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.cyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                color: selected ? Colors.white : AppColors.cyan,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppColors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
