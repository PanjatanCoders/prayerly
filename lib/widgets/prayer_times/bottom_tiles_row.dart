import 'package:flutter/material.dart';

/// The "Today's Verse" / "Next Prayer" tile pair beneath the prayer list.
/// The verse text is the same translation this app has always shown
/// (previously on the welcome screen, before it was replaced by the plain
/// splash screen) - reused verbatim rather than rotating through a
/// hand-picked pool, since an unreviewed translation risks misquoting the
/// Qur'an.
class BottomTilesRow extends StatelessWidget {
  final String nextPrayer;
  final Duration timeRemaining;

  const BottomTilesRow({
    super.key,
    required this.nextPrayer,
    required this.timeRemaining,
  });

  String _formatTimeRemaining(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:"
        "${(duration.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(flex: 6, child: _VerseTile()),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: _NextPrayerTile(
              nextPrayer: nextPrayer,
              formattedTimeRemaining: _formatTimeRemaining(timeRemaining),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, size: 14, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  "Today's Verse",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            '"Verily, prayer restrains from immorality and wrongdoing."',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            "— Qur'an 29:45",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPrayerTile extends StatelessWidget {
  final String nextPrayer;
  final String formattedTimeRemaining;

  const _NextPrayerTile({
    required this.nextPrayer,
    required this.formattedTimeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _nextPrayerCardBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Next Prayer',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.wb_sunny, size: 16, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            nextPrayer,
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formattedTimeRemaining,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            'remaining',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tinted card background for the Next Prayer tile - a warm cream tone in
/// light mode (matching the reference), the theme's card color in dark mode.
Color _nextPrayerCardBackground(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Theme.of(context).cardColor : const Color(0xFFFCEEDD);
}
