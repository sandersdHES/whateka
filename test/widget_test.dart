// Smoke test du harnais de widgets.
//
// Remplace l'ancien template "Counter" (qui instanciait MyApp et exigeait
// Supabase.initialize, donc echouait toujours). On rend ici un vrai widget
// de l'app qui ne depend PAS de Supabase : le LanguageToggle.
//
// Objectif : garantir que `flutter test` compile et rend l'UI de base au vert.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:whateka/widgets/language_toggle.dart';

void main() {
  testWidgets('LanguageToggle affiche les deux langues (FR/EN)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: LanguageToggle(compact: true)),
        ),
      ),
    );

    // Le toggle doit exposer les deux libelles de langue.
    expect(find.text('FR'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
  });
}
