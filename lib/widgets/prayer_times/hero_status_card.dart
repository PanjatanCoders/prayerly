// widgets/prayer_times/hero_status_card.dart
import 'package:flutter/material.dart';

import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../circular_timer_widget.dart';
import '../info_card_widget.dart';
import 'greeting_header_widget.dart';

/// The single "hero" card at the top of the prayer times screen: greeting +
/// Hijri date, the sun/moon countdown ring, and location/date/elevation, all
/// sharing one card and one entrance animation instead of three separate
/// floating pieces.
class HeroStatusCard extends StatefulWidget {
  final LocationData locationData;
  final PrayerTimesData prayerTimesData;
  final PrayerStatus prayerStatus;
  final DateTime currentTime;
  final String formattedCurrentDate;
  final double? elevation;
  final bool isLoadingElevation;

  const HeroStatusCard({
    super.key,
    required this.locationData,
    required this.prayerTimesData,
    required this.prayerStatus,
    required this.currentTime,
    required this.formattedCurrentDate,
    required this.elevation,
    required this.isLoadingElevation,
  });

  @override
  State<HeroStatusCard> createState() => _HeroStatusCardState();
}

class _HeroStatusCardState extends State<HeroStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entrance;

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
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingHeaderWidget(hijriDate: widget.prayerTimesData.islamicDate),
            const SizedBox(height: 16),
            Divider(height: 1, color: onSurface.withValues(alpha: 0.08)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularTimerWidget(
                  nextPrayer: widget.prayerStatus.nextPrayer,
                  timeRemaining: widget.prayerStatus.timeRemaining,
                  currentTime: widget.currentTime,
                  progress: widget.prayerStatus.progress,
                  prayerTimes: widget.prayerTimesData.prayerTimes,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InfoCardWidget(
                    location: widget.locationData.address,
                    islamicDate: widget.prayerTimesData.islamicDate,
                    currentDate: widget.formattedCurrentDate,
                    elevation: widget.elevation,
                    isLoadingElevation: widget.isLoadingElevation,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
