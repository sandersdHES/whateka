// Tests de la logique de redirection d'auth (bugs #1/#2).
//
// On teste la fonction pure `computeAuthRedirect` : sur mobile elle renvoie le
// deep link (scheme enregistré côté natif) ; sur web elle renvoie l'origine qui
// sert l'app (et ne doit JAMAIS être null, ce qui était la cause du bug web).

import 'package:flutter_test/flutter_test.dart';
import 'package:whateka/config/auth_redirects.dart';

void main() {
  group('computeAuthRedirect', () {
    test('mobile -> deep link scheme enregistré côté natif', () {
      final url = computeAuthRedirect(
        isWeb: false,
        webOrigin: 'https://whateka.ch',
      );
      expect(url, kMobileAuthRedirect);
      expect(url, 'io.supabase.whateka://login-callback');
    });

    test('web -> origine courante (jamais null)', () {
      expect(
        computeAuthRedirect(isWeb: true, webOrigin: 'https://whateka.ch'),
        'https://whateka.ch',
      );
      // En dev, l'app est servie depuis localhost.
      expect(
        computeAuthRedirect(isWeb: true, webOrigin: 'http://localhost:8080'),
        'http://localhost:8080',
      );
    });

    test('le scheme mobile reste synchronisé avec la config native', () {
      // Garde-fou : si on change le scheme, il faut aussi mettre à jour
      // AndroidManifest.xml et Info.plist (et l'allow-list Supabase).
      expect(kMobileAuthRedirect, startsWith('io.supabase.whateka://'));
    });
  });
}
