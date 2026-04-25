import '../i18n/strings.dart';

class Activity {
  final int id;
  final String title;
  final String? titleEn;
  final String location; // mapped from location_name (jamais traduit)
  final String duration; // mapped from duration_minutes → formatted as hours
  final String? description;
  final String? descriptionEn;
  final String? dateLabel;
  final String? dateLabelEn;
  final String? imageUrl; // mapped from image_url
  final String? category;
  final String? activityUrl; // mapped from activity_url
  final List<String> features;
  final double latitude;
  final double longitude;
  final int priceLevel;
  // Depuis migration 0002, une activite peut etre les deux a la fois
  // (ex : parc aquatique avec bassins interieurs et exterieurs).
  final bool isOutdoor;
  final bool isIndoor;

  // Contraintes temporelles (v26 algo) — utilisees pour le filtre Live/Tout
  final String? recurrenceType; // 'one_off' | 'weekly' | 'seasonal' | null
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final List<int>? seasonalMonths;
  final List<int>? weeklyDays;

  // Local state only, not from DB for now
  bool isFavorite;
  String? aiReason; // AI-generated personalized explanation

  Activity({
    required this.id,
    required this.title,
    this.titleEn,
    required this.location,
    required this.duration,
    this.description,
    this.descriptionEn,
    this.dateLabel,
    this.dateLabelEn,
    this.imageUrl,
    this.category,
    this.activityUrl,
    required this.features,
    required this.latitude,
    required this.longitude,
    this.priceLevel = 1,
    this.isOutdoor = true,
    this.isIndoor = false,
    this.recurrenceType,
    this.dateStart,
    this.dateEnd,
    this.seasonalMonths,
    this.weeklyDays,
    this.isFavorite = false,
    this.aiReason,
  });

  /// Logique miroir de l'algo recommend-activity v29 :
  /// retourne true si l'activite est proposable a la date `now`.
  bool isProposableAt(DateTime now) {
    // v29 : un event sans date_start est une fiche template (club, institution
    // sans match planifie) - pas recommandable.
    final cats = (category ?? '').split(',').map((c) => c.trim().toLowerCase()).toList();
    final isEvent = cats.contains('event');
    if (isEvent && (dateStart == null || dateEnd == null)) return false;

    if (recurrenceType == null) return true;
    final hasWeekly = weeklyDays != null && weeklyDays!.isNotEmpty;
    final hasSeasonal = seasonalMonths != null && seasonalMonths!.isNotEmpty;
    final hasOneOff = recurrenceType == 'one_off' && dateStart != null && dateEnd != null;

    if (hasWeekly && !weeklyDays!.contains(now.weekday % 7)) return false;
    if (hasSeasonal && !seasonalMonths!.contains(now.month)) return false;
    if (hasOneOff) {
      final start = dateStart!;
      final end = DateTime(dateEnd!.year, dateEnd!.month, dateEnd!.day, 23, 59, 59);
      if (now.isAfter(end)) return false;
      final dur = end.difference(start).inDays + 1;
      if (dur <= 1) {
        // v27 : 1-jour -> 5 jours avant + jour J
        final win = end.subtract(const Duration(days: 5));
        if (now.isBefore(win)) return false;
      } else if (dur <= 7) {
        final win = end.subtract(const Duration(days: 21));
        if (now.isBefore(win)) return false;
      } else if (dur < 30) {
        final win = start.subtract(const Duration(days: 21));
        if (now.isBefore(win)) return false;
      } else {
        if (now.isBefore(start)) return false;
      }
    }
    if (recurrenceType == 'seasonal' && !hasSeasonal) return false;
    return true;
  }

  /// Retourne true si l'activite est echue (one_off avec date_end < now).
  bool isExpiredAt(DateTime now) {
    if (recurrenceType != 'one_off' || dateEnd == null) return false;
    final end = DateTime(dateEnd!.year, dateEnd!.month, dateEnd!.day, 23, 59, 59);
    return now.isAfter(end);
  }

  /// Format duration_minutes into a human-readable string in hours
  static String _formatDuration(int minutes) {
    if (minutes <= 0) return '';
    if (minutes < 60) return '$minutes min';
    final hours = minutes / 60;
    if (hours == hours.truncateToDouble()) {
      return '${hours.toInt()} h';
    }
    return '${hours.toStringAsFixed(1)} h';
  }

  /// Returns a human-readable price label for the given price level
  /// (locale-aware via S.current).
  static String priceLevelLabel(int level) {
    final s = S.current;
    switch (level) {
      case 1:
        return s.quizPriceFree; // Gratuit / Free
      case 2:
        return s.quizPriceLow; // 1-20 CHF
      case 3:
        return s.quizPriceMid; // 20-50 CHF
      case 4:
        return s.quizPriceHigh; // 50-100 CHF
      case 5:
        return s.quizPriceVeryHigh; // 100+ CHF
      default:
        return s.quizPriceFree;
    }
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int,
      title: json['title'] as String,
      titleEn: json['title_en'] as String?,
      location: json['location_name'] as String,
      duration: _formatDuration(json['duration_minutes'] as int? ?? 0),
      description: json['description'] as String?,
      descriptionEn: json['description_en'] as String?,
      dateLabel: json['date_label'] as String?,
      dateLabelEn: json['date_label_en'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      activityUrl: json['activity_url'] as String?,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      priceLevel: json['price_level'] as int? ?? 1,
      isOutdoor: json['is_outdoor'] as bool? ?? true,
      isIndoor: json['is_indoor'] as bool? ?? false,
      recurrenceType: json['recurrence_type'] as String?,
      dateStart: json['date_start'] != null ? DateTime.tryParse(json['date_start'] as String) : null,
      dateEnd: json['date_end'] != null ? DateTime.tryParse(json['date_end'] as String) : null,
      seasonalMonths: (json['seasonal_months'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      weeklyDays: (json['weekly_days'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }
}

// Temporary empty list to avoid breaking imports immediately, though files using it will need updates
List<Activity> mockActivities = [];
