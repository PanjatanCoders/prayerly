import 'package:flutter/material.dart';

import 'prayer_service.dart';

/// Which section of the Islamic Events screen a day belongs in: a universal
/// Islamic holiday, or an Urs (Sufi saint's death-anniversary observance)
/// specific to a dargah in India.
enum SpecialDayCategory { islamicHoliday, urs }

/// A named Islamic special day anchored to a fixed Hijri month/day (e.g. 10
/// Muharram for Ashura), as opposed to [IslamicOccasionService]'s "what's
/// notable about today" check (Ramadan-in-progress, White Days, Jumu'ah).
/// This is the fuller list a Meezan-style wall calendar prints for the whole
/// year, not just today.
class IslamicSpecialDay {
  final int hijriMonth;
  final int hijriDay;
  final String title;
  final String description;
  final IconData icon;
  final SpecialDayCategory category;

  const IslamicSpecialDay({
    required this.hijriMonth,
    required this.hijriDay,
    required this.title,
    required this.description,
    required this.icon,
    this.category = SpecialDayCategory.islamicHoliday,
  });
}

/// [IslamicSpecialDay] paired with its next upcoming Gregorian date.
class UpcomingSpecialDay {
  final IslamicSpecialDay day;
  final DateTime gregorianDate;
  final int daysUntil;

  const UpcomingSpecialDay({
    required this.day,
    required this.gregorianDate,
    required this.daysUntil,
  });
}

class IslamicSpecialDaysService {
  IslamicSpecialDaysService._();

