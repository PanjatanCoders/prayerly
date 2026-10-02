import 'package:flutter/material.dart';

import 'prayer_service.dart';

/// A notable Islamic day worth calling out on the home screen: Ramadan in
/// progress, the White Days (Ayyam al-Bidh), Jumu'ah, or a Ramadan countdown.
class IslamicOccasion {
  final String title;
  final String subtitle;
  final IconData icon;

  /// Whether this occasion is the Jumu'ah banner specifically - lets the
  /// widget make just this one tappable (to prompt the Shab-e-Jumu'ah
  /// Durood) without every other occasion also appearing interactive.
  final bool isJumuah;

  const IslamicOccasion({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isJumuah = false,
  });
}

class IslamicOccasionService {
  IslamicOccasionService._();

  static const _ramadanMonth = 9;

  /// The most relevant occasion for [now], or null on an ordinary day.
  /// Checked in priority order: Ramadan in progress, then the White Days,
  /// then Jumu'ah, then a Ramadan countdown once it's within reach.
  static IslamicOccasion? currentOccasion(DateTime now) {
    final hijri = PrayerService.hijriComponents(now);
    final day = hijri['day']!;
    final month = hijri['month']!;

    if (month == _ramadanMonth) {
      return IslamicOccasion(
        title: 'Ramadan Mubarak',
        subtitle: 'Day $day of Ramadan — may your fast be accepted',
        icon: Icons.nightlight_round,
      );
    }

    if (day == 13 || day == 14 || day == 15) {
      return const IslamicOccasion(
        title: 'Ayyam al-Bidh',
        subtitle: 'The White Days — a recommended time to fast',
        icon: Icons.brightness_2,
      );
    }

    if (now.weekday == DateTime.friday) {
      return const IslamicOccasion(
        title: 'Jumu’ah Mubarak',
        subtitle: 'Tap to recite the Durood of Jumu’ah',
        icon: Icons.mosque,
        isJumuah: true,
      );
    }

    final daysUntilRamadan = _daysUntilHijriMonth(now, _ramadanMonth);
    if (daysUntilRamadan != null && daysUntilRamadan <= 15) {
      return IslamicOccasion(
        title: daysUntilRamadan == 0
            ? 'Ramadan begins today'
            : 'Ramadan in $daysUntilRamadan day${daysUntilRamadan == 1 ? '' : 's'}',
        subtitle: 'Prepare your heart and intentions',
        icon: Icons.event,
      );
    }

    return null;
  }

  /// Days from [now] until the next 1st of [targetMonth], searching forward
  /// up to one Hijri year. Cheap one-off scan; there is no closed-form
  /// inverse for the Kuwaiti algorithm used by [PrayerService].
  static int? _daysUntilHijriMonth(DateTime now, int targetMonth) {
    for (int offset = 0; offset <= 355; offset++) {
      final candidate = now.add(Duration(days: offset));
      final hijri = PrayerService.hijriComponents(candidate);
      if (hijri['month'] == targetMonth && hijri['day'] == 1) {
        return offset;
      }
    }
    return null;
  }
}
