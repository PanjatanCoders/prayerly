// services/adhan_service.dart (Updated with Auto-Play)
// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  /// A short, finite vibration pattern (ms, off/on/off/on...). Left
  /// unspecified, some OEMs pair `NotificationCategory.Alarm` +
  /// `fullScreenIntent` with a vibration that repeats indefinitely until the
  /// notification is dismissed - this bounds it to one buzz.
  static Int64List get _vibrationPattern =>
      Int64List.fromList([0, 500, 200, 500]);

  /// One real notification channel per adhan audio file, each wired to play
  /// that file as the channel's native sound (`resource://raw/<type>`,
  /// backed by `android/app/src/main/res/raw/<type>.mp3`).
  ///
  /// This is deliberately *not* played through the Dart [_audioPlayer] for
  /// the scheduled/auto-play path. `android_alarm_manager_plus` was tried
  /// first (see git history) to wake a Dart background isolate and play the
  /// adhan from there, but that isolate doesn't reliably survive to finish
  /// (or play audio at all) once Android has killed the app process - the
  /// user would see/feel the notification vibrate (posted natively, so that
  /// part always worked) but never hear the adhan, and the adhan would only
  /// actually play if they happened to reopen the app afterwards (the
  /// buffered "notification displayed" event replaying once a Dart listener
  /// reattached). A channel's own sound is posted by the OS itself, with no
  /// Dart/Flutter isolate involved at all, so it's as reliable as the
  /// notification itself.
  ///
  /// Android notification channels are immutable after first creation
  /// (changing `soundSource` on an existing channel key has no effect), so
  /// each adhan type needs its own channel key rather than one shared key
  /// with a variable sound.
  static String _channelKeyForType(String typeKey) => 'adhan_channel_$typeKey';

  /// Used instead of a per-type channel when auto-play is disabled - plain
  /// vibration only, no sound, since the user wants to tap to play manually.
  static const String _silentChannelKey = 'adhan_channel_silent';

  static Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        for (final typeKey in adhanTypes.keys)
          NotificationChannel(
            channelGroupKey: 'adhan_group',
            channelKey: _channelKeyForType(typeKey),
            channelName: 'Adhan - ${adhanTypes[typeKey] ?? typeKey}',
            channelDescription: 'Prayer time adhan notifications ($typeKey)',
            defaultColor: Colors.amber,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            soundSource: 'resource://raw/$typeKey',
            enableVibration: true,
            vibrationPattern: _vibrationPattern,
            enableLights: true,
            criticalAlerts: true,
          ),
        NotificationChannel(
          channelGroupKey: 'adhan_group',
          channelKey: _silentChannelKey,
          channelName: 'Adhan (manual)',
          channelDescription: 'Prayer time notifications without auto-play',
          defaultColor: Colors.amber,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: false,
          enableVibration: true,
          vibrationPattern: _vibrationPattern,
          enableLights: true,
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

  /// The adhan type key (e.g. `'azan1'`, `'azan_fajr1'`) to use for
  /// [prayerName] - doubles as the Flutter asset basename and the Android
  /// raw resource name (`resource://raw/<key>`) for that audio.
  static Future<String> _getAdhanTypeKey(String prayerName) async {
    final adhanType = await getSelectedAdhanType();
    if (prayerName == 'Fajr' && adhanType == 'azan_fajr1') {
      return 'azan_fajr1';
    }
    return adhanType;
  }

  static Future<String> _getAdhanFile(String prayerName) async {
    final typeKey = await _getAdhanTypeKey(prayerName);
    return 'audio/adhan/$typeKey.mp3';
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

  // This method is called when the user interacts with a notification
  // (button press or tap). Auto-play itself does NOT go through here - it's
  // the adhan channel's own native sound (`resource://raw/<type>`, set up in
  // `_initializeNotifications`) that plays automatically, posted by the OS
  // with no Dart involvement. Two earlier approaches were tried and
  // abandoned: `onNotificationDisplayedMethod` (awesome_notifications has no
  // background-isolate resurrection path for it, so it only fired if the app
  // process happened to still be alive) and an `android_alarm_manager_plus`
  // alarm running this same playback in its own background isolate (that
  // isolate could start but audio playback through it was unreliable - the
  // user would feel the notification vibrate on time but only actually hear
  // the adhan if they reopened the app afterwards, which replayed it late).
  // A channel's native sound has neither failure mode.
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
          // The notification body was tapped (just opens the app) or this
          // fired for the notification's creation/display, neither of which
          // should (re)play the adhan - the channel's native sound already
          // handled auto-play, and replaying it here is what caused the
          // adhan to play late, minutes after the actual prayer time, if the
          // user opened the app sometime after it had already fired.
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
      for (final typeKey in adhanTypes.keys) {
        await AwesomeNotifications().cancelNotificationsByChannelKey(
          _channelKeyForType(typeKey),
        );
      }
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        _silentChannelKey,
      );
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
      final channelKey = autoPlay
          ? _channelKeyForType(await _getAdhanTypeKey(prayer))
          : _silentChannelKey;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
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
      for (final typeKey in adhanTypes.keys) {
        await AwesomeNotifications().cancelNotificationsByChannelKey(
          _channelKeyForType(typeKey),
        );
      }
      await AwesomeNotifications().cancelNotificationsByChannelKey(
        _silentChannelKey,
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