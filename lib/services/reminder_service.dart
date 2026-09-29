// services/reminder_service.dart
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prayer_service.dart';

/// User-configurable timing for the makruh-window and recitation reminders.
/// Defaults match what was agreed on: a 15-minute Fajr-ending warning, the
/// three classical makruh windows (after sunrise, approaching zawal before
/// Dhuhr, and just before sunset), and a Surah Al-Mulk nudge after Isha.
class ReminderSettings {
  final bool fajrEndingEnabled;
  final int fajrEndingMinutesBefore;

  final bool sunriseMakruhEnabled;
  final int sunriseMakruhDurationMinutes;

  final bool dhuhrMakruhEnabled;
  final int dhuhrMakruhMinutesBefore;

  final bool sunsetMakruhEnabled;
  final int sunsetMakruhMinutesBefore;

  final bool surahMulkEnabled;
  final int surahMulkDelayAfterIshaMinutes;

  const ReminderSettings({
    this.fajrEndingEnabled = true,
    this.fajrEndingMinutesBefore = 15,
    this.sunriseMakruhEnabled = true,
    this.sunriseMakruhDurationMinutes = 20,
    this.dhuhrMakruhEnabled = true,
    this.dhuhrMakruhMinutesBefore = 40,
    this.sunsetMakruhEnabled = true,
    this.sunsetMakruhMinutesBefore = 20,
    this.surahMulkEnabled = true,
    this.surahMulkDelayAfterIshaMinutes = 30,
  });

  ReminderSettings copyWith({
    bool? fajrEndingEnabled,
    int? fajrEndingMinutesBefore,
    bool? sunriseMakruhEnabled,
    int? sunriseMakruhDurationMinutes,
    bool? dhuhrMakruhEnabled,
    int? dhuhrMakruhMinutesBefore,
    bool? sunsetMakruhEnabled,
    int? sunsetMakruhMinutesBefore,
    bool? surahMulkEnabled,
    int? surahMulkDelayAfterIshaMinutes,
  }) {
    return ReminderSettings(
      fajrEndingEnabled: fajrEndingEnabled ?? this.fajrEndingEnabled,
      fajrEndingMinutesBefore: fajrEndingMinutesBefore ?? this.fajrEndingMinutesBefore,
      sunriseMakruhEnabled: sunriseMakruhEnabled ?? this.sunriseMakruhEnabled,
      sunriseMakruhDurationMinutes: sunriseMakruhDurationMinutes ?? this.sunriseMakruhDurationMinutes,
      dhuhrMakruhEnabled: dhuhrMakruhEnabled ?? this.dhuhrMakruhEnabled,
      dhuhrMakruhMinutesBefore: dhuhrMakruhMinutesBefore ?? this.dhuhrMakruhMinutesBefore,
      sunsetMakruhEnabled: sunsetMakruhEnabled ?? this.sunsetMakruhEnabled,
      sunsetMakruhMinutesBefore: sunsetMakruhMinutesBefore ?? this.sunsetMakruhMinutesBefore,
      surahMulkEnabled: surahMulkEnabled ?? this.surahMulkEnabled,
      surahMulkDelayAfterIshaMinutes: surahMulkDelayAfterIshaMinutes ?? this.surahMulkDelayAfterIshaMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'fajrEndingEnabled': fajrEndingEnabled,
        'fajrEndingMinutesBefore': fajrEndingMinutesBefore,
        'sunriseMakruhEnabled': sunriseMakruhEnabled,
        'sunriseMakruhDurationMinutes': sunriseMakruhDurationMinutes,
        'dhuhrMakruhEnabled': dhuhrMakruhEnabled,
        'dhuhrMakruhMinutesBefore': dhuhrMakruhMinutesBefore,
        'sunsetMakruhEnabled': sunsetMakruhEnabled,
        'sunsetMakruhMinutesBefore': sunsetMakruhMinutesBefore,
        'surahMulkEnabled': surahMulkEnabled,
        'surahMulkDelayAfterIshaMinutes': surahMulkDelayAfterIshaMinutes,
      };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    const defaults = ReminderSettings();
    return ReminderSettings(
      fajrEndingEnabled: json['fajrEndingEnabled'] ?? defaults.fajrEndingEnabled,
      fajrEndingMinutesBefore: json['fajrEndingMinutesBefore'] ?? defaults.fajrEndingMinutesBefore,
      sunriseMakruhEnabled: json['sunriseMakruhEnabled'] ?? defaults.sunriseMakruhEnabled,
      sunriseMakruhDurationMinutes: json['sunriseMakruhDurationMinutes'] ?? defaults.sunriseMakruhDurationMinutes,
      dhuhrMakruhEnabled: json['dhuhrMakruhEnabled'] ?? defaults.dhuhrMakruhEnabled,
      dhuhrMakruhMinutesBefore: json['dhuhrMakruhMinutesBefore'] ?? defaults.dhuhrMakruhMinutesBefore,
      sunsetMakruhEnabled: json['sunsetMakruhEnabled'] ?? defaults.sunsetMakruhEnabled,
      sunsetMakruhMinutesBefore: json['sunsetMakruhMinutesBefore'] ?? defaults.sunsetMakruhMinutesBefore,
      surahMulkEnabled: json['surahMulkEnabled'] ?? defaults.surahMulkEnabled,
      surahMulkDelayAfterIshaMinutes: json['surahMulkDelayAfterIshaMinutes'] ?? defaults.surahMulkDelayAfterIshaMinutes,
    );
  }
}

