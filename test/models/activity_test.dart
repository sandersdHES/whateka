// Tests unitaires du modele Activity.
//
// Logique pure (parsing JSON + regles temporelles v26-v29). Aucune dependance
// Supabase / reseau, donc rapide et deterministe. Protege notamment
// `isProposableAt` / `isExpiredAt` qui pilotent le filtre Live/Tout et l'algo
// de recommandation.

import 'package:flutter_test/flutter_test.dart';
import 'package:whateka/models/activity.dart';

void main() {
  group('Activity.fromJson', () {
    test('mappe les champs snake_case et applique les valeurs par defaut', () {
      final a = Activity.fromJson({
        'id': 42,
        'title': 'Tour de Sauvabelin',
        'location_name': 'Lausanne',
        'duration_minutes': 90,
        'latitude': 46.52,
        'longitude': 6.63,
      });

      expect(a.id, 42);
      expect(a.title, 'Tour de Sauvabelin');
      expect(a.location, 'Lausanne');
      expect(a.duration, '1.5 h'); // 90 min -> 1.5 h
      expect(a.priceLevel, 1); // defaut
      expect(a.features, isEmpty); // defaut []
      expect(a.isOutdoor, isTrue); // defaut
      expect(a.isIndoor, isFalse); // defaut
    });

    test('imageUrl est null quand image_url est absent (bug #3)', () {
      final a = Activity.fromJson({
        'id': 1,
        'title': 'Sans image',
        'location_name': 'Sion',
        'duration_minutes': 0,
        'latitude': 46.2,
        'longitude': 7.35,
        'image_url': null,
      });
      expect(a.imageUrl, isNull);
    });

    test('formate la duree : min, heures entieres et demi-heures', () {
      String durFor(int minutes) => Activity.fromJson({
            'id': 1,
            'title': 't',
            'location_name': 'l',
            'duration_minutes': minutes,
            'latitude': 0,
            'longitude': 0,
          }).duration;

      expect(durFor(0), '');
      expect(durFor(30), '30 min');
      expect(durFor(60), '1 h');
      expect(durFor(150), '2.5 h');
    });
  });

  group('Activity.isProposableAt / isExpiredAt', () {
    Activity build({
      String? recurrenceType,
      DateTime? dateStart,
      DateTime? dateEnd,
      List<int>? weeklyDays,
      List<int>? seasonalMonths,
      String category = 'nature',
    }) {
      return Activity(
        id: 1,
        title: 't',
        location: 'l',
        duration: '1 h',
        category: category,
        features: const [],
        latitude: 0,
        longitude: 0,
        recurrenceType: recurrenceType,
        dateStart: dateStart,
        dateEnd: dateEnd,
        weeklyDays: weeklyDays,
        seasonalMonths: seasonalMonths,
      );
    }

    final now = DateTime(2026, 7, 8, 12); // date fixe -> deterministe

    test('activite permanente (recurrence null) est toujours proposable', () {
      expect(build(recurrenceType: null).isProposableAt(now), isTrue);
    });

    test('un event sans dates n\'est jamais proposable (v29)', () {
      expect(build(category: 'event').isProposableAt(now), isFalse);
    });

    test('weekly : proposable seulement le bon jour', () {
      final today = now.weekday % 7; // convention DB (dimanche = 0)
      final otherDay = (today + 1) % 7;
      expect(
        build(recurrenceType: 'weekly', weeklyDays: [today]).isProposableAt(now),
        isTrue,
      );
      expect(
        build(recurrenceType: 'weekly', weeklyDays: [otherDay])
            .isProposableAt(now),
        isFalse,
      );
    });

    test('one_off passe : expire et non proposable', () {
      final past = build(
        recurrenceType: 'one_off',
        dateStart: DateTime(2026, 1, 1),
        dateEnd: DateTime(2026, 1, 2),
      );
      expect(past.isExpiredAt(now), isTrue);
      expect(past.isProposableAt(now), isFalse);
    });

    test('seasonal sans aucune contrainte concrete est exclu (v28)', () {
      expect(build(recurrenceType: 'seasonal').isProposableAt(now), isFalse);
    });
  });

  group('Activity.priceLevelLabel', () {
    test('retourne un libelle non vide pour chaque palier 1..5', () {
      for (var level = 1; level <= 5; level++) {
        expect(Activity.priceLevelLabel(level), isNotEmpty);
      }
    });
  });
}
