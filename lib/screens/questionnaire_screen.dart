import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../services/context_service.dart';
import '../services/subscription_service.dart';
import '../widgets/responsive_center.dart';
import '../widgets/subscription_widgets.dart';
import '../widgets/whateka_bottom_nav.dart';
import 'feedback_hot_screen.dart';

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

  // Seuil au-dela duquel on force le popup feedback au start du quiz.
  // Ex : 5 = popup au 6e quiz si l'user a fait 5 quiz precedents sans
  // soumettre aucun feedback (et sans avoir ferme un popup precedent).
  static const int _forcedFeedbackThreshold = 5;

  @override
  void initState() {
    super.initState();
    // Verification differee apres le 1er frame pour eviter de bloquer le
    // rendu initial. Le popup s'affiche en overlay sur le quiz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowForcedFeedbackDialog();
    });
  }

  /// Si l'user a fait >= _forcedFeedbackThreshold quiz sans aucun feedback,
  /// affiche un popup l'invitant a en donner un. Le bouton "Plus tard"
  /// reset le compteur a 0 (pour ne pas spammer l'user a chaque quiz).
  Future<void> _maybeShowForcedFeedbackDialog() async {
    final supa = Supabase.instance.client;
    if (supa.auth.currentUser == null) return; // Anonyme : skip
    int count;
    try {
      final res = await supa.rpc('get_unanswered_quiz_count');
      count = (res as int?) ?? 0;
    } catch (_) {
      return; // RPC fail : on n'embete pas l'user
    }
    if (count < _forcedFeedbackThreshold) return;
    if (!mounted) return;

    final s = S.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // l'user doit choisir explicitement
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(s.feedbackForcedDialogTitle),
        content: Text(s.feedbackForcedDialogBody),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Reset compteur : l'user repondra peut-etre apres 5 quiz de plus
              await _resetUnansweredQuizCount();
            },
            child: Text(s.feedbackForcedDialogClose),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Reset directement : si l'user ferme le questionnaire sans
              // soumettre, on ne le re-spammera pas immediatement.
              await _resetUnansweredQuizCount();
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeedbackHotScreen(activity: null),
                ),
              );
            },
            child: Text(s.activityFeedbackGive),
          ),
        ],
      ),
    );
  }

  Future<void> _resetUnansweredQuizCount() async {
    try {
      await Supabase.instance.client.rpc('reset_unanswered_quiz_count');
    } catch (_) {
      // best-effort
    }
  }

  /// Liste des questions construite dynamiquement à partir de la locale
  /// courante (S.current). Recalculée à chaque build pour suivre la langue.
  List<_QuestionQuestionData> get questions {
    final s = S.current;
    return [
      _QuestionQuestionData(
        s.quizQ1,
        [
          _Option(s.quizSolo, Icons.person, value: 'solo'),
          _Option(s.quizCouple, Icons.favorite, value: 'couple'),
          _Option(s.quizFamily, Icons.family_restroom, value: 'family'),
          _Option(s.quizFriends, Icons.groups, value: 'friends'),
        ],
      ),
      _QuestionQuestionData(
        s.quizQ2,
        [
          _Option(s.quizCatNature, Icons.landscape, value: 'nature'),
          _Option(s.quizCatCulture, Icons.museum, value: 'culture'),
          _Option(s.quizCatRelax, Icons.spa, value: 'relax'),
          _Option(s.quizCatSport, Icons.directions_run, value: 'sport'),
          _Option(s.quizCatGastronomy, Icons.restaurant, value: 'gastronomy'),
          _Option(s.quizCatAdventure, Icons.explore_off, value: 'adventure'),
          _Option(s.quizCatFun, Icons.celebration, value: 'fun'),
          _Option(s.quizCatEvent, Icons.event, value: 'event'),
        ],
        maxSelections: 3,
      ),
      _QuestionQuestionData(
        s.quizQ3,
        [
          _Option(s.quizOutdoor, Icons.wb_sunny, value: 'outdoor'),
          _Option(s.quizIndoor, Icons.home, value: 'indoor'),
          _Option(s.quizAny, Icons.thumbs_up_down, value: 'any'),
        ],
      ),
      _QuestionQuestionData(
        s.quizQ4,
        [
          _Option(s.quizPriceFree, Icons.money_off, value: '1'),
          _Option(s.quizPriceLow, Icons.attach_money, value: '2'),
          _Option(s.quizPriceMid, Icons.currency_exchange, value: '3'),
          _Option(s.quizPriceHigh, Icons.payments, value: '4'),
          _Option(s.quizPriceVeryHigh, Icons.diamond_outlined, value: '5'),
        ],
        maxSelections: 5,
        cascadeLowerTiers: true,
      ),
      _QuestionQuestionData(
        s.quizQ5,
        [
          _Option(s.quizDurationShort, Icons.timer, value: 'short'),
          _Option(s.quizDurationMid, Icons.wb_sunny_outlined, value: 'medium'),
          _Option(s.quizDurationLong, Icons.calendar_today, value: 'long'),
        ],
      ),
    ];
  }

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

    // v34 : verifie le quota avant de lancer la requete IA.
    // Tier free : 5 quiz / 30j. Tier paye : illimite. Le RPC consume_free_quiz()
    // increment atomiquement et retourne allowed=false si quota atteint.
    final quota = await SubscriptionService.instance.consumeFreeQuiz();
    if (!quota.allowed && quota.error == 'quota_exceeded') {
      if (!mounted) return;
      setState(() => _isLoading = false);
      await showPaywallSheet(
        context,
        resetAt: quota.resetAt ?? DateTime.now().add(const Duration(days: 30)),
      );
      return;
    }

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

      // v31 (Smart Recommender Phase 1.2) : on envoie les IDs des activites
      // recemment recommandees pour que l'edge function les penalise dans
      // le scoring (anti-repetition). Les nouvelles recos sont memorisees
      // ensuite par activity_service apres reception du resultat.
      final recentRecsRaw = meta['recent_recommendations'];
      final recentRecommendations = recentRecsRaw is List
          ? recentRecsRaw.whereType<int>().toList()
          : <int>[];

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
        'recent_recommendations': recentRecommendations, // v31 anti-repetition
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

      // Incremente le compteur total de recherches dans user_metadata
      // (utilise par le dashboard du profil).
      final currentCount = (meta['total_searches'] as int?) ?? 0;
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {
            ...meta,
            'total_searches': currentCount + 1,
          }),
        );
      } catch (_) {
        // Si le compteur echoue on continue quand meme la navigation.
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
            content: Text('${S.current.quizContextError}: $e')),
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
                  content: Text(S.current.quizMaxChoicesError
                      .replaceAll('{0}', '$maxSelections'))),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
    final s = S.of(context);
    final question = questions[currentStep];
    final progress = (currentStep + 1) / questions.length;
    final canProceed = selections[currentStep].isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
        // Sur la 1ere question : pas de fleche back (sortie via bottom nav).
        // Sur les questions 2 a 5 : fleche pour revenir d'une etape.
        leading: currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: _handleBack,
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          '${currentStep + 1} / ${questions.length}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/quiz'),
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
                      s.quizBudgetCascadeHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else if (question.maxSelections > 1)
                    Text(
                      s.quizMaxPicks,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grille d'options — aspect ratio calcule dynamiquement pour
            // que TOUTES les options tiennent dans l'espace disponible sans
            // scroll, quelle que soit la taille de l'ecran.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Pour 8 options ou plus, on bascule en 3 colonnes pour
                    // garder des cellules suffisamment hautes sans scroll.
                    final crossAxisCount =
                        question.options.length >= 8 ? 3 : 2;
                    const spacing = 10.0;
                    final rows =
                        (question.options.length / crossAxisCount).ceil();
                    final cellHeight =
                        (constraints.maxHeight - (rows - 1) * spacing) / rows;
                    final cellWidth =
                        (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                            crossAxisCount;
                    // Garde-fou minimal : 56px (icone + label sur 2 lignes).
                    const minCellHeight = 56.0;
                    final aspect = cellHeight > minCellHeight
                        ? cellWidth / cellHeight
                        : cellWidth / minCellHeight;
                    return GridView.builder(
                      physics: cellHeight > minCellHeight
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      itemCount: question.options.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: aspect.clamp(0.6, 2.5),
                      ),
                      itemBuilder: (context, index) {
                        final isSelected =
                            selections[currentStep].contains(index);
                        return _OptionCard(
                          option: question.options[index],
                          selected: isSelected,
                          onTap: () => _toggleSelection(
                              index, question.maxSelections),
                        );
                      },
                    );
                  },
                ),
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
                        ? AppColors.orange
                        : AppColors.line,
                    foregroundColor:
                        canProceed ? Colors.white : AppColors.stone,
                    disabledBackgroundColor: AppColors.line,
                    disabledForegroundColor: AppColors.stone,
                  ),
                  child: Text(
                    currentStep == questions.length - 1
                        ? (_isLoading ? s.loading : s.btnFinish)
                        : s.btnContinue,
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
      },
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
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
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.icon,
                      color: selected ? Colors.white : AppColors.ink,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        option.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: selected ? Colors.white : AppColors.ink,
                              fontSize: 13,
                            ),
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
      ),
    );
  }
}