/// Schedules the makruh-window and recitation reminders described above,
/// as local notifications alongside (but independent of) the adhan
/// notifications in [AdhanService]. Uses its own channel and ID range
/// (3001-3005) so cancelling/rescheduling one never touches the other.
class ReminderService {
  ReminderService._();

  static const _prefsKey = 'reminder_settings';
  static const _channelKey = 'prayer_reminder_channel';

  static const _idFajrEnding = 3001;
  static const _idSunriseMakruh = 3002;
  static const _idDhuhrMakruh = 3003;
  static const _idSunsetMakruh = 3004;
  static const _idSurahMulk = 3005;

  /// Registers the reminder notification channel. Must run after
  /// [AwesomeNotifications] has been initialized with the 'adhan_group'
  /// channel group (see [AdhanService.initialize]), since this channel
  /// joins that same group.
  static Future<void> initialize() async {
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelGroupKey: 'adhan_group',
        channelKey: _channelKey,
        channelName: 'Prayer Reminders',
        channelDescription: 'Makruh time windows and recitation reminders',
        defaultColor: Colors.teal,
        // Max (not High): these are precise-alarm scheduled minutes ahead of
        // a makruh window, so they need the same protection from OEM
        // battery-optimization throttling that the adhan channel gets, or
        // they're liable to be delayed/dropped exactly like Bug 1's original
        // "reminders just don't show up" symptom.
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  static Future<ReminderSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return const ReminderSettings();
      return ReminderSettings.fromJson(json.decode(raw));
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
      return const ReminderSettings();
    }
  }

  static Future<void> saveSettings(ReminderSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, json.encode(settings.toJson()));
    } catch (e) {
      debugPrint('Error saving reminder settings: $e');
    }
  }

  /// (Re)schedules every enabled reminder from [prayerTimesByDay] (today
  /// first, then each following day). Cancels this channel's existing
  /// notifications first so a settings change or a new schedule never leaves
  /// a stale reminder behind.
  ///
  /// Scheduling more than just today matters for the same reason
  /// [AdhanService.scheduleAdhanNotifications] does: there's no background
  /// task in this app to recompute and reschedule daily, so a single day's
  /// worth of reminders would otherwise silently stop firing after that day.
  static Future<void> scheduleReminders(
    List<Map<String, DateTime>> prayerTimesByDay,
  ) async {
    try {
      await AwesomeNotifications().cancelNotificationsByChannelKey(_channelKey);
      final settings = await getSettings();
      final now = DateTime.now();

      for (var dayOffset = 0; dayOffset < prayerTimesByDay.length; dayOffset++) {
        final prayerTimes = prayerTimesByDay[dayOffset];
        final sunrise = prayerTimes['Sunrise'];
        final dhuhr = prayerTimes['Dhuhr'];
        final maghrib = prayerTimes['Maghrib'];
        final isha = prayerTimes['Isha'];
        // Offset by day so a week of the same reminder gets distinct ids
        // instead of each day's schedule call overwriting the previous one.
        final idOffset = dayOffset * 10;

        if (settings.fajrEndingEnabled && sunrise != null) {
          final fireAt = sunrise.subtract(Duration(minutes: settings.fajrEndingMinutesBefore));
          if (!fireAt.isBefore(now)) {
            await _schedule(
              id: _idFajrEnding + idOffset,
              time: fireAt,
              title: '🌄 Fajr time is ending soon',
              body: 'Pray Fajr before sunrise at ${PrayerService.formatTime(sunrise)}.',
            );
          }
        }

        if (settings.sunriseMakruhEnabled && sunrise != null && !sunrise.isBefore(now)) {
          final prayAfter = sunrise.add(Duration(minutes: settings.sunriseMakruhDurationMinutes));
          await _schedule(
            id: _idSunriseMakruh + idOffset,
            time: sunrise,
            title: '☀️ Sunrise — avoid prayer',
            body: 'Sunrise starts at ${PrayerService.formatTime(sunrise)}. '
                'Pray any namaz after ${PrayerService.formatTime(prayAfter)}.',
          );
        }

        if (settings.dhuhrMakruhEnabled && dhuhr != null) {
          final fireAt = dhuhr.subtract(Duration(minutes: settings.dhuhrMakruhMinutesBefore));
          if (!fireAt.isBefore(now)) {
            await _schedule(
              id: _idDhuhrMakruh + idOffset,
              time: fireAt,
              title: '☀️ Avoid prayer — zawal approaching',
              body: 'Avoid nafl prayer until Dhuhr begins at ${PrayerService.formatTime(dhuhr)}.',
            );
          }
        }

        if (settings.sunsetMakruhEnabled && maghrib != null) {
          final fireAt = maghrib.subtract(Duration(minutes: settings.sunsetMakruhMinutesBefore));
          if (!fireAt.isBefore(now)) {
            await _schedule(
              id: _idSunsetMakruh + idOffset,
              time: fireAt,
              title: '🌇 Avoid prayer — sunset approaching',
              body: 'Avoid prayer for the next ${settings.sunsetMakruhMinutesBefore} minutes, '
                  'until Maghrib at ${PrayerService.formatTime(maghrib)}.',
            );
          }
        }

        if (settings.surahMulkEnabled && isha != null) {
          final fireAt = isha.add(Duration(minutes: settings.surahMulkDelayAfterIshaMinutes));
          if (!fireAt.isBefore(now)) {
            await _schedule(
              id: _idSurahMulk + idOffset,
              time: fireAt,
              title: '📖 Recite Surah Al-Mulk',
              body: 'A beautiful sunnah before sleeping — recite Surah Al-Mulk tonight.',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling reminders: $e');
    }
  }

  static Future<void> _schedule({
    required int id,
    required DateTime time,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        wakeUpScreen: false,
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.BigText,
      ),
      schedule: NotificationCalendar.fromDate(
        date: time,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  static Future<void> cancelAll() async {
    try {
      await AwesomeNotifications().cancelNotificationsByChannelKey(_channelKey);
    } catch (e) {
      debugPrint('Error canceling reminders: $e');
    }
  }
}
