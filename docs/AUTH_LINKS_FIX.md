# Fix liens e-mail — Reset mot de passe (#1) & Confirmation e-mail (#2)

> Établi le 5 juillet 2026. Statut : **code corrigé & testé** ✅ · **config dashboard + test device à faire** ⏳

## Cause racine

- **Web** : `resetPasswordForEmail` / `signUp` étaient appelés avec `redirectTo: null`.
  Supabase retombait alors sur le *Site URL* du projet — si celui-ci n'est pas
  aligné avec le domaine servant l'app, le lien « ne fait rien ».
- **Mobile** : le deep link `io.supabase.whateka://login-callback` est bien
  déclaré côté natif (Android + iOS) et `supabase_flutter` le capte
  automatiquement (package `app_links`, embarqué). Le maillon faible est
  l'**allow-list Supabase** : si l'URL de callback n'y figure pas, Supabase
  refuse de rediriger vers l'app.

> À noter : contrairement à l'hypothèse initiale, il ne manquait **pas** de
> handler de deep link à écrire — `supabase_flutter` s'en charge. Le correctif
> porte sur la **valeur de `redirectTo`** et sur la **config du dashboard**.

## Ce qui a été corrigé dans le code ✅

| Fichier | Changement |
|---|---|
| [lib/config/auth_redirects.dart](../lib/config/auth_redirects.dart) | **Nouveau.** Source de vérité unique : `authRedirectUrl()` (mobile → deep link, web → origine courante, **jamais null**). Logique pure testable. |
| [lib/screens/forgot_password_screen.dart](../lib/screens/forgot_password_screen.dart) | Utilise `authRedirectUrl()` au lieu de `kIsWeb ? null : …` |
| [lib/screens/signup_screen.dart](../lib/screens/signup_screen.dart) | Idem pour `emailRedirectTo` |
| [lib/screens/verification_screen.dart](../lib/screens/verification_screen.dart) | Écoute `onAuthStateChange` : dès que l'e-mail est confirmé (session établie), enchaîne vers l'app au lieu de rester bloqué |
| [test/config/auth_redirects_test.dart](../test/config/auth_redirects_test.dart) | Tests unitaires (web ≠ null, mobile = scheme, garde-fou de synchro) |

`flutter analyze` propre · `flutter test` 14/14 au vert.

## Étapes manuelles restantes ⏳ (non faisables depuis le code)

### 1. Allow-list Supabase — **indispensable**
Dashboard → **Authentication → URL Configuration** :

- **Site URL** : `https://whateka.ch`
- **Redirect URLs** (ajouter) :
  - `https://whateka.ch`
  - `https://whateka.ch/**`
  - `io.supabase.whateka://login-callback`
  - (dev) `http://localhost:*/**`  ← si tu testes le web en local

### 2. Protection mot de passe compromis (advisor sécurité) — ⚠️ Pro uniquement
**Leaked password protection** (HaveIBeenPwned) n'est disponible que sur le
plan **Supabase Pro**. Le projet étant sur le plan gratuit, on **diffère** ce
point → à réactiver le jour d'un passage en Pro. L'advisor
`auth_leaked_password_protection` restera donc affiché (limitation acceptée,
non bloquant pour #1/#2).

### 3. Vérifier les templates d'e-mail
Authentication → **Email Templates** : les liens « Confirm signup » / « Reset
password » doivent utiliser `{{ .ConfirmationURL }}` (respecte le `redirectTo`).

## Comment tester (test de contrôle)

**Automatisé (déjà en place)** : `flutter test test/config/auth_redirects_test.dart`.

**Manuel de non-régression** (après config dashboard) :
1. **Web (whateka.ch)** : « mot de passe oublié » → e-mail → clic → l'app ouvre
   l'écran de nouveau mot de passe → changement OK → login.
2. **Android** (build release) : idem, le lien ouvre l'app (deep link).
3. **iOS** : idem.
4. **Confirmation e-mail** : inscription → e-mail de confirmation → clic → sur le
   même appareil, l'app quitte l'écran « vérification » et entre dans l'app.

## Piste d'automatisation future
Un `integration_test` simulant la réception de l'URI
`io.supabase.whateka://login-callback?code=…` pour vérifier la navigation vers
`/update_password` (voir Phase 0 du plan, niveau « Integration »).
