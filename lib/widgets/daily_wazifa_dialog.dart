import 'package:flutter/material.dart';

import '../models/dhikr_models.dart';
import '../screens/dhikr/dhikr_counter_screen.dart';
import '../services/daily_wazifa_service.dart';
import '../utils/bidi_utils.dart';
import '../utils/theme/app_theme.dart';
import '../utils/theme/app_transitions.dart';

const _dayNames = {
  DateTime.monday: 'Monday',
  DateTime.tuesday: 'Tuesday',
  DateTime.wednesday: 'Wednesday',
  DateTime.thursday: 'Thursday',
  DateTime.friday: 'Friday',
  DateTime.saturday: 'Saturday',
  DateTime.sunday: 'Sunday',
};

/// Shows [date]'s (default: today's) day-specific wazifa (see
/// DailyWazifaService) and its virtue, with a "Start Counting" action
/// straight into the existing Dhikr Counter - opened from the morning
/// reminder notification. [date] is exposed mainly for tests; callers
/// normally omit it to show today's.
Future<void> showDailyWazifaDialog(BuildContext context, {DateTime? date}) {
  final resolvedDate = date ?? DateTime.now();
  final wazifa = DailyWazifaService.forDate(resolvedDate);
  final dayName = _dayNames[resolvedDate.weekday]!;

  return showDialog(
    context: context,
    builder: (context) => _DailyWazifaDialog(dayName: dayName, wazifa: wazifa),
  );
}

class _DailyWazifaDialog extends StatelessWidget {
  final String dayName;
  final Dhikr wazifa;

  const _DailyWazifaDialog({required this.dayName, required this.wazifa});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final accent = AppTheme.legibleAccent(context, AppTheme.primaryAmber);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.wb_sunny_outlined, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$dayName's Wazifa",
              style: TextStyle(color: onSurface),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wazifa.arabic,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: onSurface,
                height: 1.8,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            Text(
              wazifa.transliteration,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              wazifa.translation,
              style: TextStyle(
                fontSize: 13,
                color: onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textDirection: autoTextDirection(wazifa.translation),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                wazifa.meaning,
                style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.75),
                  height: 1.4,
                ),
                textDirection: autoTextDirection(wazifa.meaning),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: accent),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              AppTransitions.slideIn(DhikrCounterScreen(dhikr: wazifa)),
            );
          },
          icon: const Icon(Icons.touch_app, size: 18),
          label: const Text('Start Counting'),
        ),
      ],
    );
  }
}
