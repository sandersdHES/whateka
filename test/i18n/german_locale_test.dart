// Vérifie le câblage de la locale allemande (#11) : sélection -> S.current,
// et la stratégie de fallback de pickLocalized.
//
// setLocale() tente une écriture Supabase mais l'exception (client non
// initialisé en test) est capturée : la locale reste en mémoire. Chaque fichier
// de test tourne dans son propre isolate, donc le singleton n'affecte pas les
// autres tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:whateka/i18n/strings.dart';

void main() {
  test('setLocale(de) -> S.current pointe sur l\'allemand', () async {
    await LocaleProvider.instance.setLocale(AppLocale.de);
    expect(LocaleProvider.instance.current, AppLocale.de);
    expect(S.current.btnLogin, 'Anmelden');
    expect(S.current.quizCatNature, 'Natur');
    expect(S.current.navFavorites, 'Favoriten');
  });

  test('pickLocalized: en allemand, EN prioritaire puis fallback FR', () async {
    await LocaleProvider.instance.setLocale(AppLocale.de);
    // Contenu activité : pas de colonne allemande -> on prend l'anglais si dispo.
    expect(pickLocalized('Randonnée', 'Hike'), 'Hike');
    // Pas d'anglais -> fallback français.
    expect(pickLocalized('Randonnée', null), 'Randonnée');
    expect(pickLocalized('Randonnée', '  '), 'Randonnée');
  });

  test('retour au français fonctionne (hygiène)', () async {
    await LocaleProvider.instance.setLocale(AppLocale.fr);
    expect(S.current.btnLogin, 'Se connecter');
  });
}
