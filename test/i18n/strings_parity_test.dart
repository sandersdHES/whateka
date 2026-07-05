// Test de parite i18n (support de l'item #11 : ajout de l'allemand).
//
// Le systeme i18n (lib/i18n/strings.dart) est une classe `_Strings` dont TOUS
// les champs sont `required`. Le compilateur garantit donc deja qu'une locale
// (_fr, _en, et demain _de) fournit toutes les cles. Ce test ajoute un garde-fou
// lisible qui :
//   - verifie que chaque bloc de locale (_fr, _en, ...) declare exactement le
//     meme jeu de cles que le constructeur ;
//   - se declenche automatiquement pour toute nouvelle locale ajoutee au fichier.
//
// Il analyse le SOURCE (pas de reflection en Dart/Flutter). Volontairement
// tolerant : chaque entree est de la forme `cle: 'valeur',` sur sa propre ligne.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Extrait les cles (identifiants suivis de `:` en debut de ligne) entre la
/// ligne d'ouverture [startLine] (exclue) et la premiere ligne dont le contenu
/// trimme egale [terminator].
Set<String> _keysInBlock(
  List<String> lines,
  int startLine,
  String terminator,
) {
  final keyRe = RegExp(r'^\s*([a-zA-Z_]\w*)\s*:');
  final keys = <String>{};
  for (var i = startLine + 1; i < lines.length; i++) {
    if (lines[i].trim() == terminator) break;
    final m = keyRe.firstMatch(lines[i]);
    if (m != null) keys.add(m.group(1)!);
  }
  return keys;
}

void main() {
  test('chaque locale declare le meme jeu de cles que le constructeur', () {
    final file = File('lib/i18n/strings.dart');
    expect(file.existsSync(), isTrue,
        reason: 'strings.dart introuvable depuis ${Directory.current.path}');
    final lines = file.readAsLinesSync();

    // 1) Champs du constructeur : `required this.<champ>`
    final fieldRe = RegExp(r'required this\.([a-zA-Z_]\w*)');
    final fields = <String>{};
    for (final l in lines) {
      final m = fieldRe.firstMatch(l);
      if (m != null) fields.add(m.group(1)!);
    }
    expect(fields, isNotEmpty, reason: 'aucun champ `required this.` trouve');

    // 2) Blocs de locale : `const _Strings _xx = _Strings(`
    final localeRe = RegExp(r'const\s+_Strings\s+(_\w+)\s*=\s*_Strings\(');
    final localeStarts = <String, int>{};
    for (var i = 0; i < lines.length; i++) {
      final m = localeRe.firstMatch(lines[i]);
      if (m != null) localeStarts[m.group(1)!] = i;
    }
    // On s'attend a au moins _fr et _en aujourd'hui.
    expect(localeStarts.keys, containsAll(<String>['_fr', '_en']),
        reason: 'blocs de locale trouves: ${localeStarts.keys}');

    // 3) Chaque locale doit exposer exactement les champs du constructeur.
    localeStarts.forEach((name, start) {
      final keys = _keysInBlock(lines, start, ');');
      final missing = fields.difference(keys);
      final extra = keys.difference(fields);
      expect(missing, isEmpty,
          reason: 'Locale $name : cles manquantes -> $missing');
      expect(extra, isEmpty,
          reason: 'Locale $name : cles inconnues -> $extra');
    });
  });
}
