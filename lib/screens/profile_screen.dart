import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../widgets/avatar_promenade.dart';
import '../widgets/language_toggle.dart';
import '../widgets/responsive_center.dart';
import '../widgets/whateka_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// Option de ville pre-definie (mode position manuelle).
class _City {
  final String label;
  final double lat;
  final double lng;
  const _City(this.label, this.lat, this.lng);
}

/// Option de rayon ou filtre canton-wide.
/// Si [region] est non vide, le rayon est ignore (recherche canton-wide).
class _RadiusOption {
  final String label;
  final int radiusKm;
  final String region; // '' | 'vaud' | 'valais'
  const _RadiusOption(this.label, this.radiusKm, {this.region = ''});
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  static const List<_RadiusOption> _radiusOptions = [
    _RadiusOption('10 km', 10),
    _RadiusOption('25 km', 25),
    _RadiusOption('50 km', 50),
    _RadiusOption('100 km', 100),
    // Les labels des regions sont remplaces dynamiquement via S.current
    // dans le rendu (cf. _radiusLabel ci-dessous).
    _RadiusOption('vaud_full', 999, region: 'vaud'),
    _RadiusOption('valais_full', 999, region: 'valais'),
  ];

  /// Retourne le label affiche pour une option de rayon (traduit si region).
  String _radiusLabel(_RadiusOption opt) {
    if (opt.region == 'vaud') return S.current.profileRadiusVaud;
    if (opt.region == 'valais') return S.current.profileRadiusValais;
    return opt.label;
  }

  // Villes pre-definies pour le mode manuel (coordonnees centre-ville).
  static const List<_City> _manualCities = [
    _City('Lausanne', 46.5197, 6.6323),
    _City('Montreux', 46.4312, 6.9106),
    _City('Vevey', 46.4619, 6.8428),
    _City('Morges', 46.5098, 6.4993),
    _City('Nyon', 46.3833, 6.2389),
    _City('Yverdon-les-Bains', 46.7785, 6.6413),
    _City('Aigle', 46.3178, 6.9699),
    _City('Sion', 46.2311, 7.3589),
    _City('Martigny', 46.1014, 7.0728),
    _City('Sierre', 46.2925, 7.5356),
    _City('Crans-Montana', 46.3117, 7.4853),
    _City('Verbier', 46.0961, 7.2286),
    _City('Zermatt', 46.0207, 7.7491),
  ];

