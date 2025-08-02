// services/adhan_service.dart (Enhanced version)
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:convert';

class AdhanService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _notificationSettingsKey = 'prayer_notification_settings';
  static const String _volumeSettingsKey = 'adhan_volume_settings';
  static const String _adhanTypeKey = 'selected_adhan_type';
  
  // Default notification settings
  static const Map<String, bool> _defaultSettings = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  // Available adhan types
  static const Map<String, String> adhanTypes = {
    'makkah': 'Makkah',
    'madinah': 'Madinah', 
    'egypt': 'Egypt',
    'turkey': 'Turkey',
  };

  /// Initialize the AdhanService
  static Future<void> initialize() async {
    await _setupAudioPlayer();
    await _initializeNotifications();
  }

  /// Setup audio player with proper configuration
  static Future<void> _setupAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      
      // Set initial volume
      final volume = await getAdhanVolume();
      await _audioPlayer.setVolume(volume);
      
      // Listen for completion to auto-dismiss playing notification
      _audioPlayer.onPlayerComplete.listen((_) {
        _dismissPlayingNotification();
      });
      
    } catch (e) {
      debugPrint('Error setting up audio player: $e');
    }
  }

  /// Initialize notifications with proper channels
  static Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'adhan_group',
          channelKey: 'adhan_channel',
          channelName: 'Adhan Notifications',
          channelDescription: 'Prayer time adhan notifications',
          defaultColor: Colors.amber,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: false, // We handle sound manually
          enableVibration: true,
          enableLights: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'adhan_group',
          channelKey: 'adhan_playing_channel',
          channelName: 'Adhan Playing',
          channelDescription: 'Currently playing adhan controls',
          defaultColor: Colors.green,
          importance: NotificationImportance.High,
          channelShowBadge: false,
          playSound: false,
          enableVibration: false,
          onlyAlertOnce: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'adhan_group',
          channelGroupName: 'Adhan',
        )
      ],
    );
  }

  /// Get notification settings from SharedPreferences
  static Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_notificationSettingsKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> decoded = json.decode(settingsJson);
        return decoded.map((key, value) => MapEntry(key, value as bool));
      }
      
      return Map.from(_defaultSettings);
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      return Map.from(_defaultSettings);
    }
  }

  /// Update notification setting for specific prayer
  static Future<void> updateNotificationSetting(String prayer, bool enabled) async {
    try {
      final settings = await getNotificationSettings();
      settings[prayer] = enabled;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationSettingsKey, json.encode(settings));
      
      debugPrint('Updated $prayer notification: $enabled');
    } catch (e) {
      debugPrint('Error updating notification setting: $e');
    }
  }

  /// Get adhan volume (0.0 to 1.0)
  static Future<double> getAdhanVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_volumeSettingsKey) ?? 0.8; // Default 80%
    } catch (e) {
      return 0.8;
    }
  }

  /// Set adhan volume
  static Future<void> setAdhanVolume(double volume) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_volumeSettingsKey, volume.clamp(0.0, 1.0));
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// Get selected adhan type
  static Future<String> getSelectedAdhanType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_adhanTypeKey) ?? 'makkah';
    } catch (e) {
      return 'makkah';
    }
  }

  /// Set selected adhan type
  static Future<void> setSelectedAdhanType(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_adhanTypeKey, type);
    } catch (e) {
      debugPrint('Error setting adhan type: $e');
    }
  }

  /// Schedule adhan notifications for enabled prayers
  static Future<void> scheduleAdhanNotifications(
    Map<String, DateTime> prayerTimes,
    Map<String, bool> notificationSettings,
  ) async {
    try {
      // Cancel all existing adhan notifications
      await AwesomeNotifications().cancelNotificationsByChannelKey('adhan_channel');
      
      final now = DateTime.now();
      
      for (final entry in prayerTimes.entries) {
        final prayerName = entry.key;
        final prayerTime = entry.value;
        
        // Skip Sunrise and disabled prayers
        if (prayerName == 'Sunrise' || !(notificationSettings[prayerName] ?? false)) {
          continue;
        }
        
        // Only schedule future prayers (including next day)
        DateTime scheduleTime = prayerTime;
        if (prayerTime.isBefore(now)) {
          scheduleTime = prayerTime.add(const Duration(days: 1));
        }
        
        await _scheduleAdhanNotification(prayerName, scheduleTime);
      }
      
      debugPrint('Adhan notifications scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling adhan notifications: $e');
    }
  }

  /// Schedule individual adhan notification
  static Future<void> _scheduleAdhanNotification(String prayerName, DateTime prayerTime) async {
    try {
      final notificationId = _getNotificationId(prayerName);
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'adhan_channel',
          title: '🕌 $prayerName Prayer Time',
          body: 'It\'s time for $prayerName prayer. Tap to play Adhan.',
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          category: NotificationCategory.Alarm,
          notificationLayout: NotificationLayout.BigText,
          largeIcon: 'resource://drawable/ic_mosque', // Add mosque icon
          payload: {
            'prayer': prayerName,
            'action': 'play_adhan',
            'time': prayerTime.millisecondsSinceEpoch.toString(),
          },
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'play_adhan',
            label: 'Play Adhan',
            color: Colors.green,
            actionType: ActionType.SilentAction,
          ),
          NotificationActionButton(
            key: 'dismiss',
            label: 'Dismiss',
            actionType: ActionType.DismissAction,
          ),
        ],
        schedule: NotificationCalendar.fromDate(date: prayerTime),
      );
      
      debugPrint('Scheduled $prayerName adhan for ${prayerTime.toString()}');
    } catch (e) {
      debugPrint('Error scheduling $prayerName notification: $e');
    }
  }

  /// Get notification ID for prayer
  static int _getNotificationId(String prayerName) {
    switch (prayerName) {
      case 'Fajr': return 1001;
      case 'Dhuhr': return 1002;
      case 'Asr': return 1003;
      case 'Maghrib': return 1004;
      case 'Isha': return 1005;
      default: return 1000;
    }
  }

  /// Play adhan audio
  static Future<void> playAdhan(String prayerName) async {
    try {
      // Stop any currently playing audio
      await stopAdhan();
      
      // Get the appropriate adhan file
      final adhanFile = await _getAdhanFile(prayerName);
      
      debugPrint('Playing adhan for $prayerName: $adhanFile');
      
      // Set volume before playing
      final volume = await getAdhanVolume();
      await _audioPlayer.setVolume(volume);
      
      // Play the adhan
      await _audioPlayer.play(AssetSource(adhanFile));
      
      // Show playing notification with controls
      await _showPlayingNotification(prayerName);
      
    } catch (e) {
      debugPrint('Error playing adhan: $e');
      // Fallback: just show notification without audio
      await _showPlayingNotification(prayerName);
    }
  }

  /// Stop adhan audio
  static Future<void> stopAdhan() async {
    try {
      await _audioPlayer.stop();
      await _dismissPlayingNotification();
    } catch (e) {
      debugPrint('Error stopping adhan: $e');
    }
  }

  /// Pause adhan audio
  static Future<void> pauseAdhan() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing adhan: $e');
    }
  }

  /// Resume adhan audio
  static Future<void> resumeAdhan() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Error resuming adhan: $e');
    }
  }

  /// Get appropriate adhan file for prayer
  static Future<String> _getAdhanFile(String prayerName) async {
    final adhanType = await getSelectedAdhanType();
    
    // Special case for Fajr if different adhan exists
    if (prayerName == 'Fajr') {
      return 'audio/adhan_fajr_$adhanType.mp3';
    }
    
    return 'audio/adhan_$adhanType.mp3';
  }

  /// Show notification while adhan is playing
  static Future<void> _showPlayingNotification(String prayerName) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2000,
          channelKey: 'adhan_playing_channel',
          title: '🎵 $prayerName Adhan Playing',
          body: 'Use controls below to manage playback',
          wakeUpScreen: false,
          category: NotificationCategory.Status,
          notificationLayout: NotificationLayout.MediaPlayer,
          backgroundColor: Colors.green,
          payload: {
            'prayer': prayerName,
            'action': 'control_adhan',
          },
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'pause_adhan',
            label: 'Pause',
            actionType: ActionType.SilentAction,
          ),
          NotificationActionButton(
            key: 'stop_adhan',
            label: 'Stop',
            actionType: ActionType.SilentAction,
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error showing playing notification: $e');
    }
  }

  /// Dismiss playing notification
  static Future<void> _dismissPlayingNotification() async {
    try {
      await AwesomeNotifications().cancel(2000);
    } catch (e) {
      debugPrint('Error dismissing playing notification: $e');
    }
  }

  /// Handle notification tap and actions
  static Future<void> onNotificationTap(ReceivedAction receivedAction) async {
    try {
      final payload = receivedAction.payload;
      final action = payload?['action'];
      final prayer = payload?['prayer'];
      final buttonKey = receivedAction.buttonKeyPressed;
      
      debugPrint('Notification action - Key: $buttonKey, Action: $action, Prayer: $prayer');
      
      // Handle button presses
      switch (buttonKey) {
        case 'play_adhan':
          if (prayer != null) {
            await playAdhan(prayer);
          }
          break;
        case 'stop_adhan':
          await stopAdhan();
          break;
        case 'pause_adhan':
          await pauseAdhan();
          break;
        case 'dismiss':
          // Just dismiss, no action needed
          break;
        default:
          // Handle notification tap (no button)
          if (action == 'play_adhan' && prayer != null) {
            await playAdhan(prayer);
          }
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification action: $e');
    }
  }

  /// Get current playing status
  static Future<bool> isPlaying() async {
    try {
      return _audioPlayer.state == PlayerState.playing;
    } catch (e) {
      return false;
    }
  }

  /// Get current position
  static Future<Duration> getCurrentPosition() async {
    try {
      return await _audioPlayer.getCurrentPosition() ?? Duration.zero;
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Get duration
  static Future<Duration> getDuration() async {
    try {
      return await _audioPlayer.getDuration() ?? Duration.zero;
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Test adhan playback (for settings)
  static Future<void> testAdhan() async {
    try {
      await stopAdhan();
      final adhanFile = await _getAdhanFile('Test');
      await _audioPlayer.play(AssetSource(adhanFile));
      
      // Auto-stop after 10 seconds for testing
      Future.delayed(const Duration(seconds: 10), () {
        stopAdhan();
      });
    } catch (e) {
      debugPrint('Error testing adhan: $e');
    }
  }

  /// Cancel all adhan notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelNotificationsByChannelKey('adhan_channel');
      await AwesomeNotifications().cancelNotificationsByChannelKey('adhan_playing_channel');
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }
}