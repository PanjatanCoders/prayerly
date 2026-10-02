import 'package:flutter/material.dart';

import '../models/dhikr_models.dart';
import '../services/dhikr_data_service.dart';
import '../utils/bidi_utils.dart';
import '../utils/theme/app_theme.dart';

/// Shows "Shab-e-Jumu'ah ka Durood Paak" - the specific Durood Sharif this
/// app prompts for on Jumu'ah (both the Friday notification and the home
/// screen's Jumu'ah Mubarak banner open this same dialog). The text itself
/// lives once in [DhikrDataService] (id `salawat_shab_e_jumuah`) so the
/// Dhikr Counter and this prompt never drift apart.
Future<void> showJumuahDuroodDialog(BuildContext context) {
  final durood = DhikrDataService.getAllDhikr()
      .firstWhere((d) => d.id == 'salawat_shab_e_jumuah');

  return showDialog(
    context: context,
    builder: (context) => _JumuahDuroodDialog(durood: durood),
  );
}

class _JumuahDuroodDialog extends StatelessWidget {
  final Dhikr durood;

  const _JumuahDuroodDialog({required this.durood});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final accent = AppTheme.legibleAccent(context, AppTheme.primaryAmber);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.mosque, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Jumu'ah Mubarak",
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
              "Shab-e-Jumu'ah ka Durood Paak",
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              durood.arabic,
              style: TextStyle(
                fontSize: 22,
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
              durood.transliteration,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              durood.translation,
              style: TextStyle(
                fontSize: 13,
                color: onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textDirection: autoTextDirection(durood.translation),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                durood.meaning,
                style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.75),
                  height: 1.4,
                ),
                textDirection: autoTextDirection(durood.meaning),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ameen'),
        ),
      ],
    );
  }
}
