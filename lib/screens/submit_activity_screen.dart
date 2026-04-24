import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../widgets/responsive_center.dart';

/// Formulaire de soumission d'activité par un utilisateur.
/// Même modèle que le formulaire admin, mais :
/// - insere dans `activity_submissions` (status 'pending' par défaut)
/// - un admin doit ensuite la valider via l'interface admin
///
/// RLS sur `activity_submissions` : INSERT autorisé pour tout user
/// authentifié ; SELECT/UPDATE/DELETE réservé aux admins.
class SubmitActivityScreen extends StatefulWidget {
  const SubmitActivityScreen({super.key});

  @override
  State<SubmitActivityScreen> createState() => _SubmitActivityScreenState();
}

class _SubmitActivityScreenState extends State<SubmitActivityScreen> {
  static const _categories = [
    ('nature', 'Nature'),
    ('culture', 'Culture'),
    ('gastronomy', 'Gastronomie'),
    ('sport', 'Sport'),
    ('adventure', 'Aventure'),
    ('relax', 'Détente'),
    ('fun', 'Fun'),
  ];

  static const _features = [
    'Reservation necessaire',
    'Parking',
    'Horaires restreints',
    'Minimum de participants',
  ];

  static const _seasons = ['Printemps', 'Été', 'Automne', 'Hiver'];
  static const _socialTags = ['Famille', 'Couple', 'Amis', 'Solo'];

  static const _priceLevels = [
    (1, 'Gratuit'),
    (2, '1-20 CHF'),
    (3, '20-50 CHF'),
    (4, '50-100 CHF'),
    (5, '100+ CHF'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _activityUrlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _durationHoursCtrl = TextEditingController();

  final Set<String> _selectedCategories = {};
  final Set<String> _selectedFeatures = {};
  final Set<String> _selectedSeasons = {};
  final Set<String> _selectedSocialTags = {};
  int _priceLevel = 1;
  bool _isIndoor = false;
  bool _isOutdoor = true;

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _activityUrlCtrl.dispose();
    _imageUrlCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _durationHoursCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) return 'Le titre est requis.';
    if (_locationCtrl.text.trim().isEmpty) return 'Le lieu est requis.';
    if (_selectedCategories.isEmpty) {
      return 'Sélectionne au moins une catégorie.';
    }
    if (_descriptionCtrl.text.trim().isEmpty) {
      return 'La description est requise.';
    }
    final lat = double.tryParse(_latCtrl.text.trim());
    if (lat == null || lat < -90 || lat > 90) {
      return 'Latitude invalide (-90 à 90).';
    }
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lng == null || lng < -180 || lng > 180) {
      return 'Longitude invalide (-180 à 180).';
    }
    final dur = double.tryParse(_durationHoursCtrl.text.trim());
    if (dur == null || dur <= 0) return 'Durée invalide.';
    if (_selectedSeasons.isEmpty) {
      return 'Sélectionne au moins une saison.';
    }
    if (_selectedSocialTags.isEmpty) {
      return 'Sélectionne au moins un tag social.';
    }
    if (!_isIndoor && !_isOutdoor) {
      return 'Indoor ou Outdoor doit être coché.';
    }
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final payload = {
        'title': _titleCtrl.text.trim(),
        'location_name': _locationCtrl.text.trim(),
        'category': _selectedCategories.join(','),
        'description': _descriptionCtrl.text.trim(),
        'activity_url': _activityUrlCtrl.text.trim().isEmpty
            ? null
            : _activityUrlCtrl.text.trim(),
        'image_url': _imageUrlCtrl.text.trim().isEmpty
            ? null
            : _imageUrlCtrl.text.trim(),
        'latitude': double.parse(_latCtrl.text.trim()),
        'longitude': double.parse(_lngCtrl.text.trim()),
        'duration_minutes':
            (double.parse(_durationHoursCtrl.text.trim()) * 60).round(),
        'price_level': _priceLevel,
        'features': _selectedFeatures.toList(),
        'seasons': _selectedSeasons.toList(),
        'social_tags': _selectedSocialTags.toList(),
        'is_indoor': _isIndoor,
        'is_outdoor': _isOutdoor,
        'submitted_by': user?.email,
        // status defaults to 'pending' cote DB
      };

      await Supabase.instance.client
          .from('activity_submissions')
          .insert(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Activité soumise ! Un administrateur va la valider sous peu.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Erreur lors de la soumission: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposer une activité'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFE53935), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 18, color: Color(0xFFE53935)),
                        const SizedBox(width: 10),
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
                  const SizedBox(height: 16),
                ],

