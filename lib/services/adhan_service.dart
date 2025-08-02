// services/adhan_service.dart (Updated + Restored)
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

  static const Map<String, bool> _defaultSettings = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  static const Map<String, String> adhanTypes = {
    'azan1': 'Makkah',
    'azan2': 'Madinah',
    'azan3': 'Egypt',
    'azan4': 'Turkey',
    'azan_fajr1': 'Fajr Special',
  };

  static Future<void> initialize() async {
    await _setupAudioPlayer();
    await _initializeNotifications();
  }

  static Future<void> _setupAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      final volume = await getAdhanVolume();
      await _audioPlayer.setVolume(volume);
      _audioPlayer.onPlayerComplete.listen((_) {
        _dismissPlayingNotification();
      });
    } catch (e) {
      debugPrint('Error setting up audio player: $e');
    }
  }

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
          playSound: false,
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
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'adhan_group',
          channelGroupName: 'Adhan',
        ),
      ],
    );
  }

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

  static Future<void> updateNotificationSetting(
    String prayer,
    bool enabled,
  ) async {
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

  static Future<double> getAdhanVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_volumeSettingsKey) ?? 0.8;
    } catch (e) {
      return 0.8;
    }
  }

  static Future<void> setAdhanVolume(double volume) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_volumeSettingsKey, volume.clamp(0.0, 1.0));
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  static Future<String> getSelectedAdhanType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_adhanTypeKey) ?? 'azan1';
    } catch (e) {
      return 'azan1';
    }
  }

  static Future<void> setSelectedAdhanType(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_adhanTypeKey, type);
    } catch (e) {
      debugPrint('Error setting adhan type: $e');
    }
  }

  static Future<void> playAdhan(String prayerName) async {
    try {
      await stopAdhan();
      final adhanFile = await _getAdhanFile(prayerName);
      final volume = await getAdhanVolume();
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(AssetSource(adhanFile));
      await _showPlayingNotification(prayerName);
    } catch (e) {
      debugPrint('Error playing adhan: $e');
      await _showPlayingNotification(prayerName);
    }
  }

  static Future<String> _getAdhanFile(String prayerName) async {
    final adhanType = await getSelectedAdhanType();
    if (prayerName == 'Fajr' && adhanType == 'azan_fajr1') {
      return 'audio/adhan/azan_fajr1.mp3';
    }
    return 'audio/adhan/$adhanType.mp3';
  }

  static Future<void> stopAdhan() async {
    try {
      await _audioPlayer.stop();
      await _dismissPlayingNotification();
    } catch (e) {
      debugPrint('Error stopping adhan: $e');
    }
  }

  static Future<void> testAdhan() async {
    try {
      await stopAdhan();
      final adhanType = await getSelectedAdhanType();
      final testFile = adhanType == 'azan_fajr1'
          ? 'audio/adhan/azan_fajr1.mp3'
          : 'audio/adhan/$adhanType.mp3';
      await _audioPlayer.play(AssetSource(testFile));
      Future.delayed(const Duration(seconds: 10), () {
        stopAdhan();
      });
    } catch (e) {
      debugPrint('Error testing adhan: $e');
    }
  }

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
          payload: {'prayer': prayerName, 'action': 'control_adhan'},
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

  static Future<void> _dismissPlayingNotification() async {
    try {
      await AwesomeNotifications().cancel(2000);
    } catch (e) {
      debugPrint('Error dismissing playing notification: $e');
    }
  }

  static Future<void> onNotificationTap(ReceivedAction receivedAction) async {
    try {
      final payload = receivedAction.payload;
      final action = payload?['action'];
      final prayer = payload?['prayer'];
      final buttonKey = receivedAction.buttonKeyPressed;

      debugPrint(
        'Notification action - Key: $buttonKey, Action: $action, Prayer: $prayer',
      );

      switch (buttonKey) {
        case 'play_adhan':
          if (prayer != null) await playAdhan(prayer);
          break;
        case 'stop_adhan':
          await stopAdhan();
          break;
        case 'pause_adhan':
          await _audioPlayer.pause();
          break;
        case 'dismiss':
          break;
        default:
          if (action == 'play_adhan' && prayer != null) {
            await playAdhan(prayer);
          }
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification action: $e');
    }
  }

  static Future<void> scheduleAdhanNotifications(
    Map<String, DateTime> prayerTimes,
    Map<String, bool> notificationSettings,
  ) async {
    try {
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        'adhan_channel',
      );
      final now = DateTime.now();

      for (final entry in prayerTimes.entries) {
        final name = entry.key;
        final time = entry.value;
        if (name == 'Sunrise' || !(notificationSettings[name] ?? false))
          continue;
        DateTime scheduleTime = time.isBefore(now)
            ? time.add(const Duration(days: 1))
            : time;
        await _scheduleAdhanNotification(name, scheduleTime);
      }
      debugPrint('Adhan notifications scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling adhan notifications: $e');
    }
  }

  static Future<void> _scheduleAdhanNotification(
    String prayer,
    DateTime time,
  ) async {
    try {
      final id = _getNotificationId(prayer);
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'adhan_channel',
          title: '🕌 $prayer Prayer Time',
          body: 'It\'s time for $prayer prayer. Tap to play Adhan.',
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          category: NotificationCategory.Alarm,
          notificationLayout: NotificationLayout.BigText,
          largeIcon: 'resource://drawable/ic_mosque',
          payload: {
            'prayer': prayer,
            'action': 'play_adhan',
            'time': time.millisecondsSinceEpoch.toString(),
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
        schedule: NotificationCalendar.fromDate(date: time),
      );
    } catch (e) {
      debugPrint('Error scheduling $prayer notification: $e');
    }
  }

  static int _getNotificationId(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return 1001;
      case 'Dhuhr':
        return 1002;
      case 'Asr':
        return 1003;
      case 'Maghrib':
        return 1004;
      case 'Isha':
        return 1005;
      default:
        return 1000;
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        'adhan_channel',
      );
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        'adhan_playing_channel',
      );
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }

  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }
}
