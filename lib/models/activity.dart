class Activity {
  final int id;
  final String title;
  final String location; // mapped from location_name
  final String duration; // mapped from duration_minutes → formatted as hours
  final String? description;
  final String? imageUrl; // mapped from image_url
  final String? category;
  final String? activityUrl; // mapped from activity_url
  final List<String> features;
  final double latitude;
  final double longitude;
  final int priceLevel;
  final bool isOutdoor;

  // Local state only, not from DB for now
  bool isFavorite;
  String? aiReason; // AI-generated personalized explanation

  Activity({
    required this.id,
    required this.title,
    required this.location,
    required this.duration,
    this.description,
    this.imageUrl,
    this.category,
    this.activityUrl,
    required this.features,
    required this.latitude,
    required this.longitude,
    this.priceLevel = 1,
    this.isOutdoor = true,
    this.isFavorite = false,
    this.aiReason,
  });

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
  static String priceLevelLabel(int level) {
    switch (level) {
      case 1:
        return 'Gratuit';
      case 2:
        return '1–20 CHF';
      case 3:
        return '20–50 CHF';
      case 4:
        return '50–100 CHF';
      case 5:
        return '100 CHF et plus';
      default:
        return 'Gratuit';
    }
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int,
      title: json['title'] as String,
      location: json['location_name'] as String,
      duration: _formatDuration(json['duration_minutes'] as int? ?? 0),
      description: json['description'] as String?,
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
    );
  }
}

// Temporary empty list to avoid breaking imports immediately, though files using it will need updates
List<Activity> mockActivities = [];