                _Section(
                  label: 'Titre *',
                  child: TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ex : Bains thermaux de Saillon',
                    ),
                  ),
                ),
                _Section(
                  label: 'Lieu *',
                  child: TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Ex : Saillon',
                    ),
                  ),
                ),
                _Section(
                  label: 'Catégories *',
                  child: _ChipSelector(
                    options: _categories.map((c) => c.$2).toList(),
                    values: _categories.map((c) => c.$1).toList(),
                    selected: _selectedCategories,
                    onToggle: (v) => setState(() {
                      _selectedCategories.contains(v)
                          ? _selectedCategories.remove(v)
                          : _selectedCategories.add(v);
                    }),
                  ),
                ),
                _Section(
                  label: 'Description *',
                  child: TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Décrivez l\'activité en quelques phrases...',
                    ),
                  ),
                ),
                _Section(
                  label: 'URL de l\'activité',
                  child: TextFormField(
                    controller: _activityUrlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(hintText: 'https://...'),
                  ),
                ),
                _Section(
                  label: 'URL de l\'image',
                  child: TextFormField(
                    controller: _imageUrlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(hintText: 'https://...'),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: _Section(
                        label: 'Latitude *',
                        child: TextFormField(
                          controller: _latCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                          decoration: const InputDecoration(hintText: '46.22'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Section(
                        label: 'Longitude *',
                        child: TextFormField(
                          controller: _lngCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                          decoration: const InputDecoration(hintText: '7.36'),
                        ),
                      ),
                    ),
                  ],
                ),
                _Section(
                  label: 'Durée (en heures) *',
                  child: TextFormField(
                    controller: _durationHoursCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: 'Ex : 2.5'),
                  ),
                ),
                _Section(
                  label: 'Niveau de prix *',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _priceLevels.map((p) {
                      final isSel = _priceLevel == p.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _priceLevel = p.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSel ? AppColors.orange : AppColors.surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color:
                                  isSel ? AppColors.orange : AppColors.line,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            p.$2,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color:
                                      isSel ? Colors.white : AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                _Section(
                  label: 'Informations utiles',
                  child: _ChipSelector(
                    options: _features,
                    values: _features,
                    selected: _selectedFeatures,
                    onToggle: (v) => setState(() {
                      _selectedFeatures.contains(v)
                          ? _selectedFeatures.remove(v)
                          : _selectedFeatures.add(v);
                    }),
                  ),
                ),
                _Section(
                  label: 'Saisons *',
                  child: _ChipSelector(
                    options: _seasons,
                    values: _seasons,
                    selected: _selectedSeasons,
                    onToggle: (v) => setState(() {
                      _selectedSeasons.contains(v)
                          ? _selectedSeasons.remove(v)
                          : _selectedSeasons.add(v);
                    }),
                  ),
                ),
                _Section(
                  label: 'Tags sociaux *',
                  child: _ChipSelector(
                    options: _socialTags,
                    values: _socialTags,
                    selected: _selectedSocialTags,
                    onToggle: (v) => setState(() {
                      _selectedSocialTags.contains(v)
                          ? _selectedSocialTags.remove(v)
                          : _selectedSocialTags.add(v);
                    }),
                  ),
                ),
                _Section(
                  label: 'Type (Indoor / Outdoor — au moins un) *',
                  child: Row(
                    children: [
                      Expanded(
                        child: _ToggleCard(
                          label: 'Indoor',
                          icon: Icons.home_outlined,
                          selected: _isIndoor,
                          onTap: () =>
                              setState(() => _isIndoor = !_isIndoor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ToggleCard(
                          label: 'Outdoor',
                          icon: Icons.wb_sunny_outlined,
                          selected: _isOutdoor,
                          onTap: () =>
                              setState(() => _isOutdoor = !_isOutdoor),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Soumettre'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre proposition sera vérifiée par un administrateur avant publication.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final List<String> values;
  final Set<String> selected;
  final void Function(String) onToggle;

  const _ChipSelector({
    required this.options,
    required this.values,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final isSel = selected.contains(values[i]);
        return GestureDetector(
          onTap: () => onToggle(values[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? AppColors.orange : AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSel ? AppColors.orange : AppColors.line,
                width: 0.5,
              ),
            ),
            child: Text(
              options[i],
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSel ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      }),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleCard({
    required this.label,
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.line,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected ? Colors.white : AppColors.ink, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : AppColors.ink,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
