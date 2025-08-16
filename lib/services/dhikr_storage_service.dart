import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/dhikr_tracking_models.dart';
import '../models/dhikr_models.dart';

class DhikrStorageService {
  static const String _customDhikrKey = 'custom_dhikr_list';
  static const String _sessionsKey = 'dhikr_sessions';
  static const String _userStatsKey = 'dhikr_user_stats';
  static const String _settingsKey = 'dhikr_settings';

  // Custom Dhikr Management
  static Future<List<CustomDhikr>> getCustomDhikrList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_customDhikrKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CustomDhikr.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading custom dhikr: $e');
      return [];
    }
  }

  static Future<void> saveCustomDhikrList(List<CustomDhikr> dhikrList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = dhikrList.map((dhikr) => dhikr.toJson()).toList();
      await prefs.setString(_customDhikrKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving custom dhikr: $e');
    }
  }

  static Future<void> addCustomDhikr(CustomDhikr dhikr) async {
    final dhikrList = await getCustomDhikrList();
    dhikrList.add(dhikr);
    await saveCustomDhikrList(dhikrList);
  }

  static Future<void> updateCustomDhikr(CustomDhikr dhikr) async {
    final dhikrList = await getCustomDhikrList();
    final index = dhikrList.indexWhere((d) => d.id == dhikr.id);
    if (index != -1) {
      dhikrList[index] = dhikr;
      await saveCustomDhikrList(dhikrList);
    }
  }

  static Future<void> deleteCustomDhikr(String dhikrId) async {
    final dhikrList = await getCustomDhikrList();
    dhikrList.removeWhere((dhikr) => dhikr.id == dhikrId);
    await saveCustomDhikrList(dhikrList);
  }

  static Future<void> incrementDhikrCount(String dhikrId, int count) async {
    final dhikrList = await getCustomDhikrList();
    final index = dhikrList.indexWhere((d) => d.id == dhikrId);
    if (index != -1) {
      final updatedDhikr = dhikrList[index].copyWith(
        totalRecitations: dhikrList[index].totalRecitations + count,
        lastUsed: DateTime.now(),
      );
      dhikrList[index] = updatedDhikr;
      await saveCustomDhikrList(dhikrList);
    }
  }

  // Session Management
  static Future<List<DhikrSessionTracker>> getDhikrSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_sessionsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => DhikrSessionTracker.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading dhikr sessions: $e');
      return [];
    }
  }

  static Future<void> saveDhikrSessions(List<DhikrSessionTracker> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = sessions.map((session) => session.toJson()).toList();
      await prefs.setString(_sessionsKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving dhikr sessions: $e');
    }
  }

  static Future<void> addDhikrSession(DhikrSessionTracker session) async {
    final sessions = await getDhikrSessions();
    sessions.add(session);
    
    // Keep only last 100 sessions to prevent storage bloat
    if (sessions.length > 100) {
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      sessions.removeRange(100, sessions.length);
    }
    
    await saveDhikrSessions(sessions);
  }

  static Future<List<DhikrSessionTracker>> getSessionsForDhikr(String dhikrId) async {
    final sessions = await getDhikrSessions();
    return sessions.where((session) => session.dhikrId == dhikrId).toList();
  }

  static Future<List<DhikrSessionTracker>> getRecentSessions({int limit = 10}) async {
    final sessions = await getDhikrSessions();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions.take(limit).toList();
  }

  // User Statistics
  static Future<DhikrUserStats> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userStatsKey);
      if (jsonString == null) return const DhikrUserStats();

      final json = jsonDecode(jsonString);
      return DhikrUserStats.fromJson(json);
    } catch (e) {
      debugPrint('Error loading user stats: $e');
      return const DhikrUserStats();
    }
  }

  static Future<void> saveUserStats(DhikrUserStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatsKey, json.encode(stats.toJson()));
    } catch (e) {
      debugPrint('Error saving user stats: $e');
    }
  }

  static Future<void> updateUserStats({
    int? additionalRecitations,
    bool? sessionCompleted,
    bool? sessionStarted,
    Duration? additionalTime,
    String? dhikrId,
    DhikrCategory? category,
    List<String>? newAchievements,
  }) async {
    final currentStats = await getUserStats();
    
    final updatedDhikrCounts = Map<String, int>.from(currentStats.dhikrCounts);
    if (dhikrId != null && additionalRecitations != null) {
      updatedDhikrCounts[dhikrId] = 
        (updatedDhikrCounts[dhikrId] ?? 0) + additionalRecitations;
    }

    final updatedCategoryStats = Map<DhikrCategory, int>.from(currentStats.categoryStats);
    if (category != null && additionalRecitations != null) {
      updatedCategoryStats[category] = 
        (updatedCategoryStats[category] ?? 0) + additionalRecitations;
    }

    final updatedAchievements = List<String>.from(currentStats.achievements);
    if (newAchievements != null) {
      for (final achievement in newAchievements) {
        if (!updatedAchievements.contains(achievement)) {
          updatedAchievements.add(achievement);
        }
      }
    }

    // Calculate streak
    final now = DateTime.now();
    final lastActivity = currentStats.lastActivity;
    int newCurrentStreak = currentStats.currentStreak;
    int newLongestStreak = currentStats.longestStreak;

    if (lastActivity != null) {
      final daysDifference = now.difference(lastActivity).inDays;
      if (daysDifference == 1) {
        // Consecutive day
        newCurrentStreak++;
      } else if (daysDifference > 1) {
        // Streak broken
        newCurrentStreak = 1;
      }
      // If same day, keep current streak
    } else {
      // First activity
      newCurrentStreak = 1;
    }

    if (newCurrentStreak > newLongestStreak) {
      newLongestStreak = newCurrentStreak;
    }

    final updatedStats = currentStats.copyWith(
      totalDhikrRecited: currentStats.totalDhikrRecited + (additionalRecitations ?? 0),
      totalSessionsCompleted: currentStats.totalSessionsCompleted + 
        (sessionCompleted == true ? 1 : 0),
      totalSessionsStarted: currentStats.totalSessionsStarted + 
        (sessionStarted == true ? 1 : 0),
      totalTimeSpent: Duration(
        milliseconds: currentStats.totalTimeSpent.inMilliseconds + 
          (additionalTime?.inMilliseconds ?? 0),
      ),
      dhikrCounts: updatedDhikrCounts,
      categoryStats: updatedCategoryStats,
      achievements: updatedAchievements,
      lastActivity: DateTime.now(),
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
    );

    await saveUserStats(updatedStats);
  }

  // Settings Management
  static Future<DhikrSettings> getDhikrSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_settingsKey);
      if (jsonString == null) return const DhikrSettings();

      final json = jsonDecode(jsonString);
      return DhikrSettings(
        enableHapticFeedback: json['enableHapticFeedback'] ?? true,
        enableSound: json['enableSound'] ?? false,
        showArabicText: json['showArabicText'] ?? true,
        showTransliteration: json['showTransliteration'] ?? true,
        showTranslation: json['showTranslation'] ?? true,
        fontSize: json['fontSize']?.toDouble() ?? 16.0,
        autoReset: json['autoReset'] ?? false,
        defaultTargetCount: json['defaultTargetCount'] ?? 33,
      );
    } catch (e) {
      debugPrint('Error loading dhikr settings: $e');
      return const DhikrSettings();
    }
  }

  static Future<void> saveDhikrSettings(DhikrSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = {
        'enableHapticFeedback': settings.enableHapticFeedback,
        'enableSound': settings.enableSound,
        'showArabicText': settings.showArabicText,
        'showTransliteration': settings.showTransliteration,
        'showTranslation': settings.showTranslation,
        'fontSize': settings.fontSize,
        'autoReset': settings.autoReset,
        'defaultTargetCount': settings.defaultTargetCount,
      };
      await prefs.setString(_settingsKey, jsonEncode(json));
    } catch (e) {
      debugPrint('Error saving dhikr settings: $e');
    }
  }

  // Data Management Utilities
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_customDhikrKey);
      await prefs.remove(_sessionsKey);
      await prefs.remove(_userStatsKey);
      await prefs.remove(_settingsKey);
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }

  static Future<void> exportData() async {
    try {
      final customDhikrList = await getCustomDhikrList();
      final sessions = await getDhikrSessions();
      final userStats = await getUserStats();
      final settings = await getDhikrSettings();
      
      final data = {
        'customDhikr': customDhikrList.map((dhikr) => dhikr.toJson()).toList(),
        'sessions': sessions.map((session) => session.toJson()).toList(),
        'userStats': userStats.toJson(),
        'settings': {
          'enableHapticFeedback': settings.enableHapticFeedback,
          'enableSound': settings.enableSound,
          'showArabicText': settings.showArabicText,
          'showTransliteration': settings.showTransliteration,
          'showTranslation': settings.showTranslation,
          'fontSize': settings.fontSize,
          'autoReset': settings.autoReset,
          'defaultTargetCount': settings.defaultTargetCount,
        },
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
      
      final jsonString = jsonEncode(data);
      // Implementation depends on your export method (file system, sharing, etc.)
      debugPrint('Export data prepared: ${jsonString.length} characters');
    } catch (e) {
      debugPrint('Error exporting data: $e');
    }
  }

  static Future<bool> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      
      // Validate structure
      if (!data.containsKey('version')) {
        throw Exception('Invalid export format');
      }

      // Import custom dhikr
      if (data['customDhikr'] != null) {
        final customDhikrList = (data['customDhikr'] as List)
            .map((json) => CustomDhikr.fromJson(json))
            .toList();
        await saveCustomDhikrList(customDhikrList);
      }

      // Import sessions
      if (data['sessions'] != null) {
        final sessions = (data['sessions'] as List)
            .map((json) => DhikrSessionTracker.fromJson(json))
            .toList();
        await saveDhikrSessions(sessions);
      }

      // Import user stats
      if (data['userStats'] != null) {
        final userStats = DhikrUserStats.fromJson(data['userStats']);
        await saveUserStats(userStats);
      }

      // Import settings
      if (data['settings'] != null) {
        final settingsJson = data['settings'];
        final settings = DhikrSettings(
          enableHapticFeedback: settingsJson['enableHapticFeedback'] ?? true,
          enableSound: settingsJson['enableSound'] ?? false,
          showArabicText: settingsJson['showArabicText'] ?? true,
          showTransliteration: settingsJson['showTransliteration'] ?? true,
          showTranslation: settingsJson['showTranslation'] ?? true,
          fontSize: settingsJson['fontSize']?.toDouble() ?? 16.0,
          autoReset: settingsJson['autoReset'] ?? false,
          defaultTargetCount: settingsJson['defaultTargetCount'] ?? 33,
        );
        await saveDhikrSettings(settings);
      }

      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  // Statistics Helpers
  static Future<Map<String, dynamic>> getQuickStats() async {
    final stats = await getUserStats();
    final sessions = await getRecentSessions(limit: 7);
    final customDhikr = await getCustomDhikrList();

    return {
      'totalRecitations': stats.totalDhikrRecited,
      'currentStreak': stats.currentStreak,
      'sessionsThisWeek': sessions.length,
      'customDhikrCount': customDhikr.length,
      'mostUsedCategory': _getMostUsedCategory(stats.categoryStats),
      'averageSessionTime': _getAverageSessionTime(sessions),
    };
  }

  static String? _getMostUsedCategory(Map<DhikrCategory, int> categoryStats) {
    if (categoryStats.isEmpty) return null;
    
    final mostUsed = categoryStats.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return mostUsed.key.toString().split('.').last;
  }

  static Duration _getAverageSessionTime(List<DhikrSessionTracker> sessions) {
    if (sessions.isEmpty) return Duration.zero;
    
    final completedSessions = sessions.where((s) => s.endTime != null).toList();
    if (completedSessions.isEmpty) return Duration.zero;

    final totalMilliseconds = completedSessions
        .map((s) => s.endTime!.difference(s.startTime).inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalMilliseconds ~/ completedSessions.length);
  }
}