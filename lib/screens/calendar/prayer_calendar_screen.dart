import 'package:flutter/material.dart';

import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../../utils/theme/app_theme.dart';

/// Monthly prayer calendar: a Gregorian grid with the Hijri day underneath
/// each cell, today highlighted, and Jumu'ah/Ramadan/White-Days badged using
/// the same offline Hijri conversion [PrayerService] already exposes.
/// Tapping a day opens a sheet with that day's full prayer times.
class PrayerCalendarScreen extends StatefulWidget {
  const PrayerCalendarScreen({super.key});

  @override
  State<PrayerCalendarScreen> createState() => _PrayerCalendarScreenState();
}

class _PrayerCalendarScreenState extends State<PrayerCalendarScreen> {
  late DateTime _visibleMonth;
  LocationData? _location;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _loadLocation();
  }

  /// The grid itself (Gregorian/Hijri dates, occasion badges) needs no
  /// location at all - only the per-day prayer-time sheet does - so this
  /// runs in the background without blocking the calendar from rendering.
  Future<void> _loadLocation() async {
    final cached = await LocationService.cachedLocation();
    if (cached != null && mounted) {
      setState(() => _location = cached);
    }
    final resolved = await LocationService.resolve(context: mounted ? context : null);
    if (mounted) setState(() => _location = resolved);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  void _openDay(DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DayDetailSheet(day: day, location: _location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Prayer Calendar'),
      ),
      body: Column(
        children: [
          _MonthHeader(
            month: _visibleMonth,
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: _MonthGrid(
                month: _visibleMonth,
                onDayTap: _openDay,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _LegendDot(color: AppTheme.primaryGreen, label: 'Today'),
                const SizedBox(width: 16),
                _LegendDot(color: AppTheme.primaryAmber, label: 'White Days'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.teal, label: "Jumu'ah"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final hijriStart = PrayerService.hijriComponents(month);
    final hijriEnd = PrayerService.hijriComponents(
      DateTime(month.year, month.month + 1, 0),
    );
    final hijriLabel = hijriStart['month'] == hijriEnd['month']
        ? '${PrayerService.hijriMonthNames[(hijriStart['month']! - 1).clamp(0, 11)]} ${hijriStart['year']}'
        : '${PrayerService.hijriMonthNames[(hijriStart['month']! - 1).clamp(0, 11)]} / '
            '${PrayerService.hijriMonthNames[(hijriEnd['month']! - 1).clamp(0, 11)]} ${hijriEnd['year']}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: onSurface),
            onPressed: onPrevious,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_monthNames[month.month - 1]} ${month.year}',
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hijriLabel,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: onSurface),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final ValueChanged<DateTime> onDayTap;

  const _MonthGrid({required this.month, required this.onDayTap});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Dart weekdays: Monday=1..Sunday=7. Mod 7 gives a Sunday-first offset
    // (Sunday=0, Monday=1, ..., Saturday=6) matching the S M T W T F S header.
    final leadingBlanks = DateTime(month.year, month.month, 1).weekday % 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemCount: leadingBlanks + daysInMonth,
      itemBuilder: (context, index) {
        if (index < leadingBlanks) return const SizedBox.shrink();

        final day = DateTime(month.year, month.month, index - leadingBlanks + 1);
        final isToday = day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        final hijri = PrayerService.hijriComponents(day);
        final isRamadan = hijri['month'] == 9;
        final isWhiteDay = [13, 14, 15].contains(hijri['day']);
        final isJumuah = day.weekday == DateTime.friday;

        return _DayCell(
          gregorianDay: day.day,
          hijriDay: hijri['day']!,
          isToday: isToday,
          isRamadan: isRamadan,
          isWhiteDay: isWhiteDay,
          isJumuah: isJumuah,
          onTap: () => onDayTap(day),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final int gregorianDay;
  final int hijriDay;
  final bool isToday;
  final bool isRamadan;
  final bool isWhiteDay;
  final bool isJumuah;
  final VoidCallback onTap;

  const _DayCell({
    required this.gregorianDay,
    required this.hijriDay,
    required this.isToday,
    required this.isRamadan,
    required this.isWhiteDay,
    required this.isJumuah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    Color? background;
    if (isToday) {
      background = AppTheme.primaryGreen;
    } else if (isRamadan) {
      background = AppTheme.primaryGreen.withValues(alpha: 0.12);
    } else if (isWhiteDay) {
      background = AppTheme.primaryAmber.withValues(alpha: 0.15);
    }

    final textColor = isToday ? Colors.white : onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$gregorianDay',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '$hijriDay',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
            if (isJumuah && !isToday) ...[
              const SizedBox(height: 2),
              Icon(Icons.mosque, size: 9, color: Colors.teal.withValues(alpha: 0.7)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final DateTime day;
  final LocationData? location;

  const _DayDetailSheet({required this.day, required this.location});

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final location = this.location;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_monthNames[day.month - 1]} ${day.day}, ${day.year}',
              style: TextStyle(
                color: onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (location == null)
              Text(
                'Waiting for location to calculate prayer times…',
                style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
              )
            else
              FutureBuilder<PrayerTimesData>(
                future: PrayerService.getPrayerTimes(
                  latitude: location.latitude,
                  longitude: location.longitude,
                  date: day,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final times = snapshot.data!.prayerTimes;
                  return Column(
                    children: times.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key,
                                    style: TextStyle(color: onSurface, fontSize: 15),
                                  ),
                                  Text(
                                    PrayerService.formatTime(e.value),
                                    style: TextStyle(
                                      color: onSurface,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
