import 'package:flutter/foundation.dart';

/// Source de vérité unique pour l'URL de redirection des e-mails d'auth
/// (réinitialisation de mot de passe #1, confirmation d'e-mail #2).
///
/// Cette URL DOIT figurer dans l'allow-list Supabase :
///   Dashboard → Authentication → URL Configuration → Redirect URLs.
///
/// Fonctionnement :
///  - **Mobile** : deep link vers l'app. Le scheme est enregistré côté natif
///    (AndroidManifest.xml + Info.plist) et `supabase_flutter` capte l'URI
///    entrante automatiquement (package `app_links`, embarqué), établit la
///    session, puis émet `onAuthStateChange` (→ `passwordRecovery` route vers
///    `/update_password` dans main.dart).
///  - **Web** : on renvoie vers l'origine qui sert l'app (whateka.ch en prod,
///    localhost en dev). `supabase_flutter` détecte le token présent dans l'URL
///    au chargement (`detectSessionInUri`, activé par défaut).
///
/// Auparavant, `redirectTo` valait `null` sur web : Supabase retombait alors
/// sur le Site URL du projet, d'où des liens qui « ne fonctionnaient pas »
/// quand cette config n'était pas alignée. On rend désormais la valeur explicite.

/// Scheme de deep link mobile. À garder synchronisé avec :
///  - android/app/src/main/AndroidManifest.xml (`<data android:scheme=...>`)
///  - ios/Runner/Info.plist (`CFBundleURLSchemes`)
const String kMobileAuthRedirect = 'io.supabase.whateka://login-callback';

/// Logique pure (testable) : calcule l'URL de redirection.
String computeAuthRedirect({required bool isWeb, required String webOrigin}) {
  if (!isWeb) return kMobileAuthRedirect;
  return webOrigin;
}

/// URL de redirection effective pour la plateforme courante.
String authRedirectUrl() =>
    computeAuthRedirect(isWeb: kIsWeb, webOrigin: Uri.base.origin);
