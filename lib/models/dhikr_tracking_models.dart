// models/dhikr_tracking_models.dart
// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';

import '../models/dhikr_models.dart';

/// Enhanced Dhikr model with user customization
class CustomDhikr extends Dhikr {
  final bool isCustom;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final int totalRecitations;

  const CustomDhikr({
    required super.id,
    required super.arabic,
    required super.transliteration,
    required super.translation,
    required super.meaning,
    required super.targetCount,
    required super.category,
    super.reward,
    this.isCustom = false,
    required this.createdAt,
    this.lastUsed,
    this.totalRecitations = 0,
  });

  CustomDhikr copyWith({
    String? id,
    String? arabic,
    String? transliteration,
    String? translation,
    String? meaning,
    int? targetCount,
    DhikrCategory? category,
    int? reward,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? totalRecitations,
  }) {
    return CustomDhikr(
      id: id ?? this.id,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      meaning: meaning ?? this.meaning,
      targetCount: targetCount ?? this.targetCount,
      category: category ?? this.category,
      reward: reward ?? this.reward,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      totalRecitations: totalRecitations ?? this.totalRecitations,
    );
  }

  /// Convert to regular Dhikr
  Dhikr toDhikr() {
    return Dhikr(
      id: id,
      arabic: arabic,
      transliteration: transliteration,
      translation: translation,
      meaning: meaning,
      targetCount: targetCount,
      category: category,
      reward: reward,
    );
  }

  /// Create from regular Dhikr
  factory CustomDhikr.fromDhikr(Dhikr dhikr, {
    bool isCustom = false,
    DateTime? createdAt,
    DateTime? lastUsed,
    int totalRecitations = 0,
  }) {
    return CustomDhikr(
      id: dhikr.id,
      arabic: dhikr.arabic,
      transliteration: dhikr.transliteration,
      translation: dhikr.translation,
      meaning: dhikr.meaning,
      targetCount: dhikr.targetCount,
      category: dhikr.category,
      reward: dhikr.reward,
      isCustom: isCustom,
      createdAt: createdAt ?? DateTime.now(),
      lastUsed: lastUsed,
      totalRecitations: totalRecitations,
    );
  }

  /// Create custom dhikr from user input
  factory CustomDhikr.createCustom({
    required String title,
    required int targetCount,
    String? description,
  }) {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    return CustomDhikr(
      id: id,
      arabic: title, // User can input Arabic or just title
      transliteration: title,
      translation: description ?? title,
      meaning: description ?? 'Custom dhikr created by user',
      targetCount: targetCount,
      category: DhikrCategory.custom,
      isCustom: true,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
      'meaning': meaning,
      'targetCount': targetCount,
      'category': category.toString(),
      'reward': reward,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'totalRecitations': totalRecitations,
    };
  }

