import 'package:flutter/foundation.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/models/activity_models.dart';

class ActivityService extends ApiService {
  static Future<void> recordActivity({
    required int resourceId,
    required String activityType,
    required bool isCompleted,
    required DateTime startTime,
  }) async {
    final durationSeconds = DateTime.now().difference(startTime).inSeconds;
    if (durationSeconds < 10) return;

    try {
      debugPrint("--- MOCK ACTIVITY RECORD ---");
      debugPrint("Payload: ${{
        'resourceId': resourceId,
        'activityType': activityType,
        'durationSeconds': durationSeconds,
        'isCompleted': isCompleted,
      }}");
    } catch (e) {
      debugPrint("Error recording activity (silently failing): $e");
    }
  }

  static Future<List<DailyActivitySummary>> fetchMyActivitySummary() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      DailyActivitySummary(
        date: DateTime.now(),
        totalDurationSeconds: 45 * 60 + 15,
        activities: [
          ActivityDetail(
              resourceTitle: "Introduction to Sacraments",
              activityType: "video",
              durationSeconds: 25 * 60 + 5),
          ActivityDetail(
              resourceTitle: "The Meaning of Lent",
              activityType: "article",
              durationSeconds: 20 * 60 + 10),
        ],
      ),
      DailyActivitySummary(
        date: DateTime.now().subtract(const Duration(days: 1)),
        totalDurationSeconds: 12 * 60,
        activities: [
          ActivityDetail(
              resourceTitle: "Lives of the Martyrs",
              activityType: "article",
              durationSeconds: 12 * 60),
        ],
      ),
    ];
  }
}