  /// Dates follow the same offline Kuwaiti-algorithm Hijri calculation
  /// [PrayerService] uses everywhere else in the app (calendar grid,
  /// Ramadan/White-Days detection) - not local moon sighting - so this list
  /// is consistent with the rest of Prayerly, but can land a day off from a
  /// moon-sighting-based announcement in your region, same caveat as any
  /// calculated Hijri calendar. Laylat al-Qadr has no fixed date in reality
  /// (it's one of the odd nights in Ramadan's last ten); the 27th is listed
  /// here only because it's the night most widely observed.
  static const List<IslamicSpecialDay> all = [
    IslamicSpecialDay(
      hijriMonth: 1,
      hijriDay: 1,
      title: 'Islamic New Year',
      description: '1 Muharram — the start of the new Hijri year',
      icon: Icons.nights_stay,
    ),
    IslamicSpecialDay(
      hijriMonth: 1,
      hijriDay: 10,
      title: 'Day of Ashura',
      description: '10 Muharram — a recommended day of fasting',
      icon: Icons.brightness_2,
    ),
    IslamicSpecialDay(
      hijriMonth: 3,
      hijriDay: 12,
      title: 'Mawlid al-Nabi',
      description: "12 Rabi' al-Awwal — the Prophet's ﷺ birthday",
      icon: Icons.star,
    ),
    IslamicSpecialDay(
      hijriMonth: 7,
      hijriDay: 27,
      title: "Isra and Mi'raj",
      description: "27 Rajab — the Prophet's ﷺ Night Journey and Ascension",
      icon: Icons.nightlight_round,
    ),
    IslamicSpecialDay(
      hijriMonth: 8,
      hijriDay: 15,
      title: 'Shab-e-Barat',
      description: "15 Sha'ban — Laylat al-Bara'ah, the Night of Forgiveness",
      icon: Icons.auto_awesome,
    ),
    IslamicSpecialDay(
      hijriMonth: 9,
      hijriDay: 1,
      title: 'Ramadan Begins',
      description: '1 Ramadan — the start of the fasting month',
      icon: Icons.mosque,
    ),
    IslamicSpecialDay(
      hijriMonth: 9,
      hijriDay: 27,
      title: 'Laylat al-Qadr (observed)',
      description: '27 Ramadan — widely observed as the Night of Decree',
      icon: Icons.auto_awesome,
    ),
    IslamicSpecialDay(
      hijriMonth: 10,
      hijriDay: 1,
      title: 'Eid al-Fitr',
      description: '1 Shawwal — the festival marking the end of Ramadan',
      icon: Icons.celebration,
    ),
    IslamicSpecialDay(
      hijriMonth: 12,
      hijriDay: 9,
      title: 'Day of Arafah',
      description: '9 Dhul Hijjah — the most important day of Hajj',
      icon: Icons.landscape,
    ),
    IslamicSpecialDay(
      hijriMonth: 12,
      hijriDay: 10,
      title: 'Eid al-Adha',
      description: '10 Dhul Hijjah — the Festival of Sacrifice',
      icon: Icons.celebration,
    ),

    // --- Urs (death-anniversary) observances at dargahs in India ---
    //
    // Each date below was checked against multiple independent sources
    // rather than assumed; where a saint's actual death date and the
    // dargah's traditionally-observed Urs date differ slightly (this
    // happens - e.g. Nizamuddin Auliya), the traditionally-observed date is
    // used since that's the one people actually gather for. Two requested
    // Urs were deliberately left out because no source gave a consistent,
    // specific Hijri day: Baba Tajuddin (Nagpur) and the Dewa Sharif Waris
    // Pak mela (whose main annual fair turned out to run on a Hindu
    // Vikram-Samvat calendar date, not Hijri, alongside a separately
    // mentioned "1 Safar" observance) - add these once you have a
    // confirmed Hijri day/month from the dargah itself.
    IslamicSpecialDay(
      hijriMonth: 7,
      hijriDay: 6,
      title: 'Urs of Ajmer Sharif',
      description: 'Chhati Sharif, 6 Rajab — Khwaja Moinuddin Chishti, Ajmer',
      icon: Icons.account_balance,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 3,
      hijriDay: 14,
      title: 'Urs of Qutbuddin Bakhtiyar Kaki',
      description: "14 Rabi' al-Awwal — Mehrauli Dargah, Delhi",
      icon: Icons.account_balance,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 4,
      hijriDay: 16,
      title: 'Urs of Haji Ali',
      description: "16 Rabi' al-Thani — Haji Ali Dargah, Mumbai",
      icon: Icons.account_balance,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 4,
      hijriDay: 17,
      title: 'Urs of Nizamuddin Auliya',
      description: "17 Rabi' al-Thani — Nizamuddin Dargah, Delhi",
      icon: Icons.account_balance,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 5,
      hijriDay: 6,
      title: 'Urs-e-Mujahid-e-Millat',
      description: 'Jumada al-Awwal 6 — Dhamnagar Dargah, Odisha',
      icon: Icons.menu_book,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 2,
      hijriDay: 25,
      title: 'Urs-e-Razavi (Ala Hazrat)',
      description: '25 Safar — Imam Ahmad Raza Khan, Bareilly',
      icon: Icons.menu_book,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 4,
      hijriDay: 11,
      title: 'Giyarhwin Sharif (Ghaus-e-Azam)',
      description: "11 Rabi' al-Thani — Sheikh Abdul Qadir Jilani, observed across India",
      icon: Icons.account_balance,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 11,
      hijriDay: 6,
      title: 'Urs-e-Tajushariya',
      description: 'Dhul Qadah 6 — Mufti Akhtar Raza Khan, Bareilly',
      icon: Icons.menu_book,
      category: SpecialDayCategory.urs,
    ),
    IslamicSpecialDay(
      hijriMonth: 1,
      hijriDay: 28,
      title: 'Urs of Makhdum Ashraf',
      description: 'Muharram 28 — Kichaucha Sharif, Uttar Pradesh',
      icon: Icons.account_balance,
      category: SpecialDayCategory.urs,
    ),
  ];

  /// [all], each resolved to its next upcoming Gregorian date from [now]
  /// (today counts as "upcoming" with `daysUntil == 0`), sorted soonest
  /// first.
  static List<UpcomingSpecialDay> upcoming(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final resolved = all
        .map((day) => _nextOccurrence(day, today))
        .whereType<UpcomingSpecialDay>()
        .toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return resolved;
  }

  /// Searches forward up to one Hijri year for the next date whose Hijri
  /// month/day matches [day]. Cheap one-off scan; there is no closed-form
  /// inverse for the Kuwaiti algorithm used by [PrayerService].
  static UpcomingSpecialDay? _nextOccurrence(IslamicSpecialDay day, DateTime today) {
    for (int offset = 0; offset <= 355; offset++) {
      final candidate = today.add(Duration(days: offset));
      final hijri = PrayerService.hijriComponents(candidate);
      if (hijri['month'] == day.hijriMonth && hijri['day'] == day.hijriDay) {
        return UpcomingSpecialDay(day: day, gregorianDate: candidate, daysUntil: offset);
      }
    }
    return null;
  }
}