  int _selectedRadiusKm = 50;
  String _selectedRegion = ''; // '' | 'vaud' | 'valais'
  String _locationMode = 'auto'; // 'auto' | 'manual'
  String _manualCity = 'Lausanne';
  int _avatarId = 1;
  int _totalSearches = 0;
  /// Total cumule de metres (charge de user_metadata au mount, mis a jour
  /// a chaque tick par AvatarPromenade, sauvegarde toutes les 60s et au dispose).
  double _metersWalked = 0;
  double _lastSavedMeters = 0;
  Timer? _metersSaveTimer;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Sauvegarde periodique des metres marches (toutes les 60s) pour ne pas
    // perdre les donnees en cas de crash. Sauve seulement si la valeur a
    // change d'au moins 1 metre depuis la derniere sauvegarde.
    _metersSaveTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _persistMetersIfChanged();
    });
  }

  @override
  void dispose() {
    _metersSaveTimer?.cancel();
    // Sauvegarde finale quand on quitte l'ecran (navigation ou close).
    _persistMetersIfChanged();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _persistMetersIfChanged() async {
    if ((_metersWalked - _lastSavedMeters).abs() < 1) return;
    final savedValue = _metersWalked;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final meta = user?.userMetadata ?? {};
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          ...meta,
          'total_meters': savedValue,
        }),
      );
      _lastSavedMeters = savedValue;
    } catch (_) {
      // Echec silencieux : on retentera au prochain tick.
    }
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata ?? {};
      setState(() {
        _emailController.text = user.email ?? '';
        _nameController.text = (meta['first_name'] is String ? meta['first_name'] : '') as String;
        _selectedRadiusKm = (meta['search_radius_km'] as int?) ?? 50;
        _selectedRegion = (meta['search_region'] as String?) ?? '';
        _locationMode = (meta['location_mode'] as String?) ?? 'auto';
        _manualCity = (meta['manual_city'] as String?) ?? 'Lausanne';
        _avatarId = (meta['avatar_id'] as int?) ?? 1;
        _totalSearches = (meta['total_searches'] as int?) ?? 0;
        _metersWalked = (meta['total_meters'] as num?)?.toDouble() ?? 0;
        _lastSavedMeters = _metersWalked;
        _profileLoaded = true;
      });
    } else {
      setState(() => _profileLoaded = true);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      // Trouver les coordonnees de la ville manuelle (si mode=manual).
      final city = _manualCities.firstWhere(
        (c) => c.label == _manualCity,
        orElse: () => _manualCities.first,
      );

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'first_name': _nameController.text.trim(),
          'search_radius_km': _selectedRadiusKm,
          'search_region': _selectedRegion,
          'location_mode': _locationMode,
          'manual_city': _manualCity,
          'manual_lat': city.lat,
          'manual_lng': city.lng,
          'avatar_id': _avatarId,
        }),
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email != _emailController.text.trim()) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(email: _emailController.text.trim()),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.current.profileEmailChangeNotice),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.current.profileUpdated)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.current.errorWithDetails}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  /// Suppression de compte definitive (App Store requirement).
  Future<void> _deleteAccount() async {
    final s = S.current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.profileDeleteAccountDialogTitle),
        content: Text(s.profileDeleteAccountDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.btnCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(s.profileDeleteAccountConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.functions.invoke('delete-account');
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.profileDeleteAccountError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Affiche une bottom-sheet pour changer le mot de passe.
  /// Verification : on retente une connexion avec l'ancien mot de passe avant
  /// d'accepter le changement (Supabase ne fournit pas d'API "verify password"
  /// dedie). Puis on appelle auth.updateUser(password: newPassword).
  Future<void> _showChangePasswordSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const _ChangePasswordSheet(),
      ),
    );
  }

  bool _isRadiusSelected(_RadiusOption o) {
    return _selectedRadiusKm == o.radiusKm && _selectedRegion == o.region;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
      appBar: AppBar(
        title: Text(s.profileTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: const WhatekBottomNav(currentRoute: '/profile'),
      body: ResponsiveCenter(
        maxWidth: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar anime qui se promene dans une bande horizontale.
              // On attend que le profil soit charge pour monter le widget
              // (sinon initialMeters serait 0 alors que la valeur reelle vient
              // de charger). Placeholder pendant le chargement.
              _profileLoaded
                  ? AvatarPromenade(
                      avatarId: _avatarId,
                      initialMeters: _metersWalked,
                      onMetersWalked: (m) =>
                          setState(() => _metersWalked = m),
                    )
                  : const SizedBox(height: 200),
              const SizedBox(height: 16),

              // Dashboard : recherches cumulees + metres marches cette session
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.search,
                      value: '$_totalSearches',
                      label: s.profileSearches,
                      accent: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.directions_walk,
                      value: _metersWalked.floor().toString(),
                      label: s.profileMeters,
                      accent: AppColors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Préférences
              Text(
                s.profileSection,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: s.profileFirstNameLabel,
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: s.profileEmailLabel,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    // Selecteur d'avatar : dropdown avec preview SVG du
                    // personnage actuellement selectionne.
                    DropdownButtonFormField<int>(
                      initialValue: _avatarId,
                      isExpanded: true,
                      items: WhatekaAvatar.all
                          .map((a) => DropdownMenuItem<int>(
                                value: a.id,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 40,
                                      child: SvgPicture.asset(
                                        'assets/avatars/${a.filename}',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(a.name),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _avatarId = v);
                      },
                      decoration: InputDecoration(
                        labelText: s.profileCharacterLabel,
                        prefixIcon: const Icon(Icons.face_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Position
              Text(
                s.profileLocation,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationModeToggle(
                      mode: _locationMode,
                      onChanged: (m) => setState(() => _locationMode = m),
                    ),
                    if (_locationMode == 'manual') ...[
                      const SizedBox(height: 14),
                      Text(
                        s.profileLocationChooseCityLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _manualCity,
                        items: _manualCities
                            .map((c) => DropdownMenuItem(
                                  value: c.label,
                                  child: Text(c.label),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _manualCity = v);
                        },
                        decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.location_city_outlined, size: 20),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 6),
                      Text(
                        s.profileLocationAutoHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Rayon
              Text(
                s.profileRadius,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.profileRadiusInfo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _radiusOptions.map((option) {
                        final isSelected = _isRadiusSelected(option);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                          onTap: () => setState(() {
                            _selectedRadiusKm = option.radiusKm;
                            _selectedRegion = option.region;
                          }),
                          borderRadius: BorderRadius.circular(999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.ink
                                  : AppColors.paper,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.ink
                                    : AppColors.line,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _radiusLabel(option),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Bouton sauvegarder (cyan pleine largeur)
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(s.profileSaveBtn),
              ),
              const SizedBox(height: 12),

              // Section Securite : changer le mot de passe.
              // Bouton outline pour ne pas concurrencer le CTA sauvegarder (cyan).
              OutlinedButton.icon(
                onPressed: _showChangePasswordSheet,
                icon: const Icon(Icons.lock_reset, size: 18),
                label: Text(s.profileChangePassword),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // Section Langue
              Text(
                s.profileLanguage,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line, width: 0.5),
                ),
                child: const Center(child: LanguageToggle()),
              ),
              const SizedBox(height: 24),

              // Déconnexion en orange
              TextButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, size: 18),
                label: Text(s.profileSignOut),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: _isLoading ? null : _deleteAccount,
                icon: const Icon(Icons.delete_forever_outlined, size: 18),
                label: Text(s.profileDeleteAccount),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }
}

class _LocationModeToggle extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChanged;
  const _LocationModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _ModeChoice(
            label: s.profileLocationModeAuto,
            subtitle: s.profileLocationGps,
            icon: Icons.gps_fixed,
            selected: mode == 'auto',
            onTap: () => onChanged('auto'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModeChoice(
            label: s.profileLocationModeManual,
            subtitle: s.profileLocationChooseCity,
            icon: Icons.edit_location_alt_outlined,
            selected: mode == 'manual',
            onTap: () => onChanged('manual'),
          ),
        ),
      ],
    );
  }
}

class _ModeChoice extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChoice({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.cyan : AppColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.cyan : AppColors.line,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? Colors.white : AppColors.ink, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : AppColors.ink,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.stone,
                  ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        height: 1.1,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom-sheet pour changer le mot de passe utilisateur.
/// - Champ "actuel" verifie via signInWithPassword avec l'email courant
/// - Champ "nouveau" + "confirmer" valides cote client (>=6 chars + match)
/// - Sur succes : updateUser(password:) puis SnackBar + close.
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final current = _currentCtrl.text.trim();
    final next = _newCtrl.text.trim();
    if (current == next) {
      setState(() => _error = S.current.profileChangePasswordSamePwd);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final supabase = Supabase.instance.client;
    final email = supabase.auth.currentUser?.email;
    if (email == null) {
      setState(() {
        _busy = false;
        _error = S.current.profileChangePasswordGenericError;
      });
      return;
    }

    try {
      // 1. Verifier l'ancien mot de passe en retentant un signin.
      //    Supabase n'expose pas d'API "verify only" — c'est la solution
      //    standard utilisee dans les SDK officiels.
      await supabase.auth.signInWithPassword(
        email: email,
        password: current,
      );

      // 2. Mettre a jour le mot de passe.
      await supabase.auth.updateUser(UserAttributes(password: next));

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.profileChangePasswordSuccess),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      // Heuristique : message "Invalid login credentials" => mot de passe
      // actuel incorrect. Sinon afficher le message brut.
      final msg = e.message.toLowerCase();
      setState(() {
        _busy = false;
        if (msg.contains('invalid') || msg.contains('credentials')) {
          _error = S.current.profileChangePasswordCurrentInvalid;
        } else {
          _error = e.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = S.current.profileChangePasswordGenericError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                s.profileChangePasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFE53935), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 18, color: Color(0xFFE53935)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: const Color(0xFFB71C1C)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _currentCtrl,
                obscureText: !_currentVisible,
                decoration: InputDecoration(
                  labelText: s.profileChangePasswordCurrent,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _currentVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.stone,
                    ),
                    tooltip:
                        _currentVisible ? s.passwordHide : s.passwordShow,
                    onPressed: () => setState(
                        () => _currentVisible = !_currentVisible),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? s.validationRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newCtrl,
                obscureText: !_newVisible,
                decoration: InputDecoration(
                  labelText: s.updatePasswordNewLabel,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _newVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.stone,
                    ),
                    tooltip: _newVisible ? s.passwordHide : s.passwordShow,
                    onPressed: () =>
                        setState(() => _newVisible = !_newVisible),
                  ),
                ),
                validator: (v) => (v != null && v.length >= 6)
                    ? null
                    : s.validationMinChars,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: !_confirmVisible,
                decoration: InputDecoration(
                  labelText: s.updatePasswordConfirmLabel,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.stone,
                    ),
                    tooltip:
                        _confirmVisible ? s.passwordHide : s.passwordShow,
                    onPressed: () => setState(
                        () => _confirmVisible = !_confirmVisible),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return s.validationRequired;
                  if (v != _newCtrl.text) {
                    return s.validationPasswordsMismatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(s.profileChangePassword),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(s.btnCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
