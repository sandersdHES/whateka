import 'package:supabase_flutter/supabase_flutter.dart';

/// Tier d'abonnement (synchronise avec la DB).
enum SubscriptionTier {
  free,
  regional,
  evasion;

  String get key => switch (this) {
        SubscriptionTier.free => 'free',
        SubscriptionTier.regional => 'regional',
        SubscriptionTier.evasion => 'evasion',
      };

  static SubscriptionTier fromString(String? s) => switch (s) {
        'regional' => SubscriptionTier.regional,
        'evasion' => SubscriptionTier.evasion,
        _ => SubscriptionTier.free,
      };

  /// Prix mensuel en CHF (pour affichage UI).
  double get priceChf => switch (this) {
        SubscriptionTier.free => 0,
        SubscriptionTier.regional => 3.0,
        SubscriptionTier.evasion => 5.0,
      };
}

/// Etat complet de l'abonnement utilisateur.
class SubscriptionState {
  final SubscriptionTier tier;
  final String? selectedRegion; // 'vaud' | 'valais' | null
  final DateTime freePeriodStartedAt;
  final int freeQuizzesUsed;
  static const int freeQuotaLimit = 5;
  final DateTime? lastRegionChange;
  final DateTime? trialEndsAt;
  final DateTime? expiresAt;
  final String? source; // 'apple' | 'stripe' | 'promo' | null
  final String status;

  const SubscriptionState({
    required this.tier,
    this.selectedRegion,
    required this.freePeriodStartedAt,
    required this.freeQuizzesUsed,
    this.lastRegionChange,
    this.trialEndsAt,
    this.expiresAt,
    this.source,
    required this.status,
  });

  /// Default state pour un user sans ligne en DB (pas encore initialise).
  factory SubscriptionState.defaultFree() => SubscriptionState(
        tier: SubscriptionTier.free,
        freePeriodStartedAt: DateTime.now(),
        freeQuizzesUsed: 0,
        status: 'active',
      );

