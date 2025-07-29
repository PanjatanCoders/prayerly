import 'package:flutter/material.dart';
import '../utils/circular_progress_painter.dart';
import '../services/prayer_service.dart';

class CircularTimerWidget extends StatelessWidget {
  final String nextPrayer;
  final Duration timeRemaining;
  final DateTime currentTime;
  final double progress;
  final double size;

  const CircularTimerWidget({
    super.key,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.currentTime,
    required this.progress,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('timer_${currentTime.millisecondsSinceEpoch}'),
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress circle (this is your only circle now)
          CustomPaint(
            key: ValueKey('progress_${progress}_$nextPrayer'),
            size: Size(size, size),
            painter: CircularProgressPainter(
              progress: progress,
              color: _getPrayerColor(nextPrayer),
            ),
          ),

          // Timer content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Next prayer name
              Text(
                nextPrayer,
                key: ValueKey('prayer_$nextPrayer'),
                style: TextStyle(
                  color: _getPrayerColor(nextPrayer),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Time remaining
              Text(
                _formatTimeRemaining(timeRemaining),
                key: ValueKey('remaining_${timeRemaining.inSeconds}'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Current time
              Text(
                PrayerService.formatCurrentTime(currentTime),
                key: ValueKey('current_${currentTime.millisecondsSinceEpoch}'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats time remaining as HH:MM:SS
  String _formatTimeRemaining(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:"
        "${(duration.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  /// Gets color for each prayer
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