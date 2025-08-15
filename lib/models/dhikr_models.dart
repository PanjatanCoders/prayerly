// models/dhikr_models.dart

import 'package:flutter/material.dart';

/// Model for individual Dhikr/Tasbih item
class Dhikr {
  final String id;
  final String arabic;
  final String transliteration;
  final String translation;
  final String meaning;
  final int targetCount;
  final DhikrCategory category;
  final int? reward; // Optional: spiritual reward mentioned in hadith

  const Dhikr({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.meaning,
    this.targetCount = 33,
    required this.category,
    this.reward,
  });

  Dhikr copyWith({
    String? id,
    String? arabic,
    String? transliteration,
    String? translation,
    String? meaning,
    int? targetCount,
    DhikrCategory? category,
    int? reward,
  }) {
    return Dhikr(
      id: id ?? this.id,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      meaning: meaning ?? this.meaning,
      targetCount: targetCount ?? this.targetCount,
      category: category ?? this.category,
      reward: reward ?? this.reward,
    );
  }
}

/// Categories for organizing Dhikr
enum DhikrCategory {
  tasbih,     // Glorification
  tahmid,     // Praise
  takbir,     // Magnification
  tahlil,     // Declaration of faith
  istighfar,  // Seeking forgiveness
  salawat,    // Blessings on Prophet
  dua,        // Supplications
  asmaUlHusna, // Names of Allah
  custom,     // User-created
}

extension DhikrCategoryExtension on DhikrCategory {
  String get displayName {
    switch (this) {
      case DhikrCategory.tasbih:
        return 'Tasbih (Glorification)';
      case DhikrCategory.tahmid:
        return 'Tahmid (Praise)';
      case DhikrCategory.takbir:
        return 'Takbir (Magnification)';
      case DhikrCategory.tahlil:
        return 'Tahlil (Declaration)';
      case DhikrCategory.istighfar:
        return 'Istighfar (Forgiveness)';
      case DhikrCategory.salawat:
        return 'Salawat (Blessings)';
      case DhikrCategory.dua:
        return 'Dua (Supplications)';
      case DhikrCategory.asmaUlHusna:
        return 'Asma ul-Husna';
      case DhikrCategory.custom:
        return 'Custom Dhikr';
    }
  }

  Color get color {
    switch (this) {
      case DhikrCategory.tasbih:
        return const Color(0xFF2E7D32); // Green
      case DhikrCategory.tahmid:
        return const Color(0xFF1976D2); // Blue
      case DhikrCategory.takbir:
        return const Color(0xFFD32F2F); // Red
      case DhikrCategory.tahlil:
        return const Color(0xFF7B1FA2); // Purple
      case DhikrCategory.istighfar:
        return const Color(0xFFF57C00); // Orange
      case DhikrCategory.salawat:
        return const Color(0xFF388E3C); // Dark Green
      case DhikrCategory.dua:
        return const Color(0xFF5D4037); // Brown
      case DhikrCategory.asmaUlHusna:
        return const Color(0xFF0288D1); // Light Blue
      case DhikrCategory.custom:
        return const Color(0xFF424242); // Grey
    }
  }
}

/// Model for tracking Dhikr count and sessions
class DhikrSession {
  final String id;
  final String dhikrId;
  final int count;
  final int targetCount;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;

  const DhikrSession({
    required this.id,
    required this.dhikrId,
    required this.count,
    required this.targetCount,
    required this.startTime,
    this.endTime,
    required this.isCompleted,
  });

  DhikrSession copyWith({
    String? id,
    String? dhikrId,
    int? count,
    int? targetCount,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
  }) {
    return DhikrSession(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
      count: count ?? this.count,
      targetCount: targetCount ?? this.targetCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Calculate completion percentage
  double get progress => count / targetCount;

  /// Get session duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Check if target is reached
  bool get isTargetReached => count >= targetCount;
}

/// Statistics for Dhikr tracking
class DhikrStats {
  final int totalCount;
  final int totalSessions;
  final int completedSessions;
  final Duration totalTime;
  final Map<String, int> dhikrCounts;
  final DateTime? lastSession;

  const DhikrStats({
    required this.totalCount,
    required this.totalSessions,
    required this.completedSessions,
    required this.totalTime,
    required this.dhikrCounts,
    this.lastSession,
  });

  /// Calculate completion rate
  double get completionRate {
    if (totalSessions == 0) return 0.0;
    return completedSessions / totalSessions;
  }

  /// Get average session duration
  Duration get averageSessionDuration {
    if (totalSessions == 0) return Duration.zero;
    return Duration(
      milliseconds: totalTime.inMilliseconds ~/ totalSessions,
    );
  }
}

/// Settings for Dhikr counter
class DhikrSettings {
  final bool enableHapticFeedback;
  final bool enableSound;
  final bool showArabicText;
  final bool showTransliteration;
  final bool showTranslation;
  final double fontSize;
  final bool autoReset;
  final int defaultTargetCount;

  const DhikrSettings({
    this.enableHapticFeedback = true,
    this.enableSound = false,
    this.showArabicText = true,
    this.showTransliteration = true,
    this.showTranslation = true,
    this.fontSize = 16.0,
    this.autoReset = false,
    this.defaultTargetCount = 33,
  });

  DhikrSettings copyWith({
    bool? enableHapticFeedback,
    bool? enableSound,
    bool? showArabicText,
    bool? showTransliteration,
    bool? showTranslation,
    double? fontSize,
    bool? autoReset,
    int? defaultTargetCount,
  }) {
    return DhikrSettings(
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableSound: enableSound ?? this.enableSound,
      showArabicText: showArabicText ?? this.showArabicText,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      showTranslation: showTranslation ?? this.showTranslation,
      fontSize: fontSize ?? this.fontSize,
      autoReset: autoReset ?? this.autoReset,
      defaultTargetCount: defaultTargetCount ?? this.defaultTargetCount,
    );
  }
}