import 'package:flutter/material.dart';

import 'circular_progress_painter.dart';

class CircularTimerWidget extends StatelessWidget {
  final String nextPrayer;
  final Duration timeRemaining;
  final double Function() getTimerProgress; // Function returning progress 0.0-1.0
  final Color Function(String) getPrayerColor; // Function that returns color for a given prayer name
  final String Function() formatCurrentTime; // Function that returns formatted current time

  const CircularTimerWidget({
    Key? key,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.getTimerProgress,
    required this.getPrayerColor,
    required this.formatCurrentTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double size = 200;
    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Progress circle
          CustomPaint(
            size: Size(size, size),
            painter: CircularProgressPainter(
              progress: getTimerProgress(),
              color: getPrayerColor(nextPrayer),
            ),
          ),
          // Timer text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nextPrayer,
                style: TextStyle(
                  color: getPrayerColor(nextPrayer),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${timeRemaining.inHours.toString().padLeft(2, '0')}:"
                    "${(timeRemaining.inMinutes % 60).toString().padLeft(2, '0')}:"
                    "${(timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrentTime(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
