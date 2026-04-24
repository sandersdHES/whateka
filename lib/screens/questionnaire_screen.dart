import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../services/context_service.dart';
import '../widgets/responsive_center.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _Option {
  final String label;
  final IconData icon;
  final String? value;
  const _Option(this.label, this.icon, {this.value});
}

class _QuestionQuestionData {
  final String question;
  final List<_Option> options;
  final int maxSelections;
  // Si true, tap sur une option inclut automatiquement toutes les options
  // d'index inferieur (cascade), avec deselection individuelle possible.
  // Utilise pour le budget : choisir 1-20 CHF coche aussi Gratuit.
  final bool cascadeLowerTiers;
  const _QuestionQuestionData(this.question, this.options,
      {this.maxSelections = 1, this.cascadeLowerTiers = false});
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int currentStep = 0;
  bool _isLoading = false;
  final ContextService _contextService = ContextService();

  final List<Set<int>> selections = [{}, {}, {}, {}, {}, {}];

  final List<_QuestionQuestionData> questions = const [
    _QuestionQuestionData(
      "Avec qui partez-vous ?",
      [
        _Option('Solo', Icons.person, value: 'solo'),
        _Option('En couple', Icons.favorite, value: 'couple'),
        _Option('En famille', Icons.family_restroom, value: 'family'),
        _Option('Entre amis', Icons.groups, value: 'friends'),
      ],
    ),
    _QuestionQuestionData(
      "Quelle est votre envie du moment ?",
      [
        _Option('Nature', Icons.landscape, value: 'nature'),
        _Option('Culture', Icons.museum, value: 'culture'),
        _Option('Détente', Icons.spa, value: 'relax'),
        _Option('Sport', Icons.directions_run, value: 'sport'),
        _Option('Gourmandise', Icons.restaurant, value: 'gastronomy'),
        _Option('Aventure', Icons.explore_off, value: 'adventure'),
        _Option('Fun', Icons.celebration, value: 'fun'),
      ],
      maxSelections: 3,
    ),
    _QuestionQuestionData(
      "Envie d'extérieur ou d'intérieur ?",
      [
        _Option('Outdoor', Icons.wb_sunny, value: 'outdoor'),
        _Option('Indoor', Icons.home, value: 'indoor'),
        _Option('Egal', Icons.thumbs_up_down, value: 'any'),
      ],
    ),
    _QuestionQuestionData(
      "Quel est votre budget ?",
      [
        _Option('Gratuit', Icons.money_off, value: '1'),
        _Option('1–20 CHF', Icons.attach_money, value: '2'),
        _Option('20–50 CHF', Icons.currency_exchange, value: '3'),
        _Option('50–100 CHF', Icons.payments, value: '4'),
        _Option('100+ CHF', Icons.diamond_outlined, value: '5'),
      ],
      maxSelections: 5,
      cascadeLowerTiers: true,
    ),
    _QuestionQuestionData(
      "Combien de temps ?",
      [
        _Option('Quelques h.', Icons.timer, value: 'short'),
        _Option('Demi-journée', Icons.wb_sunny_outlined, value: 'medium'),
        _Option('Journée', Icons.calendar_today, value: 'long'),
      ],
    ),
  ];

  void _nextStep() {
    if (selections[currentStep].isEmpty) return;

    if (currentStep < questions.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      _finishQuestionnaire();
    }
  }

  Future<void> _finishQuestionnaire() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String getSingleValue(int stepIndex) {
        final selectedIndex = selections[stepIndex].first;
        return questions[stepIndex].options[selectedIndex].value ?? '';
      }

      List<String> getMultipleValues(int stepIndex) {
        return selections[stepIndex]
            .map((i) => questions[stepIndex].options[i].value ?? '')
            .where((v) => v.isNotEmpty)
            .toList();
      }

      final user = Supabase.instance.client.auth.currentUser;
      final meta = user?.userMetadata ?? {};
      final radiusKm = meta['search_radius_km'] as int? ?? 50;
      final region = (meta['search_region'] as String?) ?? '';
      final locationMode = (meta['location_mode'] as String?) ?? 'auto';

