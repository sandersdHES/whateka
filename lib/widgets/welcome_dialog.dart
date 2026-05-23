import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';

/// Dialog d'onboarding affiche UNE SEULE FOIS apres l'inscription
/// d'un nouvel utilisateur (ou a la premiere connexion d'un compte
/// existant qui n'a jamais vu le welcome).
///
/// Logique du gating :
///   - On lit user_metadata.has_seen_welcome
///   - Si null/false : on affiche le dialog et on pose le flag a true
///     a la fermeture (succes ou skip).
///   - Si true : pas de dialog.
///
/// Affiche le tier Decouverte (free) en sous-tetage et propose d'activer
/// un code promo (WA2026 -> 3 mois d'Evasion offert) en un tap.
class WelcomeDialog {
  /// Affiche le dialog si l'user n'a pas encore vu le welcome.
  /// Best-effort : echec silencieux si Supabase indisponible.
  static Future<void> showIfNeeded(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final hasSeen = user.userMetadata?['has_seen_welcome'] == true;
    if (hasSeen) return;

    // Petit delay pour eviter de superposer le splash en cours.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _WelcomeDialogContent(),
    );

    // Marquer comme vu, quel que soit le bouton clique.
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'has_seen_welcome': true}),
      );
    } catch (_) {
      // best-effort : si l'update echoue, le dialog re-apparaitra au prochain
      // lancement, ce qui est moins pire que de l'avoir cache definitivement.
    }
  }
}

class _WelcomeDialogContent extends StatelessWidget {
  const _WelcomeDialogContent();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Dialog(
          backgroundColor: AppColors.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo cyan rond avec icone
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.waving_hand_rounded,
                        size: 38,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Titre
                  Text(
                    s.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.welcomeIntro,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.stone,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Carte mode Decouverte
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🌱', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s.welcomeDiscoveryTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _Bullet(text: s.welcomeDiscoveryBullet1),
                        _Bullet(text: s.welcomeDiscoveryBullet2),
                        _Bullet(text: s.welcomeDiscoveryBullet3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Promo callout
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.orange.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.card_giftcard_rounded,
                            color: AppColors.orange, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.welcomePromoIntro,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // CTAs
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Petit delay pour laisser le pop terminer avant la nav.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamed('/promo_code');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.local_offer_outlined, size: 18),
                    label: Text(
                      s.welcomeHasCode,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.stone,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(s.welcomeLater),
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

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_rounded, size: 16, color: AppColors.cyan),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
