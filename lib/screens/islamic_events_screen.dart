import 'package:flutter/material.dart';

import '../services/islamic_special_days.dart';
import '../utils/theme/app_theme.dart';

/// The full list of named Islamic special days (Ashura, Mawlid, Ramadan,
/// both Eids, etc.) with their next upcoming Gregorian date - a Meezan-style
/// "whole year at a glance" view, distinct from [OccasionBannerWidget]'s
/// single "what's notable about today" banner on the home screen.
class IslamicEventsScreen extends StatelessWidget {
  const IslamicEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final upcoming = IslamicSpecialDaysService.upcoming(DateTime.now());
    final holidays = upcoming
        .where((u) => u.day.category == SpecialDayCategory.islamicHoliday)
        .toList();
    final urs = upcoming
        .where((u) => u.day.category == SpecialDayCategory.urs)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Islamic Events')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Islamic Holidays'),
          const SizedBox(height: 10),
          for (final item in holidays) ...[
            _EventTile(item: item),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          _SectionHeader(
            title: 'Urs Observances (India)',
            subtitle: 'Sufi saints\' death anniversaries, marked at dargahs across India',
          ),
          const SizedBox(height: 10),
          for (final item in urs) ...[
            _EventTile(item: item),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(color: onSurface.withValues(alpha: 0.55), fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final UpcomingSpecialDay item;

  const _EventTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final accent = AppTheme.legibleAccent(context, AppTheme.primaryAmber);
    final isToday = item.daysUntil == 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isToday ? Border.all(color: accent.withValues(alpha: 0.6)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item.day.icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.day.title,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.day.description,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(item.gregorianDate),
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isToday ? accent : accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _relativeLabel(item.daysUntil),
                  style: TextStyle(
                    color: isToday ? Colors.white : accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
  }

  String _relativeLabel(int daysUntil) {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    return 'In $daysUntil days';
  }
}
