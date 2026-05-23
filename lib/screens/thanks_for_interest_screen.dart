import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../services/subscription_service.dart';
import '../widgets/responsive_center.dart';

/// Ecran "Merci pour ton intérêt" affiché à la place du checkout Stripe/Apple
/// tant que l'équipe Whateka ne facture pas encore les abonnements.
///
/// Flow :
///   1. L'utilisateur clique "Start trial" sur la subscription screen
///   2. On le redirige ici → message de remerciement + code WA2026 offert
///   3. Il active le code en un tap → 3 mois d'Évasion gratuit
class ThanksForInterestScreen extends StatefulWidget {
  /// Tier sélectionné par l'utilisateur (juste pour message contextuel).
  final SubscriptionTier? tier;

  const ThanksForInterestScreen({super.key, this.tier});

  @override
  State<ThanksForInterestScreen> createState() =>
      _ThanksForInterestScreenState();
}

class _ThanksForInterestScreenState extends State<ThanksForInterestScreen> {
  bool _busy = false;

  Future<void> _applyPromoCode() async {
    setState(() => _busy = true);
    final result = await SubscriptionService.instance.redeemPromoCode('WA2026');
    if (!mounted) return;
    setState(() => _busy = false);
    final s = S.current;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.promoCodeSuccess
                .replaceAll('{months}', '${result.durationMonths ?? 3}'),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
      return;
    }

    final msg = switch (result.error) {
      'already_redeemed' => s.promoCodeErrorAlreadyRedeemed,
      'code_not_found' => s.promoCodeErrorNotFound,
      'code_inactive' => s.promoCodeErrorInactive,
      'code_expired' => s.promoCodeErrorExpired,
      'code_exhausted' => s.promoCodeErrorExhausted,
      'not_authenticated' => s.promoCodeErrorNotAuthenticated,
      _ => s.promoCodeErrorGeneric,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(const ClipboardData(text: 'WA2026'));
    if (!mounted) return;
    final s = S.current;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.thanksCodeCopied),
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
            title: Text(s.thanksTitle),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ResponsiveCenter(
            maxWidth: 560,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Heart / coeur en haut
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 42,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Headline
                  Text(
                    s.thanksHeadline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Intro
                  Text(
                    s.thanksIntro,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.stone,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // Carte cadeau
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.cyan,
                          Color(0xFF0099B8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.card_giftcard_rounded,
                                color: Colors.white, size: 26),
                            const SizedBox(width: 10),
                            Text(
                              s.thanksGiftLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.thanksGiftValue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.thanksGiftBenefit,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Code box
                        GestureDetector(
                          onTap: _copyCode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.thanksGiftCode,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.copy_rounded,
                                    color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // CTA Activer
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.cyan,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: _busy ? null : _applyPromoCode,
                          child: _busy
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.cyan,
                                  ),
                                )
                              : Text(
                                  s.thanksApplyNow,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section "Comment nous aider"
                  Text(
                    s.thanksSupportTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.thanksSupportIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.stone,
                        ),
                  ),
                  const SizedBox(height: 14),
                  _SupportItem(
                    icon: Icons.campaign_rounded,
                    text: s.thanksSupportBullet1,
                  ),
                  _SupportItem(
                    icon: Icons.add_location_alt_rounded,
                    text: s.thanksSupportBullet2,
                  ),
                  _SupportItem(
                    icon: Icons.favorite_border_rounded,
                    text: s.thanksSupportBullet3,
                  ),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      s.thanksClose,
                      style: const TextStyle(color: AppColors.stone),
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

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SupportItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
