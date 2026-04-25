import 'package:flutter/material.dart';
import '../i18n/strings.dart';
import '../main.dart';

/// Toggle compact entre français et anglais avec drapeaux 🇫🇷 / 🇬🇧.
/// Persiste dans user_metadata.locale automatiquement.
class LanguageToggle extends StatelessWidget {
  final bool compact;
  const LanguageToggle({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final isEn = LocaleProvider.instance.isEn;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _chip(
                emoji: '🇫🇷',
                label: compact ? 'FR' : 'Français',
                active: !isEn,
                onTap: () => LocaleProvider.instance.setLocale(AppLocale.fr),
              ),
              const SizedBox(width: 4),
              _chip(
                emoji: '🇬🇧',
                label: compact ? 'EN' : 'English',
                active: isEn,
                onTap: () => LocaleProvider.instance.setLocale(AppLocale.en),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip({
    required String emoji,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: compact ? 14 : 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