  factory SubscriptionState.fromJson(Map<String, dynamic> json) {
    return SubscriptionState(
      tier: SubscriptionTier.fromString(json['tier'] as String?),
      selectedRegion: json['selected_region'] as String?,
      freePeriodStartedAt: DateTime.parse(
          json['free_period_started_at'] as String),
      freeQuizzesUsed: (json['free_quizzes_used'] as num?)?.toInt() ?? 0,
      lastRegionChange: json['last_region_change'] != null
          ? DateTime.parse(json['last_region_change'] as String)
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      source: json['source'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  // ────────────────────────────────────────────────────────────
  // Computed properties
  // ────────────────────────────────────────────────────────────

  bool get isPaid =>
      tier != SubscriptionTier.free && isActive && !isExpired;

  bool get isActive => status == 'active';

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get isInTrial =>
      trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now());

  /// Date de reset de la fenetre 30j pour le quota free.
  DateTime get freePeriodEndsAt =>
      freePeriodStartedAt.add(const Duration(days: 30));

  /// Quizzes restants dans la fenetre 30j courante.
  int get freeQuizzesRemaining {
    if (DateTime.now().isAfter(freePeriodEndsAt)) {
      // Fenetre echue → 5 disponibles (le serveur fera le reset au prochain quiz).
      return freeQuotaLimit;
    }
    return (freeQuotaLimit - freeQuizzesUsed).clamp(0, freeQuotaLimit);
  }

  /// Date du prochain changement de canton possible (Regional).
  DateTime? get nextRegionChangeAt {
    if (lastRegionChange == null) return null;
    return lastRegionChange!.add(const Duration(days: 30));
  }

  bool get canChangeRegion {
    if (lastRegionChange == null) return true;
    return DateTime.now().isAfter(nextRegionChangeAt!);
  }
}

/// Resultat d'un appel a `consume_free_quiz()`.
class QuotaCheckResult {
  final bool allowed;
  final SubscriptionTier tier;
  final int? used;
  final int? limit;
  final DateTime? resetAt;
  final String? error;

  const QuotaCheckResult({
    required this.allowed,
    required this.tier,
    this.used,
    this.limit,
    this.resetAt,
    this.error,
  });

  factory QuotaCheckResult.fromJson(Map<String, dynamic> json) {
    return QuotaCheckResult(
      allowed: json['allowed'] as bool? ?? false,
      tier: SubscriptionTier.fromString(json['tier'] as String?),
      used: (json['used'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      resetAt: json['reset_at'] != null
          ? DateTime.parse(json['reset_at'] as String)
          : null,
      error: json['error'] as String?,
    );
  }
}

/// Resultat d'une tentative de redemption d'un code promo.
class PromoRedemptionResult {
  final bool success;
  final String? error;
  final SubscriptionTier? tier;
  final DateTime? expiresAt;
  final int? durationMonths;

  const PromoRedemptionResult({
    required this.success,
    this.error,
    this.tier,
    this.expiresAt,
    this.durationMonths,
  });

  factory PromoRedemptionResult.fromJson(Map<String, dynamic> json) {
    return PromoRedemptionResult(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      tier: json['tier'] != null
          ? SubscriptionTier.fromString(json['tier'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      durationMonths: (json['duration_months'] as num?)?.toInt(),
    );
  }
}

/// Resultat d'un changement de canton.
class RegionChangeResult {
  final bool success;
  final String? error;
  final String? region;
  final DateTime? nextChangeAt;

  const RegionChangeResult({
    required this.success,
    this.error,
    this.region,
    this.nextChangeAt,
  });

  factory RegionChangeResult.fromJson(Map<String, dynamic> json) {
    return RegionChangeResult(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      region: json['region'] as String?,
      nextChangeAt: json['next_change_at'] != null
          ? DateTime.parse(json['next_change_at'] as String)
          : null,
    );
  }
}

/// Service centralisant les appels d'abonnement (Supabase).
///
/// Usage :
///   final state = await SubscriptionService.instance.fetchCurrentState();
///   if (state.tier == SubscriptionTier.free && state.freeQuizzesRemaining == 0) {
///     showPaywall();
///   }
class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Etat courant en cache (evite les requetes repetees, refresh manuel possible).
  SubscriptionState? _cached;
  DateTime? _cachedAt;
  static const Duration _cacheTTL = Duration(seconds: 30);

  SubscriptionState? get cachedState => _cached;

  /// Charge l'etat depuis la DB. Cree la ligne 'free' si absente.
  /// Si pas de user authentifie : retourne defaultFree.
  Future<SubscriptionState> fetchCurrentState({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTTL) {
      return _cached!;
    }

    final user = _client.auth.currentUser;
    if (user == null) return SubscriptionState.defaultFree();

    try {
      final row = await _client.rpc('ensure_subscription_row');
      if (row is Map<String, dynamic>) {
        _cached = SubscriptionState.fromJson(row);
        _cachedAt = DateTime.now();
        return _cached!;
      }
      // Le RPC retourne parfois un List<dynamic> selon la config.
      if (row is List && row.isNotEmpty && row.first is Map) {
        _cached = SubscriptionState.fromJson(
          Map<String, dynamic>.from(row.first as Map),
        );
        _cachedAt = DateTime.now();
        return _cached!;
      }
    } catch (_) {
      // Fallback : SELECT direct.
      try {
        final res = await _client
            .from('subscriptions')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();
        if (res != null) {
          _cached = SubscriptionState.fromJson(res);
          _cachedAt = DateTime.now();
          return _cached!;
        }
      } catch (_) {/* ignore */}
    }

    // Si rien ne marche, on retourne un free par defaut.
    return SubscriptionState.defaultFree();
  }

  /// Tente de consommer 1 quiz du quota free. Retourne allowed=false si quota
  /// epuise. A appeler AVANT de naviguer vers le quiz.
  /// Pour les tiers payants, le serveur renvoie allowed=true sans consommer.
  Future<QuotaCheckResult> consumeFreeQuiz() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const QuotaCheckResult(
        allowed: false,
        tier: SubscriptionTier.free,
        error: 'not_authenticated',
      );
    }
    try {
      final res = await _client.rpc('consume_free_quiz');
      if (res is Map<String, dynamic>) {
        // Invalider le cache pour qu'on relise apres consommation.
        _cached = null;
        return QuotaCheckResult.fromJson(res);
      }
    } catch (e) {
      return QuotaCheckResult(
        allowed: false,
        tier: SubscriptionTier.free,
        error: 'rpc_error: $e',
      );
    }
    return const QuotaCheckResult(
      allowed: false,
      tier: SubscriptionTier.free,
      error: 'unexpected_response',
    );
  }

  /// Active un code promo (verifications cote serveur).
  Future<PromoRedemptionResult> redeemPromoCode(String code) async {
    try {
      final res = await _client.rpc(
        'redeem_promo_code',
        params: {'p_code': code.trim().toUpperCase()},
      );
      if (res is Map<String, dynamic>) {
        _cached = null; // forcer le refresh apres redemption
        return PromoRedemptionResult.fromJson(res);
      }
    } catch (e) {
      return PromoRedemptionResult(success: false, error: 'rpc_error: $e');
    }
    return const PromoRedemptionResult(
        success: false, error: 'unexpected_response');
  }

  /// Change le canton (pour tier 'regional').
  Future<RegionChangeResult> changeRegion(String newRegion) async {
    try {
      final res = await _client.rpc(
        'change_region',
        params: {'p_new_region': newRegion},
      );
      if (res is Map<String, dynamic>) {
        _cached = null;
        return RegionChangeResult.fromJson(res);
      }
    } catch (e) {
      return RegionChangeResult(success: false, error: 'rpc_error: $e');
    }
    return const RegionChangeResult(
        success: false, error: 'unexpected_response');
  }

  /// Force-refresh du cache (apres un paiement reussi par exemple).
  void invalidate() {
    _cached = null;
    _cachedAt = null;
  }
}
