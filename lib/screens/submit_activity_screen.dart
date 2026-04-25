import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../widgets/responsive_center.dart';

/// Formulaire de soumission d'activité par un utilisateur.
/// - Insere dans `activity_submissions` (status 'pending' par défaut).
/// - Permet d'uploader plusieurs photos depuis l'appareil vers le bucket
///   Supabase Storage `activity-images`, ET/OU de coller des URL distantes.
/// - Un admin valide ensuite via l'interface admin.
class SubmitActivityScreen extends StatefulWidget {
  const SubmitActivityScreen({super.key});

  @override
  State<SubmitActivityScreen> createState() => _SubmitActivityScreenState();
}

/// Un item photo : soit un fichier local pas encore uploadé ([bytes] non null),
/// soit une URL distante déjà accessible ([url] non null).
class _PhotoItem {
  final Uint8List? bytes;
  final String? url;
  final String filename;
  final String? mimeType;
  const _PhotoItem({
    this.bytes,
    this.url,
    required this.filename,
    this.mimeType,
  });

  bool get isLocal => bytes != null;
}

class _SubmitActivityScreenState extends State<SubmitActivityScreen> {
  // Liste des catégories (clés FR fixes pour la DB, labels traduits via getter).
  static const _categoryKeys = [
    'nature', 'culture', 'gastronomy', 'sport',
    'adventure', 'relax', 'fun', 'event',
  ];

  /// Retourne la liste des catégories avec labels traduits.
  List<(String, String)> get _categories {
    final s = S.current;
    return [
      ('nature', s.quizCatNature),
      ('culture', s.quizCatCulture),
      ('gastronomy', s.quizCatGastronomy),
      ('sport', s.quizCatSport),
      ('adventure', s.quizCatAdventure),
      ('relax', s.quizCatRelax),
      ('fun', s.quizCatFun),
      ('event', s.quizCatEvent),
    ];
  }

  // Liste des features stockées en DB (clés FR fixes — la traduction se fait
  // à l'affichage via _featuresLabels).
  static const _featuresValues = [
    'Reservation necessaire',
    'Parking',
    'Horaires restreints',
    'Minimum de participants',
  ];

  /// Labels traduits pour chaque feature (même ordre que _featuresValues).
  List<String> get _featuresLabels {
    final s = S.current;
    return [
      s.featureReservation,
      s.featureParking,
      s.featureRestrictedHours,
      s.featureMinParticipants,
    ];
  }

  // Clés DB fixes (ne pas traduire)
  static const _seasonsKeys = ['Printemps', 'Été', 'Automne', 'Hiver'];
  static const _socialTagsKeys = ['Famille', 'Couple', 'Amis', 'Solo'];

  /// Labels traduits pour les saisons (même ordre que _seasonsKeys).
  List<String> get _seasonsLabels {
    final s = S.current;
    return [
      s.submitSeasonSpring,
      s.submitSeasonSummer,
      s.submitSeasonAutumn,
      s.submitSeasonWinter,
    ];
  }

  /// Labels traduits pour les social tags.
  List<String> get _socialTagsLabels {
    final s = S.current;
    return [
      s.submitSocialFamily,
      s.submitSocialCouple,
      s.submitSocialFriends,
      s.submitSocialSolo,
    ];
  }

  /// Couples (level, label) pour les prix — label traduit pour 'Gratuit', le
  /// reste reste affichable (CHF reste universel).
  List<(int, String)> get _priceLevels {
    final s = S.current;
    return [
      (1, s.submitPriceFree),
      (2, '1-20 CHF'),
      (3, '20-50 CHF'),
      (4, '50-100 CHF'),
      (5, '100+ CHF'),
    ];
  }

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _activityUrlCtrl = TextEditingController();
  final _remoteImageUrlCtrl = TextEditingController();
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

  final List<_PhotoItem> _photos = [];
  final MapController _mapController = MapController();

