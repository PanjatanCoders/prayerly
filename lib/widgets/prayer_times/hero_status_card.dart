// widgets/prayer_times/hero_status_card.dart
import 'package:flutter/material.dart';

import '../../screens/adhan_settings_screen.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../../utils/theme/app_transitions.dart';
import '../circular_timer_widget.dart';
import '../info_card_widget.dart';

/// The hero section at the top of the prayer times screen: a full-bleed
/// photo backdrop with the location/date/elevation card and the countdown
/// ring floating on top of it.
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
        constraints: const BoxConstraints(minHeight: 260),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hero_prayer_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LocationDateCard(
                locationData: widget.locationData,
                prayerTimesData: widget.prayerTimesData,
                formattedCurrentDate: widget.formattedCurrentDate,
                elevation: widget.elevation,
                isLoadingElevation: widget.isLoadingElevation,
              ),
            ),
            const SizedBox(width: 16),
            CircularTimerWidget(
              nextPrayer: widget.prayerStatus.nextPrayer,
              timeRemaining: widget.prayerStatus.timeRemaining,
              currentTime: widget.currentTime,
              progress: widget.prayerStatus.progress,
              prayerTimes: widget.prayerTimesData.prayerTimes,
              size: 170,
            ),
          ],
        ),
      ),
    );
  }
}

/// The semi-opaque card over the hero photo: location, Gregorian/Hijri date,
/// elevation, and the current Asr calculation method.
class _LocationDateCard extends StatelessWidget {
  final LocationData locationData;
  final PrayerTimesData prayerTimesData;
  final String formattedCurrentDate;
  final double? elevation;
  final bool isLoadingElevation;

  const _LocationDateCard({
    required this.locationData,
    required this.prayerTimesData,
    required this.formattedCurrentDate,
    required this.elevation,
    required this.isLoadingElevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoCardWidget(
            location: locationData.address,
            islamicDate: prayerTimesData.islamicDate,
            currentDate: formattedCurrentDate,
            elevation: elevation,
            isLoadingElevation: isLoadingElevation,
          ),
          const SizedBox(height: 12),
          _AsrMethodPill(
            onTap: () => Navigator.push(
              context,
              AppTransitions.slideIn(const AdhanSettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AsrMethodPill extends StatelessWidget {
  final VoidCallback onTap;

  const _AsrMethodPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings, size: 14, color: Colors.black87),
              SizedBox(width: 6),
              Text(
                'Asr: Hanafi',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
