import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../services/subscription_service.dart';
import '../widgets/responsive_center.dart';

/// Ecran de selection / mise a niveau d'abonnement.
/// Trois cartes empilees : Decouverte (free), Regional (3 CHF), Evasion (5 CHF).
///
/// Phase 1 : pas de paiement reel. Les boutons "Demarrer" affichent une
/// SnackBar info. La logique de paiement viendra en Phase 2 (Stripe) et
/// Phase 3 (Apple IAP via RevenueCat).
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionState? _state;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await SubscriptionService.instance.fetchCurrentState();
    if (!mounted) return;
    setState(() {
      _state = s;
      _loading = false;
    });
  }

  void _showSoonSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Le paiement sera disponible prochainement. Utilise un code promo en attendant.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          backgroundColor: AppColors.paper,
          appBar: AppBar(
            backgroundColor: AppColors.paper,
            surfaceTintColor: AppColors.paper,
            title: Text(s.subscriptionTitle),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.cyan))
              : ResponsiveCenter(
                  maxWidth: 560,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.subscriptionHeadline,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.subscriptionSubheadline,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        // Carte 1 — Decouverte (Free)
                        _PlanCard(
                          tier: SubscriptionTier.free,
                          accentColor: AppColors.stone,
                          features: [
                            s.subscriptionFreeFeature1,
                            s.subscriptionFreeFeature2,
                            s.subscriptionFreeFeature3,
                            s.subscriptionFreeFeature4,
                          ],
                          isCurrent: _state?.tier == SubscriptionTier.free,
                          onTap: null,
                        ),
                        const SizedBox(height: 12),
                        // Carte 2 — Regional (3 CHF)
                        _PlanCard(
                          tier: SubscriptionTier.regional,
                          accentColor: AppColors.cyan,
                          isHighlighted: true,
                          highlightLabel: s.subscriptionMostPopular,
                          features: [
                            s.subscriptionRegionalFeature1,
                            s.subscriptionRegionalFeature2,
                            s.subscriptionRegionalFeature3,
                            s.subscriptionRegionalFeature4,
                          ],
                          isCurrent: _state?.tier == SubscriptionTier.regional,
                          onTap: _showSoonSnack,
                          ctaLabel: s.subscriptionStartTrial,
                        ),
                        const SizedBox(height: 12),
                        // Carte 3 — Evasion (5 CHF)
                        _PlanCard(
                          tier: SubscriptionTier.evasion,
                          accentColor: const Color(0xFFD4A04A),
                          features: [
                            s.subscriptionEvasionFeature1,
                            s.subscriptionEvasionFeature2,
                            s.subscriptionEvasionFeature3,
                            s.subscriptionEvasionFeature4,
                          ],
                          isCurrent: _state?.tier == SubscriptionTier.evasion,
                          onTap: _showSoonSnack,
                          ctaLabel: s.subscriptionStartTrial,
                        ),
                        const SizedBox(height: 24),
                        // Lien code promo
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                  context, '/promo_code');
                              _load(); // refresh apres redemption
                            },
                            icon: const Icon(Icons.local_offer_outlined,
                                size: 18, color: AppColors.cyan),
                            label: Text(
                              s.subscriptionPromoCodeButton,
                              style: const TextStyle(color: AppColors.cyan),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.subscriptionDisclaimer,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.stone),
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

/// Carte de plan : titre + prix + bullets + CTA.
class _PlanCard extends StatelessWidget {
  final SubscriptionTier tier;
  final Color accentColor;
  final List<String> features;
  final bool isCurrent;
  final bool isHighlighted;
  final String? highlightLabel;
  final VoidCallback? onTap;
  final String? ctaLabel;

  const _PlanCard({
    required this.tier,
    required this.accentColor,
    required this.features,
    required this.isCurrent,
    this.isHighlighted = false,
    this.highlightLabel,
    this.onTap,
    this.ctaLabel,
  });

  String _title(BuildContext context) {
    final s = S.of(context);
    return switch (tier) {
      SubscriptionTier.free => s.subscriptionFreeTitle,
      SubscriptionTier.regional => s.subscriptionRegionalTitle,
      SubscriptionTier.evasion => s.subscriptionEvasionTitle,
    };
  }

  String _emoji() => switch (tier) {
        SubscriptionTier.free => '🌱',
        SubscriptionTier.regional => '🗺️',
        SubscriptionTier.evasion => '🌍',
      };

  String _priceLabel(BuildContext context) {
    final s = S.of(context);
    if (tier == SubscriptionTier.free) return s.subscriptionPriceFree;
    return '${tier.priceChf.toStringAsFixed(0)} ${s.subscriptionPriceMonth}';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? accentColor : AppColors.line,
          width: isHighlighted ? 1.5 : 0.5,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isHighlighted && highlightLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(19)),
              ),
              child: Text(
                '⭐  $highlightLabel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_emoji(), style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Text(
                      _title(context),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _priceLabel(context),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (tier != SubscriptionTier.free) ...[
                  const SizedBox(height: 4),
                  Text(
                    s.subscriptionTrialHint,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.stone),
                  ),
                ],
                const SizedBox(height: 16),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 18, color: accentColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                if (isCurrent)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.line.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      s.subscriptionCurrentPlan,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.stone),
                    ),
                  )
                else if (onTap != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: onTap,
                    child: Text(
                      ctaLabel ?? s.subscriptionStartTrial,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
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
