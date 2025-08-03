// services/qaza_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QazaService {
  static const String _qazaDataKey = 'qaza_namaz_data';
  static const String _qazaHistoryKey = 'qaza_history';
  static const String _qazaSettingsKey = 'qaza_settings';

  // Hanafi prayer types that require Qaza
  static const List<String> prayerTypes = [
    'Fajr',
    'Zuhr', 
    'Asr',
    'Maghrib',
    'Isha',
    'Witr'
  ];

  /// Get current Qaza counts
  static Future<Map<String, int>> getQazaCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? qazaDataStr = prefs.getString(_qazaDataKey);
      
      if (qazaDataStr == null) {
        return _getDefaultQazaCounts();
      }
      
      final Map<String, dynamic> qazaData = json.decode(qazaDataStr);
      final Map<String, int> qazaCounts = {};
      
      for (String prayer in prayerTypes) {
        qazaCounts[prayer] = qazaData[prayer] ?? 0;
      }
      
      return qazaCounts;
    } catch (e) {
      print('Error getting Qaza counts: $e');
      return _getDefaultQazaCounts();
    }
  }

  /// Set Qaza counts
  static Future<void> setQazaCounts(Map<String, int> counts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_qazaDataKey, json.encode(counts));
    } catch (e) {
      print('Error setting Qaza counts: $e');
    }
  }

  /// Add Qaza prayers (when missed)
  static Future<void> addQazaPrayers(Map<String, int> addCounts) async {
    final currentCounts = await getQazaCounts();
    
    for (String prayer in prayerTypes) {
      if (addCounts.containsKey(prayer)) {
        currentCounts[prayer] = (currentCounts[prayer] ?? 0) + (addCounts[prayer] ?? 0);
      }
    }
    
    await setQazaCounts(currentCounts);
    await _logQazaHistory('added', addCounts);
  }

  /// Complete Qaza prayers (when performed)
  static Future<void> completeQazaPrayers(Map<String, int> completeCounts) async {
    final currentCounts = await getQazaCounts();
    
    for (String prayer in prayerTypes) {
      if (completeCounts.containsKey(prayer)) {
        final completed = completeCounts[prayer] ?? 0;
        currentCounts[prayer] = ((currentCounts[prayer] ?? 0) - completed).clamp(0, double.infinity).toInt();
      }
    }
    
    await setQazaCounts(currentCounts);
    await _logQazaHistory('completed', completeCounts);
  }

  /// Calculate total Qaza prayers
  // static Future<int> getTotalQazaCount() async {
  //   final counts = await getQazaCounts();
  //   return counts.values.fold(0, (sum, count) => sum + count);
  // }
  static Future<int> getTotalQazaCount() async {
  final history = await getQazaHistory();
  int total = 0;
  for (final entry in history) {
    if (entry.action == 'added') {
      total += entry.counts.values.fold(0, (sum, v) => sum + v);
    }
  }
  return total;
}


  /// Get completion percentage
  static Future<double> getCompletionPercentage() async {
    final history = await getQazaHistory();
    int totalAdded = 0;
    int totalCompleted = 0;
    
    for (QazaHistoryEntry entry in history) {
      if (entry.action == 'added') {
        totalAdded += entry.counts.values.fold(0, (sum, count) => sum + count);
      } else if (entry.action == 'completed') {
        totalCompleted += entry.counts.values.fold(0, (sum, count) => sum + count);
      }
    }
    
    if (totalAdded == 0) return 0.0;
    return (totalCompleted / totalAdded * 100).clamp(0.0, 100.0);
  }

  /// Get Qaza history
  static Future<List<QazaHistoryEntry>> getQazaHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyStr = prefs.getString(_qazaHistoryKey);
      
      if (historyStr == null) return [];
      
      final List<dynamic> historyList = json.decode(historyStr);
      return historyList.map((item) => QazaHistoryEntry.fromJson(item)).toList();
    } catch (e) {
      print('Error getting Qaza history: $e');
      return [];
    }
  }

  /// Log Qaza history entry
  static Future<void> _logQazaHistory(String action, Map<String, int> counts) async {
    try {
      final history = await getQazaHistory();
      final entry = QazaHistoryEntry(
        action: action,
        counts: counts,
        timestamp: DateTime.now(),
      );
      
      history.add(entry);
      
      // Keep only last 100 entries
      if (history.length > 100) {
        history.removeRange(0, history.length - 100);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final historyJson = history.map((e) => e.toJson()).toList();
      await prefs.setString(_qazaHistoryKey, json.encode(historyJson));
    } catch (e) {
      print('Error logging Qaza history: $e');
    }
  }

  /// Get streak information
  static Future<QazaStreak> getStreak() async {
    final history = await getQazaHistory();
    if (history.isEmpty) return QazaStreak(current: 0, longest: 0, lastCompletionDate: null);
    
    // Sort by timestamp (most recent first)
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastCompletionDate;
    DateTime? lastDate;
    
    for (QazaHistoryEntry entry in history.reversed) {
      if (entry.action == 'completed') {
        final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
        
        if (lastDate == null || entryDate.difference(lastDate).inDays <= 1) {
          tempStreak++;
          if (lastCompletionDate == null) lastCompletionDate = entry.timestamp;
        } else {
          longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
          tempStreak = 1;
        }
        
        lastDate = entryDate;
      }
    }
    
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
    
    // Check if current streak is still active (completed something today or yesterday)
    if (lastDate != null) {
      final daysSinceLastCompletion = DateTime.now().difference(lastDate).inDays;
      currentStreak = daysSinceLastCompletion <= 1 ? tempStreak : 0;
    }
    
    return QazaStreak(
      current: currentStreak,
      longest: longestStreak,
      lastCompletionDate: lastCompletionDate,
    );
  }

  /// Get Qaza settings
  static Future<QazaSettings> getQazaSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? settingsStr = prefs.getString(_qazaSettingsKey);
      
      if (settingsStr == null) {
        return QazaSettings.defaultSettings();
      }
      
      final Map<String, dynamic> settingsData = json.decode(settingsStr);
      return QazaSettings.fromJson(settingsData);
    } catch (e) {
      print('Error getting Qaza settings: $e');
      return QazaSettings.defaultSettings();
    }
  }

  /// Save Qaza settings
  static Future<void> saveQazaSettings(QazaSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_qazaSettingsKey, json.encode(settings.toJson()));
    } catch (e) {
      print('Error saving Qaza settings: $e');
    }
  }

  /// Calculate estimated completion time
  static Future<Duration> getEstimatedCompletionTime() async {
    final totalQaza = await getTotalQazaCount();
    final settings = await getQazaSettings();
    
    if (totalQaza == 0 || settings.dailyTarget == 0) {
      return Duration.zero;
    }
    
    final daysNeeded = (totalQaza / settings.dailyTarget).ceil();
    return Duration(days: daysNeeded);
  }

  /// Get motivational message based on progress
  static Future<String> getMotivationalMessage() async {
    final totalQaza = await getTotalQazaCount();
    final percentage = await getCompletionPercentage();
    final streak = await getStreak();
    
    if (totalQaza == 0) {
      return "Alhamdulillah! No pending Qaza prayers. Keep up your regular prayers! 🤲";
    }
    
    if (percentage >= 80) {
      return "Excellent progress! You're almost there. May Allah make it easy for you! ✨";
    } else if (percentage >= 50) {
      return "Halfway there! Your dedication is admirable. Keep going! 💪";
    } else if (streak.current >= 7) {
      return "Amazing streak of ${streak.current} days! Allah sees your efforts! 🌟";
    } else if (streak.current >= 3) {
      return "Great consistency! ${streak.current} days strong. May Allah bless your efforts! 🌙";
    } else {
      return "Every prayer counts! Start today and make it a habit. Allah is Most Merciful! 💚";
    }
  }

  /// Helper method for default counts
  static Map<String, int> _getDefaultQazaCounts() {
    return {
      for (String prayer in prayerTypes) prayer: 0
    };
  }

  /// Clear all Qaza data (for testing or reset)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_qazaDataKey);
      await prefs.remove(_qazaHistoryKey);
      await prefs.remove(_qazaSettingsKey);
    } catch (e) {
      print('Error clearing Qaza data: $e');
    }
  }

  /// Export data for backup
  static Future<String> exportData() async {
    final counts = await getQazaCounts();
    final history = await getQazaHistory();
    final settings = await getQazaSettings();
    
    final exportData = {
      'counts': counts,
      'history': history.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
    };
    
    return json.encode(exportData);
  }

  /// Import data from backup
  static Future<bool> importData(String jsonData) async {
    try {
      final importData = json.decode(jsonData);
      
      // Validate data structure
      if (!importData.containsKey('counts') || 
          !importData.containsKey('history') || 
          !importData.containsKey('settings')) {
        return false;
      }
      
      // Import counts
      final Map<String, int> counts = {};
      for (String prayer in prayerTypes) {
        counts[prayer] = importData['counts'][prayer] ?? 0;
      }
      await setQazaCounts(counts);
      
      // Import history
      final List<QazaHistoryEntry> history = [];
      for (var item in importData['history']) {
        history.add(QazaHistoryEntry.fromJson(item));
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_qazaHistoryKey, json.encode(history.map((e) => e.toJson()).toList()));
      
      // Import settings
      final settings = QazaSettings.fromJson(importData['settings']);
      await saveQazaSettings(settings);
      
      return true;
    } catch (e) {
      print('Error importing Qaza data: $e');
      return false;
    }
  }
}

