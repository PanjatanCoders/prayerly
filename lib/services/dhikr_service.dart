// services/dhikr_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dhikr_models.dart';
import 'dhikr_data_service.dart';

/// Service for managing Dhikr counting logic and interactions
class DhikrService {
  
  /// Provide haptic feedback for counting
  static Future<void> provideFeedback({
    bool enableHaptic = true,
    bool enableSound = false,
    bool isComplete = false,
  }) async {
    if (enableHaptic) {
      if (isComplete) {
        // Double vibration for completion
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
      } else {
        // Single light vibration for each count
        await HapticFeedback.lightImpact();
      }
    }

    if (enableSound) {
      // Play system sound
      await SystemSound.play(isComplete 
        ? SystemSoundType.alert 
        : SystemSoundType.click);
    }
  }

  /// Calculate progress percentage
  static double calculateProgress(int current, int target) {
    if (target <= 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }

  /// Check if target is reached
  static bool isTargetReached(int current, int target) {
    return current >= target;
  }

  /// Get progress color based on completion
  static Color getProgressColor(double progress) {
    if (progress >= 1.0) {
      return Colors.green; // Completed
    } else if (progress >= 0.7) {
      return Colors.orange; // Almost done
    } else {
      return Colors.blue; // In progress
    }
  }

  /// Format count display
  static String formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  /// Calculate remaining count
  static int getRemainingCount(int current, int target) {
    final remaining = target - current;
    return remaining > 0 ? remaining : 0;
  }

  /// Get completion message
  static String getCompletionMessage(Dhikr dhikr) {
    return 'Completed ${dhikr.transliteration}! May Allah accept your dhikr.';
  }

  /// Get encouragement message based on progress
  static String getEncouragementMessage(double progress) {
    if (progress >= 0.9) {
      return 'Almost there! Keep going!';
    } else if (progress >= 0.75) {
      return 'Great progress! You\'re doing well.';
    } else if (progress >= 0.5) {
      return 'Halfway there! May Allah bless you.';
    } else if (progress >= 0.25) {
      return 'Good start! Continue with dhikr.';
    } else {
      return 'Begin your dhikr journey!';
    }
  }

  /// Validate custom target count
  static String? validateTargetCount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a target count';
    }
    
    final count = int.tryParse(value);
    if (count == null) {
      return 'Please enter a valid number';
    }
    
    if (count <= 0) {
      return 'Target must be greater than 0';
    }
    
    if (count > 100000) {
      return 'Target too large (max: 100,000)';
    }
    
    return null;
  }

  /// Get default target counts for different categories
  static int getDefaultTargetCount(DhikrCategory category) {
    switch (category) {
      case DhikrCategory.tasbih:
      case DhikrCategory.tahmid:
      case DhikrCategory.takbir:
        return 33;
      case DhikrCategory.tahlil:
      case DhikrCategory.istighfar:
        return 100;
      case DhikrCategory.salawat:
        return 10;
      case DhikrCategory.dua:
        return 7;
      case DhikrCategory.asmaUlHusna:
        return 99;
      case DhikrCategory.custom:
        return 33;
    }
  }

  /// Generate unique session ID
  static String generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Calculate words per minute for dhikr
  static double calculateWordsPerMinute(int count, Duration duration) {
    if (duration.inSeconds == 0) return 0.0;
    return count / (duration.inMinutes > 0 ? duration.inMinutes : 1);
  }

  /// Get time-based recommendations
  static List<Dhikr> getTimeBasedRecommendations() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      // Morning dhikr
      return [
        DhikrDataService.getAllDhikr().firstWhere((d) => d.id == 'subhan_allah'),
        DhikrDataService.getAllDhikr().firstWhere((d) => d.id == 'alhamdulillah'),
        DhikrDataService.getAllDhikr().firstWhere((d) => d.id == 'allahu_akbar'),
      ];
    } else if (hour >= 12 && hour < 18) {
      // Afternoon dhikr
      return [
        DhikrDataService.getAllDhikr().firstWhere((d) => d.id == 'astaghfirullah'),
        DhikrDataService.getAllDhikr().firstWhere((d) => d.id == 'la_ilaha_illa_allah'),
      ];
    } else {
      // Evening dhikr
      return [
        DhikrDataService.getAllDhikr().firstWhere((d) => d.id == 'subhan_allah_wabihamdihi'),
        DhikrDataService.getAllDhikr().firstWhere((d) => d.id == 'la_hawla_wala_quwwata'),
      ];
    }
  }

  /// Get dhikr benefits/virtues text
  static String getDhikrBenefits(DhikrCategory category) {
    switch (category) {
      case DhikrCategory.tasbih:
        return 'Tasbih purifies the heart and increases spiritual light. The Prophet (PBUH) said it is beloved to Allah.';
      case DhikrCategory.tahmid:
        return 'Praising Allah fills the scales of good deeds. It is a means of gratitude for Allah\'s countless blessings.';
      case DhikrCategory.takbir:
        return 'Saying Allahu Akbar reminds us of Allah\'s supremacy and helps overcome difficulties.';
      case DhikrCategory.tahlil:
        return 'La ilaha illa Allah is the best dhikr. It renews faith and erases sins.';
      case DhikrCategory.istighfar:
        return 'Seeking forgiveness opens doors of mercy and removes anxiety from the heart.';
      case DhikrCategory.salawat:
        return 'Sending blessings upon the Prophet brings Allah\'s blessings upon you tenfold.';
      case DhikrCategory.dua:
        return 'Dua is the essence of worship. It strengthens the connection between servant and Creator.';
      case DhikrCategory.asmaUlHusna:
        return 'Reciting Allah\'s beautiful names brings one closer to Allah and increases spiritual knowledge.';
      case DhikrCategory.custom:
        return 'All sincere dhikr purifies the heart and brings peace to the soul.';
    }
  }

  /// Get completion celebration text
  static String getCompletionCelebration(int count, DhikrCategory category) {
    final messages = [
      'Alhamdulillah! You completed $count dhikr.',
      'SubhanAllah! ${formatCount(count)} dhikr finished.',
      'May Allah accept your $count dhikr.',
      'Barakallahu feeki! $count dhikr completed.',
      'Allahu Akbar! You finished ${formatCount(count)} dhikr.',
    ];
    
    return messages[count % messages.length];
  }

  /// Convert 12-hour to 24-hour format helper
  static String formatTime12Hour(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '$displayHour:$minute $period';
  }
}
