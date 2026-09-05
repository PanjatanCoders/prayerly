import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/location_data.dart';
import '../../models/qibla_data.dart';
import '../../services/compass_service.dart';
import '../../services/qibla_service.dart';
import '../../utils/theme/app_theme.dart';
import '../../widgets/compass/compass_widget.dart';
import '../../widgets/compass/loading_error_widgets.dart';
import '../../widgets/compass/qibla_info_widget.dart';

/// Qibla compass.
///
/// Lifecycle rules that the previous version got wrong:
///
///  * the location is resolved **once** per session, not twice (it used to be
///    fetched for the initial reading and again inside the stream);
///  * the sensor is only subscribed while the screen is actually on top, so
///    sitting on another tab of the [IndexedStack] no longer keeps the
///    magnetometer running;
///  * a missing compass degrades to a bearing read-out instead of an error.
class QiblaCompassScreen extends StatefulWidget {
  /// Whether this screen is the visible tab. The shell keeps every tab alive
  /// in an [IndexedStack], so without this the sensor would never stop.
  final bool isActive;

  const QiblaCompassScreen({super.key, this.isActive = true});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with WidgetsBindingObserver {
  QiblaReading? _reading;
  QiblaFailure? _failure;
  bool _isLoading = true;

  LocationData? _location;
  StreamSubscription<QiblaReading>? _subscription;

  /// Set once the sensor has been silent long enough to call it missing.
  bool _compassTimedOut = false;
  Timer? _compassWatchdog;

  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didUpdateWidget(covariant QiblaCompassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncSubscription();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isForeground = state == AppLifecycleState.resumed;
    _syncSubscription();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassWatchdog?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  bool get _shouldListen => widget.isActive && _isForeground;

  Future<void> _initialize({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _failure = null;
    });

    try {
      final location = await QiblaService.resolveLocation(
        context: mounted ? context : null,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;

      _location = location;
      setState(() => _isLoading = false);
      _syncSubscription();
    } on QiblaException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _failure = e.failure;
      });
    } catch (e) {
      debugPrint('QiblaCompassScreen: initialization failed ($e)');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _failure = QiblaFailure.locationUnavailable;
      });
    }
  }

  /// Starts or stops the sensor to match visibility.
  void _syncSubscription() {
    final location = _location;

    if (!_shouldListen || location == null) {
      _subscription?.cancel();
      _subscription = null;
      _compassWatchdog?.cancel();
      return;
    }

    if (_subscription != null) return;

    _subscription = QiblaService.watch(location).listen((reading) {
      if (!mounted) return;
      if (reading.hasHeading) {
        _compassWatchdog?.cancel();
        if (_compassTimedOut) _compassTimedOut = false;
      }

      // Re-subscribing (returning to the tab) starts with a heading-less
      // frame. Carry the last known heading over so the dial does not flash
      // back to "reading compass" for one frame.
      final previous = _reading;
      final next = !reading.hasHeading && (previous?.hasHeading ?? false)
          ? reading.copyWith(
              heading: previous!.heading,
              accuracy: previous.accuracy,
            )
          : reading;

      setState(() => _reading = next);
    });

    // If nothing arrives in this window the device almost certainly has no
    // usable magnetometer. Watching the real stream is more reliable than the
    // old approach of opening a second probe subscription just to find out.
    if (!CompassService.isSupported) {
      _compassTimedOut = true;
    } else {
      _compassWatchdog?.cancel();
      _compassWatchdog = Timer(const Duration(seconds: 4), () {
        if (!mounted || (_reading?.hasHeading ?? false)) return;
        setState(() => _compassTimedOut = true);
      });
    }
  }

  Future<void> _refresh() async {
    _subscription?.cancel();
    _subscription = null;
    _compassWatchdog?.cancel();
    _compassTimedOut = false;
    await _initialize(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.qiblaCompass,
          style: AppTheme.subheadingStyle(context).copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.islamicColors['qibla'],
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refresh,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return QiblaLoadingWidget(message: l10n.finderTitle);
    }

    final failure = _failure;
    if (failure != null) {
      return QiblaErrorWidget(failure: failure, onRetry: _refresh);
    }

    final reading = _reading;
    if (reading == null) {
      return QiblaLoadingWidget(message: l10n.waitingForCompass);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        children: [
          if (_compassTimedOut) const CompassUnavailableBanner(),
          if (reading.needsCalibration) const CompassCalibrationBanner(),

          Center(child: CompassWidget(reading: reading)),
          const SizedBox(height: 20),

          QiblaGuidanceBanner(reading: reading),
          QiblaInfoWidget(reading: reading),

          _InstructionsCard(showSensorSteps: !_compassTimedOut),
        ],
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  final bool showSensorSteps;

  const _InstructionsCard({required this.showSensorSteps});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final steps = <(IconData, String)>[
      if (showSensorSteps) ...[
        (Icons.phone_android, l10n.holdDeviceFlat),
        (Icons.rotate_right, l10n.rotateUntilMarker),
        (Icons.explore, l10n.faceDirection),
        (Icons.place, l10n.facingQibla),
      ],
      (Icons.sensors_off, l10n.avoidInterference),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.howToUse,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final (icon, text) in steps) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
