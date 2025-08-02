import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prayer_service.dart';
import '../providers/adhan_settings_provider.dart';

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          ...prayerTimes.entries.map((entry) {
            final hasNotification = provider.notificationSettings[entry.key] ?? false;
            return _buildPrayerTimeItem(entry.key, entry.value, hasNotification);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.schedule, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Prayer Times',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Icon(Icons.access_time, color: Colors.grey[600], size: 16),
      ],
    );
  }

  Widget _buildPrayerTimeItem(String prayer, DateTime time, bool hasNotification) {
    bool isCurrentPrayer = prayer == currentPrayer;
    bool isNextPrayer = prayer == nextPrayer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? Colors.green.withOpacity(0.1)
            : isNextPrayer
                ? Colors.red.withOpacity(0.1)
                : Colors.transparent,
        border: isCurrentPrayer
            ? Border.all(color: Colors.green, width: 2)
            : isNextPrayer
                ? Border.all(color: Colors.red, width: 2)
                : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getPrayerColor(prayer),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPrayerInfo(prayer, isCurrentPrayer, isNextPrayer),
          ),
          Text(
            PrayerService.formatTime(time),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            hasNotification ? Icons.notifications_active : Icons.notifications_off,
            color: hasNotification ? Colors.amber : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerInfo(String prayer, bool isCurrentPrayer, bool isNextPrayer) {
    List<Widget> children = [];

    List<Widget> nameRowChildren = [
      Text(
        prayer,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ];

    if (isCurrentPrayer) {
      nameRowChildren.add(
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

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
}
