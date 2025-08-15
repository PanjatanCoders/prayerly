// widgets/prayer_times/timer_section_widget.dart
import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../circular_timer_widget.dart';
import '../info_card_widget.dart';

class TimerSectionWidget extends StatelessWidget {
  final LocationData locationData;
  final PrayerTimesData prayerTimesData;
  final PrayerStatus prayerStatus;
  final DateTime currentTime;
  final String formattedCurrentDate;
  final double? elevation;
  final bool isLoadingElevation;

  const TimerSectionWidget({
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
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Circular Timer
        CircularTimerWidget(
          nextPrayer: prayerStatus.nextPrayer,
          timeRemaining: prayerStatus.timeRemaining,
          currentTime: currentTime,
          progress: prayerStatus.progress,
        ),
        
        const SizedBox(width: 16),
        
        // Info Card
        Expanded(
          child: InfoCardWidget(
            location: locationData.address,
            islamicDate: prayerTimesData.islamicDate,
            currentDate: formattedCurrentDate,
            elevation: elevation,
            isLoadingElevation: isLoadingElevation,
          ),
        ),
      ],
    );
  }
}