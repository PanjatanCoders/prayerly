// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/calendar/prayer_calendar_screen.dart';
import '../services/prayer_service.dart';
import '../providers/adhan_settings_provider.dart';
import '../providers/reminder_settings_provider.dart';
import '../utils/theme/app_theme.dart';
import '../utils/theme/app_transitions.dart';

class PrayerTimesListWidget extends StatelessWidget {
  final Map<String, DateTime> prayerTimes;
  final String currentPrayer;
  final String nextPrayer;

  const PrayerTimesListWidget({
    super.key,
    required this.prayerTimes,
    required this.currentPrayer,
    required this.nextPrayer,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdhanSettingsProvider>(context);
    final reminderProvider = Provider.of<ReminderSettingsProvider>(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(context, onSurface),
          const SizedBox(height: 16),
          ...prayerTimes.entries.map((entry) {
            final hasNotification = entry.key == 'Sunrise'
                ? reminderProvider.settings.sunriseMakruhEnabled
                : provider.notificationSettings[entry.key] ?? false;
            return _buildPrayerTimeItem(context, entry.key, entry.value, hasNotification, onSurface);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color onSurface) {
    return Row(
      children: [
        Icon(Icons.schedule, color: onSurface, size: 20),
        const SizedBox(width: 8),
        Text(
          'Prayer Times',
          style: TextStyle(
            color: onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Material(
          color: onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              AppTransitions.slideIn(const PrayerCalendarScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month, size: 14, color: onSurface.withValues(alpha: 0.8)),
                  const SizedBox(width: 4),
                  Text(
                    'View Calendar',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 14, color: onSurface.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimeItem(BuildContext context, String prayer, DateTime time, bool hasNotification, Color onSurface) {
    bool isNextPrayer = prayer == nextPrayer;
    bool isSunrise = prayer == 'Sunrise';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNextPrayer ? Colors.red.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.legibleAccent(context, _getPrayerColor(prayer)),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            _getPrayerIcon(prayer),
            color: AppTheme.legibleAccent(context, _getPrayerColor(prayer)),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildPrayerInfo(prayer, isNextPrayer, onSurface),
          ),
          Text(
            PrayerService.formatTime(time),
            style: TextStyle(
              color: onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          // Sunrise isn't a prayer you can set an adhan for, so it gets a
          // plain "acknowledged" checkmark instead of a notification toggle.
          isSunrise
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : Icon(
                  hasNotification ? Icons.notifications_active : Icons.notifications_off,
                  color: hasNotification ? Colors.amber : Colors.grey,
                  size: 20,
                ),
        ],
      ),
    );
  }

  Widget _buildPrayerInfo(String prayer, bool isNextPrayer, Color onSurface) {
    List<Widget> children = [];

    List<Widget> nameRowChildren = [
      Text(
        prayer,
        style: TextStyle(
          color: onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ];

    if (isNextPrayer) {
      nameRowChildren.add(
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Next',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    children.add(Row(children: nameRowChildren));

    if (prayer == 'Asr') {
      children.add(
        const Text(
          '(Hanafi)',
          style: TextStyle(color: Colors.blue, fontSize: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Colors.blue;
      case 'Sunrise':
        return Colors.orange;
      case 'Dhuhr':
        return Colors.red;
      case 'Asr':
        return Colors.amber;
      case 'Maghrib':
        return Colors.purple;
      case 'Isha':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.mosque;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhuhr':
      case 'Asr':
        return Icons.wb_sunny;
      case 'Maghrib':
        return Icons.wb_twilight;
      case 'Isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }
}
