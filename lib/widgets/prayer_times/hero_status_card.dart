// widgets/prayer_times/hero_status_card.dart
import 'package:flutter/material.dart';

import '../../screens/adhan_settings_screen.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../../services/weather_service.dart';
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
  final WeatherSnapshot? weather;
  final bool isLoadingWeather;
  final double minHeight;

  const HeroStatusCard({
    super.key,
    required this.locationData,
    required this.prayerTimesData,
    required this.prayerStatus,
    required this.currentTime,
    required this.formattedCurrentDate,
    this.weather,
    this.isLoadingWeather = false,
    this.minHeight = 172,
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
        // On a tall screen, MainContentWidget passes a taller minHeight so
        // the hero photo grows to use some of the extra vertical space - a
        // bigger photo reads as intentional, unlike stretched gaps lower on
        // the screen (see MainContentWidget for the full reasoning).
        constraints: BoxConstraints(minHeight: widget.minHeight),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hero_prayer_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Row(
          // Centered, not start-aligned, so the countdown ring sits centered
          // against the location/date card beside it rather than pinned to
          // its top edge - matters whenever the card's content (a longer
          // address, or the "location not trustworthy" notice) makes it
          // taller or shorter than the ring.
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _LocationDateCard(
                locationData: widget.locationData,
                prayerTimesData: widget.prayerTimesData,
                formattedCurrentDate: widget.formattedCurrentDate,
                weather: widget.weather,
                isLoadingWeather: widget.isLoadingWeather,
              ),
            ),
            const SizedBox(width: 14),
            CircularTimerWidget(
              nextPrayer: widget.prayerStatus.nextPrayer,
              timeRemaining: widget.prayerStatus.timeRemaining,
              currentTime: widget.currentTime,
              progress: widget.prayerStatus.progress,
              prayerTimes: widget.prayerTimesData.prayerTimes,
              weather: widget.weather,
              size: 128,
            ),
          ],
        ),
      ),
    );
  }
}

/// The semi-opaque card over the hero photo: location, Gregorian/Hijri date,
/// current weather/temperature, and the current Asr calculation method.
class _LocationDateCard extends StatelessWidget {
  final LocationData locationData;
  final PrayerTimesData prayerTimesData;
  final String formattedCurrentDate;
  final WeatherSnapshot? weather;
  final bool isLoadingWeather;

  const _LocationDateCard({
    required this.locationData,
    required this.prayerTimesData,
    required this.formattedCurrentDate,
    required this.weather,
    required this.isLoadingWeather,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
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
            weather: weather,
            isLoadingWeather: isLoadingWeather,
          ),
          const SizedBox(height: 8),
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
          padding: EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings, size: 12, color: Colors.black87),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Asr: Hanafi',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 2),
              Icon(Icons.chevron_right, size: 14, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
