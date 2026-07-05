// Test de robustesse d'affichage image (#3).
//
// Garantit qu'une URL d'image cassée (ou nulle) n'empêche PAS l'affichage de la
// carte : l'`errorBuilder` doit retomber sur le fallback catégoriel sans lever
// d'exception. En test, `Image.network` échoue toujours (pas de réseau) — c'est
// donc exactement le scénario "image qui ne s'affiche pas".

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whateka/models/activity.dart';
import 'package:whateka/widgets/activity_card.dart';

Activity _activity({String? imageUrl}) => Activity(
      id: 1,
      title: 'Test Activity',
      location: 'Lausanne',
      duration: '1 h',
      category: 'nature',
      features: const [],
      latitude: 0,
      longitude: 0,
      imageUrl: imageUrl,
    );

Future<void> _pump(WidgetTester tester, Activity a) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 320, child: ActivityCard(activity: a)),
        ),
      ),
    ),
  );
  await tester.pump(); // laisse l'errorBuilder de Image.network se declencher
}

void main() {
  testWidgets('URL image cassée -> carte affichée, pas de crash (#3)',
      (tester) async {
    await _pump(tester, _activity(imageUrl: 'https://invalid.example/x.jpg'));
    expect(find.text('Test Activity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('imageUrl null -> fallback catégoriel, pas de crash (#3)',
      (tester) async {
    await _pump(tester, _activity(imageUrl: null));
    expect(find.text('Test Activity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