/// Data models
class QazaHistoryEntry {
  final String action; // 'added' or 'completed'
  final Map<String, int> counts;
  final DateTime timestamp;
  
  QazaHistoryEntry({
    required this.action,
    required this.counts,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'action': action,
    'counts': counts,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory QazaHistoryEntry.fromJson(Map<String, dynamic> json) => QazaHistoryEntry(
    action: json['action'],
    counts: Map<String, int>.from(json['counts']),
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class QazaStreak {
  final int current;
  final int longest;
  final DateTime? lastCompletionDate;
  
  QazaStreak({
    required this.current,
    required this.longest,
    this.lastCompletionDate,
  });
}

class QazaSettings {
  final int dailyTarget;
  final bool enableReminders;
  final List<int> reminderTimes; // Hours of day (0-23)
  final bool showMotivationalMessages;
  final String preferredCalculationMethod;
  
  QazaSettings({
    required this.dailyTarget,
    required this.enableReminders,
    required this.reminderTimes,
    required this.showMotivationalMessages,
    required this.preferredCalculationMethod,
  });
  
  factory QazaSettings.defaultSettings() => QazaSettings(
    dailyTarget: 5,
    enableReminders: true,
    reminderTimes: [9, 15, 21], // 9 AM, 3 PM, 9 PM
    showMotivationalMessages: true,
    preferredCalculationMethod: 'hanafi',
  );
  
  Map<String, dynamic> toJson() => {
    'dailyTarget': dailyTarget,
    'enableReminders': enableReminders,
    'reminderTimes': reminderTimes,
    'showMotivationalMessages': showMotivationalMessages,
    'preferredCalculationMethod': preferredCalculationMethod,
  };
  
  factory QazaSettings.fromJson(Map<String, dynamic> json) => QazaSettings(
    dailyTarget: json['dailyTarget'] ?? 5,
    enableReminders: json['enableReminders'] ?? true,
    reminderTimes: List<int>.from(json['reminderTimes'] ?? [9, 15, 21]),
    showMotivationalMessages: json['showMotivationalMessages'] ?? true,
    preferredCalculationMethod: json['preferredCalculationMethod'] ?? 'hanafi',
  );
  
  QazaSettings copyWith({
    int? dailyTarget,
    bool? enableReminders,
    List<int>? reminderTimes,
    bool? showMotivationalMessages,
    String? preferredCalculationMethod,
  }) {
    return QazaSettings(
      dailyTarget: dailyTarget ?? this.dailyTarget,
      enableReminders: enableReminders ?? this.enableReminders,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      showMotivationalMessages: showMotivationalMessages ?? this.showMotivationalMessages,
      preferredCalculationMethod: preferredCalculationMethod ?? this.preferredCalculationMethod,
    );
  }
}