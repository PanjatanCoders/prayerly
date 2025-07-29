import 'package:flutter/material.dart';

import 'circular_progress_painter.dart';

class CircularTimerWidget extends StatefulWidget {
  final String nextPrayer;
  final Duration timeRemaining;
  final double Function() getTimerProgress;
  final Color Function(String) getPrayerColor;
  final String Function() formatCurrentTime;

  const CircularTimerWidget({
    Key? key,
    required this.nextPrayer,
    required this.timeRemaining,
    required this.getTimerProgress,
    required this.getPrayerColor,
    required this.formatCurrentTime,
  }) : super(key: key);

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget> {
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
              progress: widget.getTimerProgress(),
              color: widget.getPrayerColor(widget.nextPrayer),
            ),
          ),
          // Timer text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.nextPrayer,
                style: TextStyle(
                  color: widget.getPrayerColor(widget.nextPrayer),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${widget.timeRemaining.inHours.toString().padLeft(2, '0')}:"
                    "${(widget.timeRemaining.inMinutes % 60).toString().padLeft(2, '0')}:"
                    "${(widget.timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.formatCurrentTime(),
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