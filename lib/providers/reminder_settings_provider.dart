import 'package:flutter/material.dart';

import '../services/reminder_service.dart';

class ReminderSettingsProvider extends ChangeNotifier {
  ReminderSettings _settings = const ReminderSettings();
  Map<String, DateTime>? _prayerTimes;

  ReminderSettings get settings => _settings;

  ReminderSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _settings = await ReminderService.getSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
    }
  }

  /// Called whenever the screen recalculates today's prayer times, so a
  /// settings change made mid-day can reschedule against the right times
  /// without the settings screen needing to know about [PrayerService].
  void updatePrayerTimes(Map<String, DateTime> prayerTimes) {
    _prayerTimes = prayerTimes;
  }

  Future<void> _persistAndReschedule(ReminderSettings updated) async {
    _settings = updated;
    notifyListeners();
    await ReminderService.saveSettings(updated);
    final times = _prayerTimes;
    if (times != null) {
      // Only today's times are known here; the full multi-day schedule gets
      // restored on the next full recalculation (see
      // PrayerTimesScreen._scheduleNotifications).
      await ReminderService.scheduleReminders([times]);
    }
  }

  Future<void> setFajrEnding({bool? enabled, int? minutesBefore}) {
    return _persistAndReschedule(_settings.copyWith(
      fajrEndingEnabled: enabled,
      fajrEndingMinutesBefore: minutesBefore,
    ));
  }

  Future<void> setSunriseMakruh({bool? enabled, int? durationMinutes}) {
    return _persistAndReschedule(_settings.copyWith(
      sunriseMakruhEnabled: enabled,
      sunriseMakruhDurationMinutes: durationMinutes,
    ));
  }

  Future<void> setDhuhrMakruh({bool? enabled, int? minutesBefore}) {
    return _persistAndReschedule(_settings.copyWith(
      dhuhrMakruhEnabled: enabled,
      dhuhrMakruhMinutesBefore: minutesBefore,
    ));
  }

  Future<void> setSunsetMakruh({bool? enabled, int? minutesBefore}) {
    return _persistAndReschedule(_settings.copyWith(
      sunsetMakruhEnabled: enabled,
      sunsetMakruhMinutesBefore: minutesBefore,
    ));
  }

  Future<void> setSurahMulk({bool? enabled, int? delayMinutes}) {
    return _persistAndReschedule(_settings.copyWith(
      surahMulkEnabled: enabled,
      surahMulkDelayAfterIshaMinutes: delayMinutes,
    ));
  }
}
