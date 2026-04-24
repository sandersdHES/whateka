import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../widgets/avatar_promenade.dart';
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
    _RadiusOption('Vaud complet', 999, region: 'vaud'),
    _RadiusOption('Valais complet', 999, region: 'valais'),
  ];

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
  double _metersWalked = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata ?? {};
      setState(() {
        _emailController.text = user.email ?? '';
        _nameController.text = meta['first_name'] ?? '';
        _selectedRadiusKm = (meta['search_radius_km'] as int?) ?? 50;
        _selectedRegion = (meta['search_region'] as String?) ?? '';
        _locationMode = (meta['location_mode'] as String?) ?? 'auto';
        _manualCity = (meta['manual_city'] as String?) ?? 'Lausanne';
        _avatarId = (meta['avatar_id'] as int?) ?? 1;
        _totalSearches = (meta['total_searches'] as int?) ?? 0;
      });
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
            const SnackBar(
              content: Text(
                  'Un email de vérification a été envoyé pour le changement d\'adresse.'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
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

  bool _isRadiusSelected(_RadiusOption o) {
    return _selectedRadiusKm == o.radiusKm && _selectedRegion == o.region;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
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
              // Avatar anime qui se promene dans une bande horizontale
              AvatarPromenade(
                avatarId: _avatarId,
                onMetersWalked: (m) => setState(() => _metersWalked = m),
              ),
              const SizedBox(height: 16),

              // Dashboard : recherches cumulees + metres marches cette session
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.search,
                      value: '$_totalSearches',
                      label: _totalSearches > 1 ? 'recherches' : 'recherche',
                      accent: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.directions_walk,
                      value: _metersWalked.floor().toString(),
                      label: _metersWalked >= 2 ? 'mètres' : 'mètre',
                      accent: AppColors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Préférences
              Text(
                'Préférences',
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
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
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
                      decoration: const InputDecoration(
                        labelText: 'Personnage',
                        prefixIcon: Icon(Icons.face_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Position
              Text(
                'Ma position',
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
                        'Choisissez votre ville',
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
                        'L\'app utilise votre position GPS automatiquement.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Rayon
              Text(
                'Rayon de recherche',
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
                      'Le questionnaire limitera les activités à cette zone.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _radiusOptions.map((option) {
                        final isSelected = _isRadiusSelected(option);
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedRadiusKm = option.radiusKm;
                            _selectedRegion = option.region;
                          }),
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
                              option.label,
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
                    : const Text('Sauvegarder'),
              ),
              const SizedBox(height: 12),

              // Déconnexion en orange
              TextButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Se déconnecter'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.orange,
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
  }
}

class _LocationModeToggle extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChanged;
  const _LocationModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeChoice(
            label: 'Automatique',
            subtitle: 'GPS',
            icon: Icons.gps_fixed,
            selected: mode == 'auto',
            onTap: () => onChanged('auto'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ModeChoice(
            label: 'Manuelle',
            subtitle: 'Choisir une ville',
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
    return GestureDetector(
      onTap: onTap,
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
