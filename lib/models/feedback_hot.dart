class FeedbackHot {
  final int? id;
  final DateTime? createdAt;
  final String? userId;
  final int activityId;
  final int recommendationSatisfaction;
  final bool discoveredNewActivities;
  final int personalizationSatisfaction;
  final int informationLevelSatisfaction;
  final String? comments;

  FeedbackHot({
    this.id,
    this.createdAt,
    this.userId,
    required this.activityId,
    required this.recommendationSatisfaction,
    required this.discoveredNewActivities,
    required this.personalizationSatisfaction,
    required this.informationLevelSatisfaction,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'activity_id': activityId,
      'recommendation_satisfaction': recommendationSatisfaction,
      'discovered_new_activities': discoveredNewActivities,
      'personalization_satisfaction': personalizationSatisfaction,
      'information_level_satisfaction': informationLevelSatisfaction,
      'comments': comments,
    };
  }

  factory FeedbackHot.fromJson(Map<String, dynamic> json) {
    return FeedbackHot(
      id: json['id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      userId: json['user_id'],
      activityId: json['activity_id'],
      recommendationSatisfaction: json['recommendation_satisfaction'],
      discoveredNewActivities: json['discovered_new_activities'],
      personalizationSatisfaction: json['personalization_satisfaction'],
      informationLevelSatisfaction: json['information_level_satisfaction'],
      comments: json['comments'],
    );
  }
}
