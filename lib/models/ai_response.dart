import 'activity.dart';

/// Response structure from AI recommendation endpoint
class AiResponse {
  final List<Activity> activities;
  final String globalComment;

  AiResponse({
    required this.activities,
    required this.globalComment,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      globalComment: json['global_comment'] as String? ?? '',
    );
  }
}
