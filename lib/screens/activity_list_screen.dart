import 'package:flutter/material.dart';
import '../main.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/activity_card.dart';
import '../widgets/fun_loading_widget.dart';
import '../widgets/whateka_bottom_nav.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final ActivityService _activityService = ActivityService();

  List<Activity>? _activities;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _searchesCount = 1;
  static const int _pageSize = 6;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final activities =
          await _activityService.getActivities(limit: _pageSize, offset: 0);
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _activities == null) return;
    setState(() => _isLoadingMore = true);

    try {
      final more = await _activityService.getActivities(
        limit: _pageSize,
        offset: _activities!.length,
      );

      if (mounted) {
        setState(() {
          _activities!.addAll(more);
          _searchesCount++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: FunLoadingWidget());
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Une erreur est survenue : $_error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        bottomNavigationBar: const WhatekBottomNav(currentRoute: '/activity'),
      );
    }

    final activities = _activities;
    if (activities == null || activities.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Aucune activité trouvée.')),
        bottomNavigationBar: const WhatekBottomNav(currentRoute: '/activity'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/activity'),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text(
                '${activities.length} activités',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 200,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final activity = activities[index];
                  return ActivityCard(
                    activity: activity,
                    size: ActivityCardSize.medium,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/activity_detail',
                        arguments: {
                          'activity': activity,
                          'searches_count': _searchesCount,
                        },
                      ).then((_) => setState(() {}));
                    },
                  );
                },
                childCount: activities.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingMore ? null : _loadMore,
                  icon: _isLoadingMore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.cyan),
                        )
                      : const Icon(Icons.add, size: 18),
                  label: Text(
                      _isLoadingMore ? 'Chargement...' : 'Plus d\'activités'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
