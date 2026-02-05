class Activity {
  final int id;
  final String title;
  final String location; // mapped from location_name
  final String duration; // mapped from duration_minutes
  final String? description;
  final String? imageUrl; // mapped from image_url
  final String? category;
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
    required this.features,
    required this.latitude,
    required this.longitude,
    this.priceLevel = 1,
    this.isOutdoor = true,
    this.isFavorite = false,
    this.aiReason,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int,
      title: json['title'] as String,
      location: json['location_name'] as String,
      duration: '${json['duration_minutes']} min', // Simple formatting
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
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
