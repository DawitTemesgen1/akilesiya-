import 'package:flutter/material.dart';

/// Represents a summary of user activity for a single day.
class DailyActivitySummary {
  final DateTime date;
  final int totalDurationSeconds; // Total time spent on all resources this day
  final List<ActivityDetail> activities;

  DailyActivitySummary({
    required this.date,
    required this.totalDurationSeconds,
    required this.activities,
  });

  // A helper to format the total duration into a readable string like "1h 15m"
  String get formattedTotalDuration {
    final duration = Duration(seconds: totalDurationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

/// Represents a single activity, like reading an article or watching a video.
class ActivityDetail {
  final String resourceTitle;
  final String activityType; // 'article' or 'video'
  final int durationSeconds;

  ActivityDetail({
    required this.resourceTitle,
    required this.activityType,
    required this.durationSeconds,
  });

  String get formattedDuration {
    final duration = Duration(seconds: durationSeconds);
    return "${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s";
  }

  IconData get icon {
    return activityType == 'video'
        ? Icons.play_circle_filled_rounded
        : Icons.article_rounded;
  }
}