  bool _submitting = false;
  bool _geocoding = false;
  String? _error;
  String? _geocodeInfo; // info textuelle apres geocode reussi

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _activityUrlCtrl.dispose();
    _remoteImageUrlCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _durationHoursCtrl.dispose();
    super.dispose();
  }

  /// Position courante affichee sur la carte (parsed depuis les TextFields).
  /// Centre sur Lausanne par defaut si rien n'est saisi.
  LatLng get _previewPosition {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lat != null && lng != null && lat >= -90 && lat <= 90 &&
        lng >= -180 && lng <= 180) {
      return LatLng(lat, lng);
    }
    return const LatLng(46.5197, 6.6323); // Lausanne par defaut
  }

  bool get _hasValidCoords {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());
    return lat != null && lng != null;
  }

  Future<void> _autoGeocode() async {
    final title = _titleCtrl.text.trim();
    final loc = _locationCtrl.text.trim();
    if (title.isEmpty && loc.isEmpty) {
      setState(() => _error = S.current.submitGeolocatePrompt);
      return;
    }
    setState(() {
      _geocoding = true;
      _error = null;
      _geocodeInfo = null;
    });

    // Construit la requete : titre + lieu, plus precis quand les deux sont
    // donnes. L'edge function appelle Google Places API (New).
    final query = [title, loc].where((s) => s.isNotEmpty).join(', ');

    try {
      final invoke = await Supabase.instance.client.functions.invoke(
        'geocode-place',
        body: {'query': query},
      );
      if (invoke.status >= 200 && invoke.status < 300 &&
          invoke.data is Map) {
        final data = invoke.data as Map;
        final lat = (data['lat'] as num?)?.toDouble();
        final lng = (data['lng'] as num?)?.toDouble();
        final name = data['display_name']?.toString() ?? '';
        if (lat != null && lng != null && mounted) {
          setState(() {
            _latCtrl.text = lat.toStringAsFixed(6);
            _lngCtrl.text = lng.toStringAsFixed(6);
            _geocodeInfo = name.length > 80
                ? '${name.substring(0, 80)}...'
                : name;
          });
          try {
            _mapController.move(LatLng(lat, lng), 15);
          } catch (_) {}
          return;
        }
      }
      // Reponse non OK : extraire le message si possible
      final errMsg = invoke.data is Map
          ? (invoke.data as Map)['error']?.toString() ??
              S.current.submitNoPlaceFound
          : S.current.submitNoPlaceFound;
      if (mounted) {
        setState(() => _error = errMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = '${S.current.submitGeolocateError} : $e');
      }
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  Future<void> _pickPhotosFromDevice() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      for (final file in picked) {
        final bytes = await file.readAsBytes();
        _photos.add(_PhotoItem(
          bytes: bytes,
          filename: file.name,
          mimeType: file.mimeType ?? 'image/jpeg',
        ));
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '${S.current.submitPhotoReadError} : $e');
    }
  }

  void _addRemoteUrl() {
    final url = _remoteImageUrlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      setState(() => _error = S.current.submitUrlMustStartWithHttp);
      return;
    }
    setState(() {
      _photos.add(_PhotoItem(url: url, filename: url));
      _remoteImageUrlCtrl.clear();
      _error = null;
    });
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  String? _validate() {
    final s = S.current;
    if (_titleCtrl.text.trim().isEmpty) return s.submitTitleRequired;
    if (_locationCtrl.text.trim().isEmpty) return s.submitLocationRequired;
    if (_selectedCategories.isEmpty) {
      return s.submitCategoryRequired;
    }
    if (_descriptionCtrl.text.trim().isEmpty) {
      return s.submitDescriptionRequired;
    }
    final lat = double.tryParse(_latCtrl.text.trim());
    if (lat == null || lat < -90 || lat > 90) {
      return s.submitLatitudeInvalid;
    }
    final lng = double.tryParse(_lngCtrl.text.trim());
    if (lng == null || lng < -180 || lng > 180) {
      return s.submitLongitudeInvalid;
    }
    final dur = double.tryParse(_durationHoursCtrl.text.trim());
    if (dur == null || dur <= 0) return s.submitDurationInvalid;
    if (_selectedSeasons.isEmpty) {
      return s.submitSeasonRequired;
    }
    if (_selectedSocialTags.isEmpty) {
      return s.submitSocialRequired;
    }
    if (!_isIndoor && !_isOutdoor) {
      return s.submitIndoorOutdoorRequired;
    }
    return null;
  }

  /// Upload tous les [_PhotoItem] locaux vers Supabase Storage et retourne
  /// la liste finale des URLs (locaux uploadés + URLs distantes deja saisies),
  /// dans l'ordre de l'utilisateur.
  Future<List<String>> _uploadAllPhotos() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final uid = user?.id ?? 'anonymous';
    final bucket = client.storage.from('activity-images');
    final urls = <String>[];

    for (var i = 0; i < _photos.length; i++) {
      final p = _photos[i];
      if (!p.isLocal) {
        urls.add(p.url!);
        continue;
      }
      final ext = _guessExt(p.filename, p.mimeType);
      final ts = DateTime.now().millisecondsSinceEpoch;
      // Chemin : {uid}/{timestamp}-{i}.{ext}. Le prefixe par uid satisfait
      // la policy RLS "owner = auth.uid()" pour update/delete ulterieurs.
      final path = '$uid/$ts-$i.$ext';
      await bucket.uploadBinary(
        path,
        p.bytes!,
        fileOptions: FileOptions(
          contentType: p.mimeType ?? 'image/jpeg',
          upsert: false,
        ),
      );
      final publicUrl = bucket.getPublicUrl(path);
      urls.add(publicUrl);
    }
    return urls;
  }

  String _guessExt(String filename, String? mimeType) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpg';
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.heic')) return 'heic';
    switch (mimeType) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/heic':
        return 'heic';
      default:
        return 'jpg';
    }
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
      final imageUrls = await _uploadAllPhotos();
      final user = Supabase.instance.client.auth.currentUser;
      final payload = {
        'title': _titleCtrl.text.trim(),
        'location_name': _locationCtrl.text.trim(),
        'category': _selectedCategories.join(','),
        'description': _descriptionCtrl.text.trim(),
        'activity_url': _activityUrlCtrl.text.trim().isEmpty
            ? null
            : _activityUrlCtrl.text.trim(),
        // image_url = premiere photo (retrocompat avec l'app qui lit un seul URL)
        'image_url': imageUrls.isNotEmpty ? imageUrls.first : null,
        'image_urls': imageUrls,
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
      };

      await Supabase.instance.client
          .from('activity_submissions')
          .insert(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.submitSuccess),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '${S.current.submitSubmitError}: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
      appBar: AppBar(
        title: Text(s.submitTitle),
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
                  label: '${s.submitName} *',
                  child: TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: s.submitNamePlaceholder,
                    ),
                  ),
                ),
                _Section(
                  label: '${s.submitLocation} *',
                  child: TextFormField(
                    controller: _locationCtrl,
                    decoration: InputDecoration(
                      hintText: s.submitLocationPlaceholder,
                    ),
                  ),
                ),
                _Section(
                  label: '${s.submitCategories} *',
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
                  label: '${s.submitDescription} *',
                  child: TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: s.submitDescriptionPlaceholder,
                    ),
                  ),
                ),
                _Section(
                  label: s.submitActivityUrlLabel,
                  child: TextFormField(
                    controller: _activityUrlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(hintText: 'https://...'),
                  ),
                ),

                // Photos : upload depuis l'appareil + optionnellement URL distantes
                _PhotoPicker(
                  photos: _photos,
                  onPickDevice: _pickPhotosFromDevice,
                  onRemove: _removePhoto,
                  remoteUrlCtrl: _remoteImageUrlCtrl,
                  onAddRemoteUrl: _addRemoteUrl,
                ),

                // Bouton auto-geocodage : appelle Nominatim avec titre+lieu
                // pour pre-remplir lat/lng. L'utilisateur peut ensuite ajuster
                // sur la carte (clic) ou directement dans les champs.
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _geocoding ? null : _autoGeocode,
                      icon: _geocoding
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.cyan,
                              ),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: Text(_geocoding
                          ? s.submitGeolocating
                          : s.submitGeolocate),
                    ),
                  ),
                ),
                if (_geocodeInfo != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: AppColors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _geocodeInfo!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.stone),
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: _Section(
                        label: '${s.submitLatitudeLabel} *',
                        child: TextFormField(
                          controller: _latCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                          decoration: const InputDecoration(hintText: '46.22'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Section(
                        label: '${s.submitLongitudeLabel} *',
                        child: TextFormField(
                          controller: _lngCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                          decoration: const InputDecoration(hintText: '7.36'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),

                // Mini-carte de previsualisation : tap sur la carte = met a jour
                // les coordonnees. Le marqueur orange montre la position
                // actuellement saisie.
                _Section(
                  label: s.submitMapPreviewLabel,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _previewPosition,
                          initialZoom: _hasValidCoords ? 14 : 9,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _latCtrl.text =
                                  point.latitude.toStringAsFixed(6);
                              _lngCtrl.text =
                                  point.longitude.toStringAsFixed(6);
                            });
                          },
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                            userAgentPackageName: 'com.example.whateka',
                          ),
                          if (_hasValidCoords)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _previewPosition,
                                  width: 36,
                                  height: 36,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.orange,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.place,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                _Section(
                  label: '${s.submitDuration} *',
                  child: TextFormField(
                    controller: _durationHoursCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(hintText: s.submitDurationHint),
                  ),
                ),
                _Section(
                  label: '${s.submitPrice} *',
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
                  label: s.submitFeatures,
                  child: _ChipSelector(
                    options: _featuresLabels,
                    values: _featuresValues,
                    selected: _selectedFeatures,
                    onToggle: (v) => setState(() {
                      _selectedFeatures.contains(v)
                          ? _selectedFeatures.remove(v)
                          : _selectedFeatures.add(v);
                    }),
                  ),
                ),
                _Section(
                  label: '${s.submitSeasonsLabel} *',
                  child: _ChipSelector(
                    options: _seasonsLabels,
                    values: _seasonsKeys,
                    selected: _selectedSeasons,
                    onToggle: (v) => setState(() {
                      _selectedSeasons.contains(v)
                          ? _selectedSeasons.remove(v)
                          : _selectedSeasons.add(v);
                    }),
                  ),
                ),
                _Section(
                  label: '${s.submitSocialTagsLabel} *',
                  child: _ChipSelector(
                    options: _socialTagsLabels,
                    values: _socialTagsKeys,
                    selected: _selectedSocialTags,
                    onToggle: (v) => setState(() {
                      _selectedSocialTags.contains(v)
                          ? _selectedSocialTags.remove(v)
                          : _selectedSocialTags.add(v);
                    }),
                  ),
                ),
                _Section(
                  label: '${s.submitTypeLabel} *',
                  child: Row(
                    children: [
                      Expanded(
                        child: _ToggleCard(
                          label: s.submitIndoor,
                          icon: Icons.home_outlined,
                          selected: _isIndoor,
                          onTap: () =>
                              setState(() => _isIndoor = !_isIndoor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ToggleCard(
                          label: s.submitOutdoor,
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
                      : Text(s.submitConfirm),
                ),
                const SizedBox(height: 8),
                Text(
                  s.submitAdminReviewNotice,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
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

/// Section photos : permet d'uploader des images depuis l'appareil
/// (image_picker, multi-selection) ET/OU d'ajouter des URLs distantes.
/// Affiche une grille de thumbnails avec bouton × pour supprimer.
class _PhotoPicker extends StatelessWidget {
  final List<_PhotoItem> photos;
  final VoidCallback onPickDevice;
  final void Function(int) onRemove;
  final TextEditingController remoteUrlCtrl;
  final VoidCallback onAddRemoteUrl;

  const _PhotoPicker({
    required this.photos,
    required this.onPickDevice,
    required this.onRemove,
    required this.remoteUrlCtrl,
    required this.onAddRemoteUrl,
  });

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: S.of(context).submitPhoto,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnails grid (4 par ligne)
          if (photos.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(photos.length, (i) {
                final p = photos[i];
                return SizedBox(
                  width: 84,
                  height: 84,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: p.isLocal
                              ? Image.memory(p.bytes!, fit: BoxFit.cover)
                              : Image.network(
                                  p.url!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.line,
                                    child: const Icon(Icons.broken_image,
                                        size: 24, color: AppColors.stone),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemove(i),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],

          // Bouton upload depuis l'appareil
          OutlinedButton.icon(
            onPressed: onPickDevice,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(photos.isEmpty
                ? S.current.submitAddPhotos
                : S.current.submitAddMorePhotos),
          ),
          const SizedBox(height: 12),

          // OU URL distante
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: remoteUrlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    hintText: S.current.submitOrAddUrl,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAddRemoteUrl,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.cyan,
                tooltip: S.current.submitAdd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