  factory CustomDhikr.fromJson(Map<String, dynamic> json) {
    return CustomDhikr(
      id: json['id'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      meaning: json['meaning'],
      targetCount: json['targetCount'],
      category: DhikrCategory.values.firstWhere(
        (c) => c.toString() == json['category'],
        orElse: () => DhikrCategory.custom,
      ),
      reward: json['reward'],
      isCustom: json['isCustom'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null 
        ? DateTime.parse(json['lastUsed']) 
        : null,
      totalRecitations: json['totalRecitations'] ?? 0,
    );
  }
}

/// Enhanced session tracking with detailed statistics
class DhikrSessionTracker extends DhikrSession {
  final String dhikrTitle;
  final double averageSpeed; // counts per minute
  final List<DateTime> timestamps; // when each count was made
  final bool wasCompleted;
  final Duration totalDuration;

  const DhikrSessionTracker({
    required super.id,
    required super.dhikrId,
    required super.count,
    required super.targetCount,
    required super.startTime,
    super.endTime,
    required super.isCompleted,
    required this.dhikrTitle,
    this.averageSpeed = 0,
    this.timestamps = const [],
    required this.wasCompleted,
    required this.totalDuration,
  });

  DhikrSessionTracker copyWith({
    String? id,
    String? dhikrId,
    int? count,
    int? targetCount,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    String? dhikrTitle,
    double? averageSpeed,
    List<DateTime>? timestamps,
    bool? wasCompleted,
    Duration? totalDuration,
  }) {
    return DhikrSessionTracker(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
      count: count ?? this.count,
      targetCount: targetCount ?? this.targetCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      dhikrTitle: dhikrTitle ?? this.dhikrTitle,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      timestamps: timestamps ?? this.timestamps,
      wasCompleted: wasCompleted ?? this.wasCompleted,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  /// Calculate average speed from timestamps
  double calculateAverageSpeed() {
    if (timestamps.length < 2) return 0;
    final duration = timestamps.last.difference(timestamps.first);
    if (duration.inSeconds == 0) return 0;
    return (timestamps.length - 1) / (duration.inMinutes > 0 ? duration.inMinutes : 1);
  }

  /// Get session efficiency (percentage of target achieved)
  double get efficiency => count / targetCount;

  /// Check if session was fast (above average speed)
  bool get isFastSession => averageSpeed > 60; // More than 1 per second

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dhikrId': dhikrId,
      'dhikrTitle': dhikrTitle,
      'count': count,
      'targetCount': targetCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'averageSpeed': averageSpeed,
      'timestamps': timestamps.map((t) => t.toIso8601String()).toList(),
      'wasCompleted': wasCompleted,
      'totalDuration': totalDuration.inMilliseconds,
    };
  }

  factory DhikrSessionTracker.fromJson(Map<String, dynamic> json) {
    return DhikrSessionTracker(
      id: json['id'],
      dhikrId: json['dhikrId'],
      dhikrTitle: json['dhikrTitle'],
      count: json['count'],
      targetCount: json['targetCount'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null 
        ? DateTime.parse(json['endTime']) 
        : null,
      isCompleted: json['isCompleted'],
      averageSpeed: json['averageSpeed']?.toDouble() ?? 0.0,
      timestamps: (json['timestamps'] as List<dynamic>?)
          ?.map((t) => DateTime.parse(t))
          .toList() ?? [],
      wasCompleted: json['wasCompleted'] ?? false,
      totalDuration: Duration(
        milliseconds: json['totalDuration'] ?? 0,
      ),
    );
  }
}

/// User's overall Dhikr statistics and achievements
class DhikrUserStats {
  final int totalDhikrRecited;
  final int totalSessionsCompleted;
  final int totalSessionsStarted;
  final Duration totalTimeSpent;
  final Map<String, int> dhikrCounts; // dhikrId -> total count
  final Map<DhikrCategory, int> categoryStats;
  final List<String> achievements;
  final DateTime? lastActivity;
  final int currentStreak; // days with dhikr activity
  final int longestStreak;

  const DhikrUserStats({
    this.totalDhikrRecited = 0,
    this.totalSessionsCompleted = 0,
    this.totalSessionsStarted = 0,
    this.totalTimeSpent = Duration.zero,
    this.dhikrCounts = const {},
    this.categoryStats = const {},
    this.achievements = const [],
    this.lastActivity,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  DhikrUserStats copyWith({
    int? totalDhikrRecited,
    int? totalSessionsCompleted,
    int? totalSessionsStarted,
    Duration? totalTimeSpent,
    Map<String, int>? dhikrCounts,
    Map<DhikrCategory, int>? categoryStats,
    List<String>? achievements,
    DateTime? lastActivity,
    int? currentStreak,
    int? longestStreak,
  }) {
    return DhikrUserStats(
      totalDhikrRecited: totalDhikrRecited ?? this.totalDhikrRecited,
      totalSessionsCompleted: totalSessionsCompleted ?? this.totalSessionsCompleted,
      totalSessionsStarted: totalSessionsStarted ?? this.totalSessionsStarted,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      dhikrCounts: dhikrCounts ?? this.dhikrCounts,
      categoryStats: categoryStats ?? this.categoryStats,
      achievements: achievements ?? this.achievements,
      lastActivity: lastActivity ?? this.lastActivity,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  /// Get completion rate
  double get completionRate {
    if (totalSessionsStarted == 0) return 0;
    return totalSessionsCompleted / totalSessionsStarted;
  }

  /// Get average session duration
  Duration get averageSessionDuration {
    if (totalSessionsCompleted == 0) return Duration.zero;
    return Duration(
      milliseconds: totalTimeSpent.inMilliseconds ~/ totalSessionsCompleted,
    );
  }

  /// Check if user is active today
  bool get isActiveToday {
    if (lastActivity == null) return false;
    final today = DateTime.now();
    final lastDay = lastActivity!;
    return today.year == lastDay.year &&
           today.month == lastDay.month &&
           today.day == lastDay.day;
  }

  /// Get rank based on total dhikr recited
  String get userRank {
    if (totalDhikrRecited < 100) return 'Beginner';
    if (totalDhikrRecited < 1000) return 'Regular';
    if (totalDhikrRecited < 5000) return 'Dedicated';
    if (totalDhikrRecited < 10000) return 'Devoted';
    if (totalDhikrRecited < 50000) return 'Expert';
    return 'Master';
  }

  /// Get progress to next rank
  double get progressToNextRank {
    final thresholds = [100, 1000, 5000, 10000, 50000, 100000];
    for (final threshold in thresholds) {
      if (totalDhikrRecited < threshold) {
        final previous = thresholds.indexOf(threshold) == 0 
          ? 0 
          : thresholds[thresholds.indexOf(threshold) - 1];
        return (totalDhikrRecited - previous) / (threshold - previous);
      }
    }
    return 1.0; // Max rank achieved
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDhikrRecited': totalDhikrRecited,
      'totalSessionsCompleted': totalSessionsCompleted,
      'totalSessionsStarted': totalSessionsStarted,
      'totalTimeSpent': totalTimeSpent.inMilliseconds,
      'dhikrCounts': dhikrCounts,
      'categoryStats': categoryStats.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'achievements': achievements,
      'lastActivity': lastActivity?.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory DhikrUserStats.fromJson(Map<String, dynamic> json) {
    return DhikrUserStats(
      totalDhikrRecited: json['totalDhikrRecited'] ?? 0,
      totalSessionsCompleted: json['totalSessionsCompleted'] ?? 0,
      totalSessionsStarted: json['totalSessionsStarted'] ?? 0,
      totalTimeSpent: Duration(
        milliseconds: json['totalTimeSpent'] ?? 0,
      ),
      dhikrCounts: Map<String, int>.from(json['dhikrCounts'] ?? {}),
      categoryStats: (json['categoryStats'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          DhikrCategory.values.firstWhere(
            (c) => c.toString() == key,
            orElse: () => DhikrCategory.custom,
          ),
          value as int,
        ),
      ) ?? {},
      achievements: List<String>.from(json['achievements'] ?? []),
      lastActivity: json['lastActivity'] != null 
        ? DateTime.parse(json['lastActivity']) 
        : null,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }
}

/// Available achievements for users
class DhikrAchievements {
  static const List<String> availableAchievements = [
    'first_dhikr',      // First dhikr completed
    'daily_dhikr',      // Complete dhikr for 7 days
    'weekly_warrior',   // Complete dhikr for 30 days
    'century_club',     // 100 total dhikr
    'thousand_club',    // 1000 total dhikr
    'speed_demon',      // Complete 100 dhikr in under 2 minutes
    'category_master',  // Complete dhikr in all categories
    'custom_creator',   // Create 5 custom dhikr
    'perfect_week',     // 100% completion rate for a week
    'ramadan_special',  // Complete special Ramadan dhikr
  ];

  static String getAchievementTitle(String achievement) {
    switch (achievement) {
      case 'first_dhikr':
        return 'First Steps';
      case 'daily_dhikr':
        return 'Daily Devotion';
      case 'weekly_warrior':
        return 'Weekly Warrior';
      case 'century_club':
        return 'Century Club';
      case 'thousand_club':
        return 'Thousand Club';
      case 'speed_demon':
        return 'Speed Demon';
      case 'category_master':
        return 'Category Master';
      case 'custom_creator':
        return 'Custom Creator';
      case 'perfect_week':
        return 'Perfect Week';
      case 'ramadan_special':
        return 'Ramadan Special';
      default:
        return 'Unknown Achievement';
    }
  }

  static String getAchievementDescription(String achievement) {
    switch (achievement) {
      case 'first_dhikr':
        return 'Complete your first dhikr session';
      case 'daily_dhikr':
        return 'Complete dhikr for 7 consecutive days';
      case 'weekly_warrior':
        return 'Complete dhikr for 30 consecutive days';
      case 'century_club':
        return 'Recite 100 total dhikr';
      case 'thousand_club':
        return 'Recite 1,000 total dhikr';
      case 'speed_demon':
        return 'Complete 100 dhikr in under 2 minutes';
      case 'category_master':
        return 'Complete dhikr in all categories';
      case 'custom_creator':
        return 'Create 5 custom dhikr';
      case 'perfect_week':
        return 'Achieve 100% completion rate for a week';
      case 'ramadan_special':
        return 'Complete special Ramadan dhikr collection';
      default:
        return 'Mysterious achievement';
    }
  }

  static IconData getAchievementIcon(String achievement) {
    switch (achievement) {
      case 'first_dhikr':
        return Icons.star;
      case 'daily_dhikr':
        return Icons.today;
      case 'weekly_warrior':
        return Icons.calendar_month;
      case 'century_club':
        return Icons.looks_one;
      case 'thousand_club':
        return Icons.military_tech;
      case 'speed_demon':
        return Icons.speed;
      case 'category_master':
        return Icons.category;
      case 'custom_creator':
        return Icons.create;
      case 'perfect_week':
        return Icons.memory_outlined;
      case 'ramadan_special':
        return Icons.star_half;
      default:
        return Icons.emoji_events;
    }
  }
}