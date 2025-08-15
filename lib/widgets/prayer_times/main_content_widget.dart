import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../circular_timer_widget.dart';
import '../info_card_widget.dart';
import '../prayer_times_list_widget.dart';
import 'quick_actions_widget.dart'; // ADD THIS IMPORT

class MainContentWidget extends StatelessWidget {
  final LocationData locationData;
  final PrayerTimesData prayerTimesData;
  final PrayerStatus prayerStatus;
  final DateTime currentTime;
  final String formattedCurrentDate;
  final double? elevation;
  final bool isLoadingElevation;

  const MainContentWidget({
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top section with circular timer and info
          Row(
            children: [
              CircularTimerWidget(
                nextPrayer: prayerStatus.nextPrayer,
                timeRemaining: prayerStatus.timeRemaining,
                currentTime: currentTime,
                progress: prayerStatus.progress,
              ),
              const SizedBox(width: 16),
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
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions Section - NEW
          const QuickActionsWidget(),
          
          const SizedBox(height: 16),
          
          // Prayer Times List
          PrayerTimesListWidget(
            prayerTimes: prayerTimesData.prayerTimes,
            currentPrayer: prayerStatus.currentPrayer,
            nextPrayer: prayerStatus.nextPrayer,
          ),
        ],
      ),
    );
  }
}