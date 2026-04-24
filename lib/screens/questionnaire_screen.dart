import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../services/context_service.dart';
import '../widgets/whateka_bottom_nav.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _Option {
  final String label;
  final IconData icon;
  final String? value; // For logic checks (like 'outdoor')
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

  // Use Set<int> for multiple selections per step
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
      // Cascade : tap sur un budget selectionne aussi tous les budgets inferieurs.
      // L'utilisateur peut ensuite deselectionner individuellement une case.
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
    if (selections[currentStep].isEmpty) return; // Prevent empty step if needed

    if (currentStep < questions.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      // Final step: Fetch context and navigate
      _finishQuestionnaire();
    }
  }

  Future<void> _finishQuestionnaire() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Extract user preferences from questionnaire responses
      String getSingleValue(int stepIndex) {
        final selectedIndex = selections[stepIndex].first;
        return questions[stepIndex].options[selectedIndex].value ?? '';
      }

      // Support multi-selection for categories (step 1)
      List<String> getMultipleValues(int stepIndex) {
        return selections[stepIndex]
            .map((i) => questions[stepIndex].options[i].value ?? '')
            .where((v) => v.isNotEmpty)
            .toList();
      }

      // Lire le rayon de recherche depuis les métadonnées utilisateur
      final user = Supabase.instance.client.auth.currentUser;
      final radiusKm = user?.userMetadata?['search_radius_km'] as int? ?? 50;

      // Budget : la question supporte desormais la multi-selection en cascade.
      // On envoie la liste exacte des niveaux selectionnes (price_levels) ET
      // un price_max pour retrocompatibilite avec les versions < v19 du backend.
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
        'categories': getMultipleValues(1), // multi-catégories
        'category': getSingleValue(1),      // rétrocompatibilité
        'environment': getSingleValue(2),
        'price_max': priceMax,              // 1-5, plafond (retrocompat)
        'price_levels': priceLevels,        // liste explicite (v19+)
        'duration': getSingleValue(4),
        'radius_km': radiusKm,
      };

      // Get real context data
      final contextData = await _contextService.getFullContext();

      if (!mounted) return;

      // Navigate to AI result screen
      Navigator.pushNamed(
        context,
        '/ai_result',
        arguments: {
          'prefs': userPrefs,
          'context': contextData, // Real data passed here
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

      // Mode cascade (budget) : tap sur un tier ajoute tous les tiers inferieurs,
      // deselection libre ensuite.
      if (question.cascadeLowerTiers) {
        if (selectionsForStep.contains(index)) {
          // Deselection : on enleve uniquement ce tier-la
          selectionsForStep.remove(index);
        } else {
          // Selection : on ajoute ce tier ET tous les tiers d'index inferieur
          for (int i = 0; i <= index; i++) {
            selectionsForStep.add(i);
          }
        }
        return;
      }

      // Mode classique (simple ou multi-selection bornee)
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Étape ${currentStep + 1}/${questions.length}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _handleBack,
        ),
      ),
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/quiz'),
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
                  child: Column(
                    children: [
                      Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                  height: 1.3,
                                ),
                      ),
                      if (question.cascadeLowerTiers)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Les budgets inférieurs sont inclus automatiquement (désélectionnables)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                        )
                      else if (question.maxSelections > 1)
                        Text(
                          "(Choix multiple: ${question.maxSelections} max)",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                    ],
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
                      onPressed: (canProceed && !_isLoading) ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canProceed ? AppColors.orange : Colors.grey[300],
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
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final _Option option;
  final bool selected;
  final VoidCallback onTap;

  const _Option