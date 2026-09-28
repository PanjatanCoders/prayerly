import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/location_service.dart';
import '../../services/prayer_service.dart';
import '../prayer_times_list_widget.dart';
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
      // Always scrollable so pull-to-refresh works even when the content
      // happens to fit on screen.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HeroStatusCard(
            locationData: locationData,
            prayerTimesData: prayerTimesData,
            prayerStatus: prayerStatus,
            currentTime: currentTime,
            formattedCurrentDate: formattedCurrentDate,
            elevation: elevation,
            isLoadingElevation: isLoadingElevation,
          ),
          const SizedBox(height: 12),

          const OccasionBannerWidget(),

          if (!locationData.isTrustworthy) ...[
            const SizedBox(height: 12),
            _LocationNotice(locationData: locationData),
          ],

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
