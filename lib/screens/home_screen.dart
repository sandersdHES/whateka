import 'package:flutter/material.dart';
import '../main.dart';
import '../i18n/strings.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/language_toggle.dart';
import '../widgets/responsive_center.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          backgroundColor: AppColors.surface,
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
                    color: AppColors.cyan.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orange.withValues(alpha: 0.05),
                  ),
                ),
              ),
              SafeArea(
                child: ResponsiveCenter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/home_icon.png',
                          height: 150,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'WHATEKA',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: AppColors.cyan,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.appTagline,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.cyan,
                                  ),
                        ),
                        const SizedBox(height: 32),
                        const _ActivityShowcase(),
                        const SizedBox(height: 24),
                        const _CommunityBanner(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(s.btnLogin),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(s.btnSignup),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(child: LanguageToggle()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Bandeau qui met en avant la fonctionnalité "proposer une activité", pour
/// donner envie de rejoindre la communauté Whateka dès la page d'accueil.
class _CommunityBanner extends StatelessWidget {
  const _CommunityBanner();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppColors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              s.homeCommunityMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.ink,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carrousel horizontal d'images d'activités réelles (issues de Supabase),
/// pour donner un aperçu attrayant du contenu de l'app dès la page d'accueil
/// (avant même la connexion). Échec silencieux si le chargement échoue : la
/// page d'accueil reste utilisable (connexion/inscription) même hors-ligne.
class _ActivityShowcase extends StatefulWidget {
  const _ActivityShowcase();

  @override
  State<_ActivityShowcase> createState() => _ActivityShowcaseState();
}

class _ActivityShowcaseState extends State<_ActivityShowcase> {
  late final Future<List<Activity>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadShowcase();
  }

  Future<List<Activity>> _loadShowcase() async {
    try {
      // Sur-fetch pour pouvoir filtrer celles sans photo et garder les plus
      // attrayantes (activités certifiées Whateka en priorité).
      final activities = await ActivityService().getActivities(limit: 24);
      final withPhoto =
          activities.where((a) => (a.imageUrl ?? '').isNotEmpty).toList();
      withPhoto.sort((a, b) {
        if (a.isWhatekaCertified == b.isWhatekaCertified) return 0;
        return a.isWhatekaCertified ? -1 : 1;
      });
      return withPhoto.take(8).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FutureBuilder<List<Activity>>(
      future: _future,
      builder: (context, snapshot) {
        final activities = snapshot.data ?? const [];
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 140,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cyan,
                ),
              ),
            ),
          );
        }
        if (activities.isEmpty) {
          // Rien à montrer (hors-ligne, ou aucune activité avec photo) : on
          // n'affiche rien plutôt qu'un espace vide disgracieux.
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                s.homeShowcaseTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.stone,
                    ),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: activities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) =>
                    _ShowcaseCard(activity: activities[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  final Activity activity;
  const _ShowcaseCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            width: 160,
            height: 140,
            child: Image.network(
              activity.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.line),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            child: Text(
              pickLocalized(activity.title, activity.titleEn),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
