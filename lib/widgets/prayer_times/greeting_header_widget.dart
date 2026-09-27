import 'package:flutter/material.dart';

import '../../utils/theme/app_theme.dart';

/// A greeting card that changes its wording, icon and mood with the time of
/// day - dawn, morning, afternoon, sunset, night - and eases in once when
/// first built. The tint is a low-alpha overlay on the theme's own card
/// color rather than a solid saturated fill, so it stays legible in both
/// light and dark mode without per-theme tuning.
class GreetingHeaderWidget extends StatefulWidget {
  final String hijriDate;

  const GreetingHeaderWidget({super.key, required this.hijriDate});

  @override
  State<GreetingHeaderWidget> createState() => _GreetingHeaderWidgetState();
}

class _GreetingHeaderWidgetState extends State<GreetingHeaderWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entrance;
  late final AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _entrance = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = _MoodOfTheDay.forHour(DateTime.now().hour);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tint = AppTheme.legibleAccent(context, mood.tint);

    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, child) {
        return Opacity(
          opacity: _entrance.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _entrance.value) * 16),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mood.tint.withValues(alpha: 0.16),
              Theme.of(context).cardColor,
            ],
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                final scale = 1.0 + (_breatheController.value * 0.08);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mood.tint.withValues(alpha: 0.18),
                ),
                child: Icon(mood.icon, color: tint, size: 26),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mood.arabicGreeting,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mood.englishGreeting,
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.hijriDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: tint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodOfTheDay {
  final String arabicGreeting;
  final String englishGreeting;
  final IconData icon;
  final Color tint;

  const _MoodOfTheDay({
    required this.arabicGreeting,
    required this.englishGreeting,
    required this.icon,
    required this.tint,
  });

  factory _MoodOfTheDay.forHour(int hour) {
    if (hour >= 4 && hour < 6) {
      return const _MoodOfTheDay(
        arabicGreeting: 'صباح الفجر',
        englishGreeting: 'A blessed dawn to you',
        icon: Icons.wb_twilight,
        tint: Color(0xFF5C6BC0),
      );
    }
    if (hour >= 6 && hour < 12) {
      return const _MoodOfTheDay(
        arabicGreeting: 'صباح الخير',
        englishGreeting: 'Good morning',
        icon: Icons.wb_sunny,
        tint: Color(0xFFFFA000),
      );
    }
    if (hour >= 12 && hour < 17) {
      return const _MoodOfTheDay(
        arabicGreeting: 'مساء الخير',
        englishGreeting: 'Good afternoon',
        icon: Icons.wb_sunny_outlined,
        tint: Color(0xFF1E88E5),
      );
    }
    if (hour >= 17 && hour < 19) {
      return const _MoodOfTheDay(
        arabicGreeting: 'مساء النور',
        englishGreeting: 'A peaceful evening to you',
        icon: Icons.brightness_4,
        tint: Color(0xFFEF6C00),
      );
    }
    return const _MoodOfTheDay(
      arabicGreeting: 'ليلة سعيدة',
      englishGreeting: 'A peaceful night to you',
      icon: Icons.nights_stay,
      tint: Color(0xFF7E57C2),
    );
  }
}
