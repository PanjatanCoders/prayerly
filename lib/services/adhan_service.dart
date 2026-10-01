// services/adhan_service.dart (Updated with Auto-Play)
// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:convert';

class AdhanService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _notificationSettingsKey = 'prayer_notification_settings';
  static const String _volumeSettingsKey = 'adhan_volume_settings';
  static const String _adhanTypeKey = 'selected_adhan_type';
  static const String _autoPlayKey = 'auto_play_adhan';

  static const Map<String, bool> _defaultSettings = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  static const Map<String, String> adhanTypes = {
    'azan1': 'Azan1',
    'azan2': 'Azan2',
    'azan3': 'Azan3',
    'azan4': 'Azan4',
    'azan_fajr1': 'Fajr Azan',
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
          playSound: false, // We handle audio ourselves
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

  static Future<bool> getAutoPlayEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoPlayKey) ?? true; // Default to true
    } catch (e) {
      return true;
    }
  }

  static Future<void> setAutoPlayEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoPlayKey, enabled);
    } catch (e) {
      debugPrint('Error setting auto play: $e');
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
      debugPrint('Playing adhan for $prayerName prayer');
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

  /// Auto-plays the adhan when its notification actually appears on screen.
  ///
  /// Must be a bare static tear-off passed to `setListeners`, not a closure:
  /// `PluginUtilities.getCallbackHandle` (which awesome_notifications uses to
  /// resurrect this callback in a background isolate when Android has killed
  /// the app - the normal case by prayer time) can only resolve a handle for
  /// a static/top-level function. A closure silently resolves to a null
  /// handle, so the callback only ever fires if the app process happens to
  /// still be alive - which looked like "auto-play works sometimes" before
  /// this was pulled out of the inline closure in main.dart.
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayed(
    ReceivedNotification notification,
  ) async {
    final payload = notification.payload;
    if (payload != null && payload['action'] == 'play_adhan') {
      final prayer = payload['prayer'];
      final autoPlay = await getAutoPlayEnabled();
      if (autoPlay && prayer != null) {
        await playAdhan(prayer);
      }
    }
  }

  /// Fires the adhan from a plain AlarmManager alarm, independent of whether
  /// the Flutter engine/Dart VM is already running.
  ///
  /// [onNotificationDisplayed] above only runs if the app process is still
  /// alive - awesome_notifications has no background-isolate resurrection
  /// path for "notification displayed", only for [onNotificationTap]'s
  /// action-received event. By actual prayer time Android has normally
  /// killed the process, so that hook was never even attempted and the adhan
  /// silently didn't play. `android_alarm_manager_plus` exists specifically
  /// to run Dart code at an exact time with its own background isolate
  /// (plugins registered), the same mechanism alarm-clock apps use, so this
  /// alarm - scheduled alongside each notification in
  /// `_scheduleAdhanNotification` - is what actually triggers playback now.
  @pragma('vm:entry-point')
  static Future<void> onAlarmFired(int id, Map<String, dynamic> params) async {
    final prayer = params['prayer'] as String?;
    if (prayer == null) return;
    // This runs in android_alarm_manager_plus's own background isolate,
    // which never ran this app's main() - _audioPlayer and the notification
    // channels haven't been set up in *this* isolate yet, even though they
    // were in the foreground one.
    await initialize();
    final autoPlay = await getAutoPlayEnabled();
    if (autoPlay) {
      await playAdhan(prayer);
    }
  }

  // This method is called when notifications are created OR when user interacts with them
  @pragma('vm:entry-point')
  static Future<void> onNotificationTap(ReceivedAction receivedAction) async {
    try {
      final payload = receivedAction.payload;
      final action = payload?['action'];
      final prayer = payload?['prayer'];
      final buttonKey = receivedAction.buttonKeyPressed;

      debugPrint(
        'Notification action - Key: $buttonKey, Action: $action, Prayer: $prayer',
      );

      // Handle button presses
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
          // This handles the case when notification is created (no button pressed)
          // or when the notification itself is tapped
          if (action == 'play_adhan' && prayer != null) {
            final autoPlay = await getAutoPlayEnabled();
            if (autoPlay || buttonKey == null) {
              // Auto play if enabled, or if user tapped the notification
              await playAdhan(prayer);
            }
          }
          break;
      }
    } catch (e) {
      debugPrint('Error handling notification action: $e');
    }
  }

  /// Schedules adhan notifications from [prayerTimesByDay] (today first, then
  /// each following day).
  ///
  /// There's no background task (workmanager/alarm-manager) in this app to
  /// recompute and reschedule daily, so scheduling only "today" meant every
  /// notification silently stopped existing the day after, until the user
  /// happened to reopen the app. Scheduling about a week ahead means the
  /// adhan keeps firing for roughly that long even if the app stays closed.
  static Future<void> scheduleAdhanNotifications(
    List<Map<String, DateTime>> prayerTimesByDay,
    Map<String, bool> notificationSettings,
  ) async {
    try {
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        'adhan_channel',
      );
      await _cancelAllAlarms();
      final now = DateTime.now();

      for (var dayOffset = 0; dayOffset < prayerTimesByDay.length; dayOffset++) {
        for (final entry in prayerTimesByDay[dayOffset].entries) {
          final name = entry.key;
          final time = entry.value;
          if (name == 'Sunrise' || !(notificationSettings[name] ?? false)) {
            continue;
          }
          // Only relevant for dayOffset 0: every later day is entirely in
          // the future already.
          if (time.isBefore(now)) continue;
          await _scheduleAdhanNotification(name, time, dayOffset);
        }
      }
      debugPrint(
        'Adhan notifications scheduled successfully for ${prayerTimesByDay.length} day(s)',
      );
    } catch (e) {
      debugPrint('Error scheduling adhan notifications: $e');
    }
  }

  static Future<void> _scheduleAdhanNotification(
    String prayer,
    DateTime time,
    int dayOffset,
  ) async {
    try {
      // Offset by day so a week of the same prayer gets distinct ids instead
      // of each day's schedule call overwriting the previous day's.
      final id = _getNotificationId(prayer) + dayOffset * 10;
      final autoPlay = await getAutoPlayEnabled();
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'adhan_channel',
          title: '🕌 $prayer Prayer Time',
          body: autoPlay 
              ? 'It\'s time for $prayer prayer. Adhan will play automatically.'
              : 'It\'s time for $prayer prayer. Tap to play Adhan.',
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
        schedule: NotificationCalendar.fromDate(
          date: time,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      // The actual auto-play trigger - see the doc comment on [onAlarmFired].
      await AndroidAlarmManager.oneShotAt(
        time,
        id,
        onAlarmFired,
        alarmClock: true,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: {'prayer': prayer},
      );
    } catch (e) {
      debugPrint('Error scheduling $prayer notification: $e');
    }
  }

  /// Every id [_scheduleAdhanNotification] could have handed to
  /// `AndroidAlarmManager.oneShotAt` across the ~week of days
  /// `scheduleAdhanNotifications` schedules - cancelled up front on every
  /// reschedule so a prayer/day that becomes disabled doesn't leave a
  /// dangling native alarm that fires anyway.
  static Future<void> _cancelAllAlarms() async {
    for (final prayer in _defaultSettings.keys) {
      for (var dayOffset = 0; dayOffset < 8; dayOffset++) {
        await AndroidAlarmManager.cancel(
          _getNotificationId(prayer) + dayOffset * 10,
        );
      }
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
      await _cancelAllAlarms();
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