      // Budget : la question supporte la multi-selection en cascade.
      // On envoie la liste exacte (price_levels) ET un price_max pour retrocompat.
      final priceLevels = getMultipleValues(3)
          .map((v) => int.tryParse(v))
          .whereType<int>()
          .toList()
        ..sort();
      final priceMax = priceLevels.isEmpty
          ? 3
          : priceLevels.reduce((a, b) => a > b ? a : b);

      final userPrefs = {
        'social': getSingleValue(0),
        'categories': getMultipleValues(1),
        'category': getSingleValue(1),
        'environment': getSingleValue(2),
        'price_max': priceMax,
        'price_levels': priceLevels,
        'duration': getSingleValue(4),
        'radius_km': radiusKm,
        'region': region, // v22 : filtre canton-wide (Vaud/Valais) prioritaire
      };

      final contextData = await _contextService.getFullContext();
      // Si position manuelle : on ecrase la location GPS par la ville choisie.
      if (locationMode == 'manual') {
        final manualLat = (meta['manual_lat'] as num?)?.toDouble();
        final manualLng = (meta['manual_lng'] as num?)?.toDouble();
        if (manualLat != null && manualLng != null) {
          contextData['location'] = {
            'latitude': manualLat,
            'longitude': manualLng,
          };
        }
      }

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/ai_result',
        arguments: {
          'prefs': userPrefs,
          'context': contextData,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la récupération du contexte: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _toggleSelection(int index, int maxSelections) {
    setState(() {
      final question = questions[currentStep];
      final selectionsForStep = selections[currentStep];

      // Mode cascade (budget) : tap sur un tier ajoute tous les tiers inferieurs.
      if (question.cascadeLowerTiers) {
        if (selectionsForStep.contains(index)) {
          selectionsForStep.remove(index);
        } else {
          for (int i = 0; i <= index; i++) {
            selectionsForStep.add(i);
          }
        }
        return;
      }

      if (selectionsForStep.contains(index)) {
        selectionsForStep.remove(index);
      } else {
        if (maxSelections == 1) {
          selectionsForStep.clear();
          selectionsForStep.add(index);
        } else {
          if (selectionsForStep.length < maxSelections) {
            selectionsForStep.add(index);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Maximum $maxSelections choix possible(s)')),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentStep];
    final progress = (currentStep + 1) / questions.length;
    final canProceed = selections[currentStep].isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: AppColors.paper,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: _handleBack,
        ),
        title: Text(
          '${currentStep + 1} / ${questions.length}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 560,
          child: Column(
          children: [
            // Progress bar fine cyan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  color: AppColors.cyan,
                  backgroundColor: AppColors.line,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Question (grande typo Display)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 10),
                  if (question.cascadeLowerTiers)
                    Text(
                      'Les budgets inférieurs sont inclus automatiquement (désélectionnables).',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else if (question.maxSelections > 1)
                    Text(
                      'Jusqu\'à ${question.maxSelections} choix',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grille d'options
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                itemCount: question.options.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final isSelected =
                      selections[currentStep].contains(index);
                  return _OptionCard(
                    option: question.options[index],
                    selected: isSelected,
                    onTap: () =>
                        _toggleSelection(index, question.maxSelections),
                  );
                },
              ),
            ),

            // Bouton continuer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (canProceed && !_isLoading) ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canProceed
                        ? AppColors.cyan
                        : AppColors.line,
                    foregroundColor:
                        canProceed ? Colors.white : AppColors.stone,
                    disabledBackgroundColor: AppColors.line,
                    disabledForegroundColor: AppColors.stone,
                  ),
                  child: Text(
                    currentStep == questions.length - 1
                        ? (_isLoading ? 'Chargement...' : 'Terminer')
                        : 'Continuer',
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.line,
            width: 0.5,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    option.icon,
                    color: selected ? Colors.white : AppColors.ink,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color:
                              selected ? Colors.white : AppColors.ink,
                        ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9), width: 1),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.orange,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
