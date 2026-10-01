import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../../services/weather_service.dart';
import '../prayer_times_list_widget.dart';
import 'bottom_tiles_row.dart';
import 'hero_status_card.dart';
import 'occasion_banner_widget.dart';

class MainContentWidget extends StatelessWidget {
  final LocationData locationData;
  final PrayerTimesData prayerTimesData;
  final PrayerStatus prayerStatus;
  final DateTime currentTime;
  final String formattedCurrentDate;
  final double? elevation;
  final bool isLoadingElevation;
  final WeatherSnapshot? weather;

  const MainContentWidget({
    super.key,
    required this.locationData,
    required this.prayerTimesData,
    required this.prayerStatus,
    required this.currentTime,
    required this.formattedCurrentDate,
    required this.elevation,
    required this.isLoadingElevation,
    this.weather,
  });

  // On an ordinary day (no occasion banner, trustworthy location - the
  // common case), this screen's real content is roughly 550-600dp tall:
  // hero + Prayer Times card + Today's Verse/Next Prayer row. Measured
  // against an actual device screenshot from this project (691x1536,
  // ~868dp logical height), that content was barely 45% of the available
  // body height. Forcing the remaining ~55% into a single gap (whether
  // spread between sections or collected in one place) produced a gap of
  // 700-900dp on that device - clearly wrong regardless of *where* it's
  // placed, so this screen does not try to force-fill the viewport at all
  // any more. Instead: the hero photo grows moderately with the available
  // height (a bigger photo reads as intentional, unlike a stretched gap),
  // and the lower section keeps a fixed, deliberate gap before Today's
  // Verse/Next Prayer. Any space still left over after that shows as the
  // plain background below the cards - same color as the cards themselves
  // (see PrayerTimesScreen's Scaffold.backgroundColor), so it reads as
  // ordinary bottom breathing room rather than a mismatched void.
  static const double _minHeroHeight = 172;
  static const double _maxHeroHeight = 380;
  static const double _heroHeightFraction = 0.38;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final heroHeight = outerConstraints.hasBoundedHeight
            ? (outerConstraints.maxHeight * _heroHeightFraction)
                .clamp(_minHeroHeight, _maxHeroHeight)
            : _minHeroHeight;

        return SingleChildScrollView(
          // Always scrollable so pull-to-refresh still works, and so a
          // device too short for even this content scrolls instead of
          // overflowing.
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full-bleed: the hero photo needs to reach both edges, so it
              // sits outside the padded section below rather than inside it.
              HeroStatusCard(
                locationData: locationData,
                prayerTimesData: prayerTimesData,
                prayerStatus: prayerStatus,
                currentTime: currentTime,
                formattedCurrentDate: formattedCurrentDate,
                elevation: elevation,
                isLoadingElevation: isLoadingElevation,
                weather: weather,
                minHeight: heroHeight,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                transform: Matrix4.translationValues(0, -20, 0),
                // Horizontal margin matches HeroStatusCard's (14) so the
                // Prayer Times card and Today's Verse/Next Prayer cards sit
                // on the same vertical edge as the hero card above them -
                // one shared content margin for the whole screen.
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const OccasionBannerWidget(),

                    if (!locationData.isTrustworthy) ...[
                      const SizedBox(height: 6),
                      _LocationNotice(locationData: locationData),
                    ],

                    const SizedBox(height: 8),

                    // Prayer Times List
                    PrayerTimesListWidget(
                      prayerTimes: prayerTimesData.prayerTimes,
                      currentPrayer: prayerStatus.currentPrayer,
                      nextPrayer: prayerStatus.nextPrayer,
                    ),

                    // Deliberate section-spacing value (the 32dp "major
                    // section spacing" tier) between the Prayer Times card
                    // and Today's Verse/Next Prayer - fixed rather than
                    // stretched to fill whatever space
                    // happens to be left, per the reasoning above.
                    const SizedBox(height: 32),

                    BottomTilesRow(
                      nextPrayer: prayerStatus.nextPrayer,
                      timeRemaining: prayerStatus.timeRemaining,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tells the user when the times on screen were calculated from a stored or
/// stand-in position rather than a live fix - the honest counterpart to the
/// offline fallback in [LocationService].
class _LocationNotice extends StatelessWidget {
  final LocationData locationData;

  const _LocationNotice({required this.locationData});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFallback = locationData.source == LocationSource.fallback;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (isFallback ? Colors.orange : Colors.blueGrey)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isFallback ? Colors.orange : Colors.blueGrey)
              .withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFallback ? Icons.location_off : Icons.history,
            size: 18,
            color: isFallback ? Colors.orange[300] : Colors.blueGrey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isFallback
                  ? l10n.locationNoticeDefault
                  : l10n.locationNoticeSaved,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
