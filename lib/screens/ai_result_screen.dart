import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../models/activity.dart';
import '../models/ai_response.dart';
import '../widgets/fun_loading_widget.dart';
import '../widgets/whateka_bottom_nav.dart';
import '../widgets/activity_card.dart';
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

      final more = await _activityService.getActivities(
        limit: 3,
        offset: _extraActivities.length,
      );

      final filtered = more.where((a) => !_shownIds.contains(a.id)).toList();

      if (mounted) {
        setState(() {
          _extraActivities.addAll(filtered);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pour vous'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sous-titre
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 20),
                  child: Text(
                    '${response.activities.length} suggestions · cet après-midi',
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

                // Medium activities
                ...mediumActivities.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ActivityCard(
                            activity: a,
                            size: ActivityCardSize.medium,
                            onTap: () => _openDetail(a),
                          ),
                          if (a.aiReason != null && a.aiReason!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _AiReasonChip(reason: a.aiReason!),
                          ],
                        ],
                      ),
                    )),

                // Activités supplémentaires
                if (_extraActivities.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'D\'autres idées',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._extraActivities.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ActivityCard(
                          activity: a,
                          size: ActivityCardSize.medium,
                          onTap: () => _openDetail(a),
                        ),
                      )),
                ],

                const SizedBox(height: 4),

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
                        _isLoadingMore ? 'Chargement...' : 'Plus d\'idées'),
                  ),
                ),
              ],
            ),
          );
        },
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
    final isOverload = error.contains('surchargé');
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
              isOverload ? 'Forte affluence' : 'Une erreur est survenue',
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
              label: const Text('Réessayer'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 56, color: AppColors.stone),
            const SizedBox(height: 16),
            Text('Aucune activité trouvée',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.stone,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Recommencer'),
            ),
          ],
        ),
      ),
    );
  }
}
