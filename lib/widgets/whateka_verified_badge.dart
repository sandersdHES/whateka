import 'package:flutter/material.dart';
import '../i18n/strings.dart';

/// Badge "Whateka Verified" : starburst cyan + W blanc (police Concert One).
///
/// Affiche le PNG `assets/images/whateka_verified.png`. Tap -> dialog
/// expliquant que l'activite a ete testee et approuvee par l'equipe Whateka.
///
/// Utilise sur la card activite et sur la fiche detail, a cote des chips
/// categories quand `activity.isWhatekaCertified == true`.
class WhatekaVerifiedBadge extends StatelessWidget {
  /// Taille (cote du carre). Par defaut 28px pour rester proche des chips.
  final double size;

  const WhatekaVerifiedBadge({super.key, this.size = 28});

  void _showInfoDialog(BuildContext context) {
    final s = S.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/images/whateka_verified.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.whatekaVerifiedTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        content: Text(s.whatekaVerifiedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.whatekaVerifiedOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Semantics(
      label: s.whatekaVerifiedTitle,
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _showInfoDialog(context),
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: s.whatekaVerifiedMessage,
            child: Image.asset(
              'assets/images/whateka_verified.png',
              width: size,
              height: size,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
