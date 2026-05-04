import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../services/subscription_service.dart';

/// Helper de formatage de date sans dependance externe (intl).
/// Format : "12 mai 2026" (FR) ou "May 12, 2026" (EN).
String _fmtDate(BuildContext context, DateTime d) {
  final lang = Localizations.localeOf(context).languageCode;
  const fr = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];
  const en = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  if (lang == 'en') {
    return '${en[d.month - 1]} ${d.day}, ${d.year}';
  }
  return '${d.day} ${fr[d.month - 1]} ${d.year}';
}

/// Bottom-sheet affichee quand l'utilisateur free atteint le quota 5/5.
/// Propose les tiers Regional et Evasion + lien vers code promo.
///
/// Usage :
///   await showPaywallSheet(context, resetAt: state.freePeriodEndsAt);
Future<void> showPaywallSheet(
  BuildContext context, {
  required DateTime resetAt,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PaywallSheet(resetAt: resetAt),
  );
}

class _PaywallSheet extends StatelessWidget {
  final DateTime resetAt;
  const _PaywallSheet({required this.resetAt});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Center(
              child: Text('🚀', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 12),
            Text(
              s.paywallTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              s.paywallSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.stone),
            ),
            const SizedBox(height: 20),
            _PaywallTier(
              emoji: '🗺️',
              title: s.subscriptionRegionalTitle,
              priceLabel: '3 ${s.subscriptionPriceMonth}',
              subtitle: s.paywallRegionalSubtitle,
              accentColor: AppColors.cyan,
              isPrimary: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/subscription');
              },
            ),
            const SizedBox(height: 8),
            _PaywallTier(
              emoji: '🌍',
              title: s.subscriptionEvasionTitle,
              priceLabel: '5 ${s.subscriptionPriceMonth}',
              subtitle: s.paywallEvasionSubtitle,
              accentColor: const Color(0xFFD4A04A),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/subscription');
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.pushNamed(context, '/promo_code');
              },
              child: Text(s.paywallPromoCodeButton,
                  style: const TextStyle(color: AppColors.cyan)),
            ),
            const SizedBox(height: 4),
            Text(
              s.paywallResetHint.replaceAll('{date}', _fmtDate(context, resetAt)),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.paywallLater,
                  style: const TextStyle(color: AppColors.stone)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaywallTier extends StatelessWidget {
  final String emoji;
  final String title;
  final String priceLabel;
  final String subtitle;
  final Color accentColor;
  final bool isPrimary;
  final VoidCallback onTap;

  const _PaywallTier({
    required this.emoji,
    required this.title,
    required this.priceLabel,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPrimary ? accentColor.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary ? accentColor : AppColors.line,
              width: isPrimary ? 1.2 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text(priceLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.stone)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 14, color: accentColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet pour changer le canton (tier 'regional' uniquement).
/// Limite a 1 changement par 30 jours glissants.
Future<void> showRegionChangeSheet(
  BuildContext context, {
  required SubscriptionState state,
  required VoidCallback onChanged,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RegionChangeSheet(
      state: state,
      onChanged: onChanged,
    ),
  );
}

class _RegionChangeSheet extends StatefulWidget {
  final SubscriptionState state;
  final VoidCallback onChanged;
  const _RegionChangeSheet({required this.state, required this.onChanged});

  @override
  State<_RegionChangeSheet> createState() => _RegionChangeSheetState();
}

class _RegionChangeSheetState extends State<_RegionChangeSheet> {
  late String _selected;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.state.selectedRegion ?? 'vaud';
  }

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await SubscriptionService.instance.changeRegion(_selected);
    if (!mounted) return;
    setState(() => _busy = false);
    if (res.success) {
      Navigator.pop(context);
      widget.onChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.regionChangeSuccess),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final s = S.current;
    setState(() {
      _error = switch (res.error) {
        'too_soon' => s.regionChangeErrorTooSoon,
        'not_regional_tier' => s.regionChangeErrorNotRegional,
        _ => s.regionChangeErrorGeneric,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final canChange = widget.state.canChangeRegion;
    final nextChangeAt = widget.state.nextRegionChangeAt;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              s.regionChangeTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _RegionChoice(
                    label: 'Vaud',
                    emoji: '🟢',
                    selected: _selected == 'vaud',
                    onTap: canChange
                        ? () => setState(() => _selected = 'vaud')
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RegionChoice(
                    label: 'Valais',
                    emoji: '🔵',
                    selected: _selected == 'valais',
                    onTap: canChange
                        ? () => setState(() => _selected = 'valais')
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!canChange && nextChangeAt != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.yellow.withValues(alpha: 0.5),
                      width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 18, color: Color(0xFF8B6F00)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.regionChangeNextOn
                            .replaceAll('{date}', _fmtDate(context, nextChangeAt)),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: const Color(0xFF8B6F00)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                s.regionChangeWarning,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.stone),
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFB71C1C)),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: canChange && !_busy ? _confirm : null,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(s.regionChangeConfirm),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.btnCancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionChoice extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback? onTap;

  const _RegionChoice({
    required this.label,
    required this.emoji,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.cyan : AppColors.line,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte "Abonnement" affichee dans le profil. Affiche le tier courant +
/// progression du quota free / date d'expiration / bouton upgrade ou
/// gestion. Tape pour aller a l'ecran d'abonnement complet.
class SubscriptionCard extends StatelessWidget {
  final SubscriptionState state;
  final VoidCallback onUpgrade;
  final VoidCallback onChangeRegion;
  const SubscriptionCard({
    super.key,
    required this.state,
    required this.onUpgrade,
    required this.onChangeRegion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 0.5),
      ),
      child: switch (state.tier) {
        SubscriptionTier.free =>
          _FreeBlock(state: state, onUpgrade: onUpgrade),
        SubscriptionTier.regional =>
          _RegionalBlock(state: state, onChangeRegion: onChangeRegion, onUpgrade: onUpgrade),
        SubscriptionTier.evasion => _EvasionBlock(state: state),
      },
    );
  }
}

class _FreeBlock extends StatelessWidget {
  final SubscriptionState state;
  final VoidCallback onUpgrade;
  const _FreeBlock({required this.state, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final remaining = state.freeQuizzesRemaining;
    final progress = (state.freeQuizzesUsed / SubscriptionState.freeQuotaLimit)
        .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              s.subscriptionFreeTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: remaining == 0 ? AppColors.orange : AppColors.cyan,
            backgroundColor: AppColors.line,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s.subscriptionQuizUsage
              .replaceAll('{used}', '${state.freeQuizzesUsed}')
              .replaceAll('{limit}', '${SubscriptionState.freeQuotaLimit}'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          s.subscriptionResetOn
              .replaceAll('{date}', _fmtDate(context, state.freePeriodEndsAt)),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.stone),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: onUpgrade,
          icon: const Icon(Icons.rocket_launch_outlined, size: 18),
          label: Text(s.subscriptionGoPremium),
        ),
      ],
    );
  }
}

class _RegionalBlock extends StatelessWidget {
  final SubscriptionState state;
  final VoidCallback onChangeRegion;
  final VoidCallback onUpgrade;
  const _RegionalBlock({
    required this.state,
    required this.onChangeRegion,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🗺️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              s.subscriptionRegionalTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                s.subscriptionStatusActive,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _kv(s.subscriptionRegionLabel,
            (state.selectedRegion ?? '—').toUpperCase()),
        if (state.expiresAt != null)
          _kv(s.subscriptionExpiresOn, _fmtDate(context, state.expiresAt!)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onChangeRegion,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: Text(s.subscriptionChangeRegionButton),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onUpgrade,
          icon: const Icon(Icons.upgrade, size: 18),
          label: Text(s.subscriptionGoEvasion),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
                child: Text(k,
                    style: const TextStyle(color: AppColors.stone))),
            Text(v,
                style:
                    const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _EvasionBlock extends StatelessWidget {
  final SubscriptionState state;
  const _EvasionBlock({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌍', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              s.subscriptionEvasionTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8C063), Color(0xFFD4A04A)],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(s.subscriptionEvasionAllRegions),
        if (state.expiresAt != null) ...[
          const SizedBox(height: 4),
          Text(
            s.subscriptionExpiresOn
                .replaceAll('{date}', _fmtDate(context, state.expiresAt!)),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.stone),
          ),
        ],
      ],
    );
  }
}
