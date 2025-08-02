import 'package:flutter/material.dart';
import '../services/prayer_service.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    List<Widget> children = [];

    // Add header
    children.add(_buildHeader());
    children.add(const SizedBox(height: 16));

    // Add prayer time items
    prayerTimes.entries.forEach((entry) {
      bool hasNotification = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
          .contains(entry.key);
      children.add(_buildPrayerTimeItem(
        entry.key,
        entry.value,
        hasNotification,
      ));
    });

    return Column(children: children);
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
        Icon(
          Icons.access_time,
          color: Colors.grey[600],
          size: 16,
        ),
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
            ? Colors.green.withValues(alpha: 0.1)
            : isNextPrayer
            ? Colors.red.withValues(alpha: 0.1)
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
          if (hasNotification)
            const Icon(
              Icons.notifications_active,
              color: Colors.amber,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerInfo(String prayer, bool isCurrentPrayer, bool isNextPrayer) {
    List<Widget> children = [];

    // Prayer name row
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
      nameRowChildren.add(Container(
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
      ));
    }

    if (isNextPrayer) {
      nameRowChildren.add(Container(
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
      ));
    }

    children.add(Row(children: nameRowChildren));

    // Add Hanafi note for Asr
    if (prayer == 'Asr') {
      children.add(const Text(
        '(Hanafi)',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 12,
        ),
      ));
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

class CompactPrayerTimesWidget extends StatelessWidget {
  final Map<String, DateTime> prayerTimes;
  final String currentPrayer;
  final String nextPrayer;

  const CompactPrayerTimesWidget({
    super.key,
    required this.prayerTimes,
    required this.currentPrayer,
    required this.nextPrayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildCompactContent(),
    );
  }

  Widget _buildCompactContent() {
    List<Widget> children = [];

    // Add header
    children.add(Row(
      children: [
        const Icon(Icons.schedule, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        const Text(
          'Prayer Times',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ));

    children.add(const SizedBox(height: 12));

    // Add compact prayer items (excluding Sunrise)
    final filteredEntries = prayerTimes.entries
        .where((entry) => entry.key != 'Sunrise')
        .toList();

    for (var entry in filteredEntries) {
      bool isCurrentPrayer = entry.key == currentPrayer;
      bool isNextPrayer = entry.key == nextPrayer;

      children.add(Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isCurrentPrayer
              ? Colors.green.withOpacity(0.2)
              : isNextPrayer
              ? Colors.red.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: _getPrayerColor(entry.key),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              entry.key,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isCurrentPrayer || isNextPrayer
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Text(
              PrayerService.formatTime(entry.value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ));
    }

    return Column(children: children);
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