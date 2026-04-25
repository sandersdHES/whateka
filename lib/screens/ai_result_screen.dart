import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../services/activity_service.dart';
import '../models/activity.dart';
import '../models/ai_response.dart';
import '../widgets/fun_loading_widget.dart';
import '../widgets/whateka_bottom_nav.dart';
import '../widgets/activity_card.dart';
import '../widgets/responsive_center.dart';
import '../main.dart';

class AiResultScreen extends StatefulWidget {
  final Map<String, dynamic> userPrefs;
  final Map<String, dynamic> contextData;

  const AiResultScreen({
    super.key,
    required this.userPrefs,
    required this.contextData,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  final ActivityService _activityService = ActivityService();
  late Future<AiResponse> _aiFuture;

  final List<Activity> _extraActivities = [];
  bool _isLoadingMore = false;
  int _searchesCount = 1;
  Set<int> _shownIds = {};

  @override
  void initState() {
    super.initState();
    _aiFuture = _activityService.getAIRecommendations(
      userPrefs: widget.userPrefs,
      context: widget.contextData,
    );
  }

  Future<void> _loadMoreActivities(List<Activity> currentActivities) async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      _shownIds = {
        ...currentActivities.map((a) => a.id),
        ..._extraActivities.map((a) => a.id),
      };

      // Use excludeIds (côté serveur) pour avoir TOUJOURS 3 nouvelles
      // activités non encore vues, peu importe leur position.
      final more = await _activityService.getActivities(
        limit: 3,
        excludeIds: _shownIds.toList(),
      );

      if (mounted) {
        setState(() {
          _extraActivities.addAll(more);
          _searchesCount++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _openDetail(Activity activity) {
    Navigator.pushNamed(
      context,
      '/activity_detail',
      arguments: {
        'activity': activity,
        'searches_count': _searchesCount,
      },
    );
  }

  /// Label du moment de la journée selon l'heure courante (locale-aware).
  String _periodLabel(BuildContext context) {
    final hour = DateTime.now().hour;
    final s = S.of(context);
    if (hour < 12) return s.resultPeriodMorning;
    if (hour < 18) return s.resultPeriodAfternoon;
    if (hour < 23) return s.resultPeriodEvening;
    return s.resultPeriodNight;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
      appBar: AppBar(
        title: Text(s.resultTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/quiz'),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(s.resultRetry),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cyan,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/ai_result'),
      body: FutureBuilder<AiResponse>(
        future: _aiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: FunLoadingWidget());
          } else if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _aiFuture = _activityService.getAIRecommendations(
                    userPrefs: widget.userPrefs,
                    context: widget.contextData,
                  );
                });
              },
            );
          } else if (!snapshot.hasData || snapshot.data!.activities.isEmpty) {
            return const _EmptyState();
          }

          final response = snapshot.data!;
          final heroActivity = response.activities.first;
          final mediumActivities = response.activities.skip(1).toList();

          return ResponsiveCenter(
            maxWidth: 560,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sous-titre
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 20),
                    child: Text(
                      '${response.activities.length} ${S.of(context).resultSuggestionsLabel} · ${_periodLabel(context)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),

                  // Commentaire IA global (optionnel, épuré)
                  if (response.globalComment.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.line, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 18, color: AppColors.cyan),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              response.globalComment,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Hero activity
                  ActivityCard(
                    activity: heroActivity,
                    size: ActivityCardSize.hero,
                    onTap: () => _openDetail(heroActivity),
                  ),
                  if (heroActivity.aiReason != null &&
                      heroActivity.aiReason!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _AiReasonChip(reason: heroActivity.aiReason!),
                  ],
                  const SizedBox(height: 20),

                  // Medium activities — grille 2 colonnes (côte à côte)
                  if (mediumActivities.isNotEmpty)
                    _MediumGrid(
                      activities: mediumActivities,
                      onTap: _openDetail,
                    ),

                  // Activités supplémentaires
                  if (_extraActivities.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        s.moreIdeasBtn,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MediumGrid(
                      activities: _extraActivities,
                      onTap: _openDetail,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Bouton "Plus d'activités" épuré
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingMore
                          ? null
                          : () => _loadMoreActivities(
                                [...response.activities, ..._extraActivities],
                              ),
                      icon: _isLoadingMore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.cyan),
                            )
                          : const Icon(Icons.refresh, size: 18),
                      label: Text(
                          _isLoadingMore ? s.loading : s.moreIdeasBtn),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
      },
    );
  }
}

class _MediumGrid extends StatelessWidget {
  final List<Activity> activities;
  final void Function(Activity) onTap;

  const _MediumGrid({required this.activities, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 200,
      ),
      itemCount: activities.length,
      itemBuilder: (_, i) => ActivityCard(
        activity: activities[i],
        size: ActivityCardSize.medium,
        onTap: () => onTap(activities[i]),
      ),
    );
  }
}

class _AiReasonChip extends StatelessWidget {
  final String reason;
  const _AiReasonChip({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              size: 16, color: AppColors.cyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.ink,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // 'surchargé' / 'overloaded' depending on locale
    final isOverload =
        error.contains('surchargé') || error.toLowerCase().contains('overload');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOverload ? Icons.hourglass_empty : Icons.error_outline,
              size: 56,
              color: isOverload ? AppColors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isOverload ? s.errorOverloadTitle : s.errorGeneric,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.stone,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(s.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 56, color: AppColors.stone),
            const SizedBox(height: 16),
            Text(s.emptyNoActivities,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              s.emptyNoActivitiesHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.stone,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(s.resultRetry),
            ),
          ],
        ),
      ),
    );
  }
}
