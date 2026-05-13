import 'package:supabase_flutter/supabase_flutter.dart';

/// Gestion de l'accès à l'app durant la phase bêta.
///
/// Trois sources d'accès sont reconnues :
/// 1. Email dans la table `app_access` (allowlist gérée en DB).
/// 2. `user_metadata.has_access == true` (utilisateurs ayant validé le code).
/// 3. Rôle admin (super_admin / admin via `admin_users`).
///
/// Le code d'accès actuel est `WLMDY26`. Quand un utilisateur le saisit
/// correctement, on persiste `has_access = true` dans son user_metadata
/// pour qu'il n'ait plus jamais à le retaper.
class AccessService {
  static const String accessCode = 'WLMDY26';

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Vérifie si l'utilisateur courant a accès à l'app complète.
  /// Retourne `false` si non connecté.
  Future<bool> hasAccess() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    // Accès ouvert à tous les utilisateurs connectés.
    return true;
  }

  /// Tente de valider un code d'accès. Si correct, persiste
  /// `user_metadata.has_access = true` et retourne true.
  Future<bool> tryUnlockWithCode(String code) async {
    final cleaned = code.trim().toUpperCase();
    if (cleaned != accessCode) return false;

    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'has_access': true, 'access_via_code': true}),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
