import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:prayerly/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_settings_provider.dart';
import '../widgets/prayer_times/index.dart';

/// Prayer times screen.
///
/// Everything on this screen is computed on-device. The load sequence is
/// ordered so that a network outage can only ever degrade the *labels*, never
/// the times themselves:
///
///   1. paint immediately from the last persisted location (if any)
///   2. resolve a location - guaranteed to succeed, possibly from cache
///   3. calculate prayer times locally
///   4. best-effort extras (address text, elevation) that may fail silently
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with WidgetsBindingObserver {
  // Timers
  Timer? _timeUpdateTimer;
  Timer? _dailyUpdateTimer;

  // Data
  LocationData? _locationData;
  PrayerTimesData? _prayerTimesData;
  PrayerStatus? _prayerStatus;
  double? _elevation;
  DateTime _currentTime = DateTime.now();
  DateTime? _lastCalculatedFor;

  // State
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  bool _isLoadingElevation = false;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupTimers();
    _initializeServices();
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeUpdateTimer?.cancel();
    _dailyUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _tick();
    }
  }

  /// Initialize both notification services
  Future<void> _initializeServices() async {
    try {
      await AdhanService.initialize();
      await ReminderService.initialize();
      await NotificationService.initialize();

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: AdhanService.onNotificationTap,
      );

      final enabled = await NotificationService.areNotificationsEnabled();
      if (mounted) {
        setState(() => _notificationsEnabled = enabled);
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  /// Sets up periodic timers for updates - OPTIMIZED for performance
  void _setupTimers() {
    // 30s is enough granularity for a countdown shown to the minute.
    _timeUpdateTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _tick());

    // Cheap safety net in case the app is left open across midnight.
    _dailyUpdateTimer =
        Timer.periodic(const Duration(hours: 1), (_) => _tick());
  }

  /// Advances the clock, and recalculates when the day has rolled over.
  void _tick() {
    if (!mounted) return;

    setState(() => _currentTime = DateTime.now());
    _updatePrayerStatus();

    if (_needsRecalculation()) {
      _calculatePrayerTimes();
    }
  }

  /// Loads all data. Only the first two steps can affect whether the screen
  /// renders; the rest are decorative and are allowed to fail.
  Future<void> _initializeApp({bool forceRefresh = false}) async {
    if (!mounted) return;

    setState(() => _isLoadingLocation = true);

    // Paint with whatever we already know before touching the GPS.
    if (!forceRefresh && _locationData == null) {
      final cached = await LocationService.cachedLocation();
      if (cached != null && mounted) {
        setState(() => _locationData = cached);
        await _calculatePrayerTimes();
      }
    }

    try {
      final location = await LocationService.resolve(
        context: mounted ? context : null,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;

      setState(() {
        _locationData = location;
        _isLoadingLocation = false;
      });

      // Critical path ends here: we have coordinates, so we have times.
      await _calculatePrayerTimes();
    } catch (e) {
      // resolve() is contractually non-throwing; this is belt and braces.
      debugPrint('Error resolving location: $e');
      if (mounted) setState(() => _isLoadingLocation = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    // Best-effort enrichment. Failures here never reach the user.
    unawaited(_resolveAddress());
    unawaited(_fetchElevation());
  }

  /// Reverse geocoding runs off the critical path: it needs a network, and a
  /// failure must not cost us the prayer times. This is the fix for the screen
  /// showing an error state while offline.
  Future<void> _resolveAddress() async {
    final location = _locationData;
    if (location == null || !mounted) return;
    if (location.source == LocationSource.fallback) return;

    final l10n = AppLocalizations.of(context)!;
    final enriched = await LocationService.withAddress(
      location,
      unknownLabel: l10n.unknownLocation,
    );

    if (!mounted) return;
    // Guard against a refresh having replaced the location mid-lookup.
    if (_locationData?.coarseKey != location.coarseKey) return;

    setState(() => _locationData = enriched);
  }

  /// Fetches elevation data (cached/offline; contributes to display only)
  Future<void> _fetchElevation() async {
    final location = _locationData;
    if (location == null || !mounted) return;

    setState(() => _isLoadingElevation = true);

    try {
      final elevation = await ElevationService.getElevation(
        location.latitude,
        location.longitude,
      );
      if (mounted) {
        setState(() {
          _elevation = elevation;
          _isLoadingElevation = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching elevation: $e');
      if (mounted) setState(() => _isLoadingElevation = false);
    }
  }

  /// Calculates prayer times locally for the resolved location.
  Future<void> _calculatePrayerTimes() async {
    final location = _locationData;
    if (location == null || !mounted) return;

    try {
      final data = await PrayerService.getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (!mounted) return;

      setState(() {
        _prayerTimesData = data;
        _lastCalculatedFor = DateTime.now();
      });

      if (mounted) {
        context.read<ReminderSettingsProvider>().updatePrayerTimes(data.prayerTimes);
      }

      _updatePrayerStatus();

      if (_notificationsEnabled) {
        await _scheduleNotifications();
      }
    } catch (e) {
      debugPrint('Error calculating prayer times: $e');
    }
  }

  /// Schedule notifications for prayer times using AdhanService
  Future<void> _scheduleNotifications() async {
    if (_prayerTimesData?.prayerTimes.isEmpty ?? true) return;

    try {
      final notificationSettings = await AdhanService.getNotificationSettings();
      await AdhanService.scheduleAdhanNotifications(
        _prayerTimesData!.prayerTimes,
        notificationSettings,
      );
      await ReminderService.scheduleReminders(_prayerTimesData!.prayerTimes);
      debugPrint('Adhan notifications and reminders scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  /// Updates current prayer status
  void _updatePrayerStatus() {
    final times = _prayerTimesData?.prayerTimes;
    if (times == null || times.isEmpty || !mounted) return;

    final status = PrayerService.getCurrentPrayerStatus(times, _currentTime);
    setState(() => _prayerStatus = status);
  }

  /// True when the calculated day no longer matches today.
  bool _needsRecalculation() {
    if (_prayerTimesData?.prayerTimes.isEmpty ?? true) return true;

    final last = _lastCalculatedFor;
    if (last == null) return true;

    final now = DateTime.now();
    return now.day != last.day ||
        now.month != last.month ||
        now.year != last.year;
  }

  /// Refreshes all data, forcing a new location fix.
  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _initializeApp(forceRefresh: true);
  }

  /// Toggle notifications
  Future<void> _toggleNotifications() async {
    final l10n = AppLocalizations.of(context)!;
    if (_notificationsEnabled) {
      await AdhanService.cancelAllNotifications();
      await ReminderService.cancelAll();
      if (mounted) {
        setState(() => _notificationsEnabled = false);
        _showSnackBar(l10n.notificationsDisabled);
      }
    } else {
      final enabled = await NotificationService.requestPermissions();
      if (!mounted) return;

      if (enabled) {
        setState(() => _notificationsEnabled = true);
        await _scheduleNotifications();
        if (mounted) _showSnackBar(l10n.notificationsEnabled);
      } else {
        _showSnackBar(l10n.notificationPermissionDenied);
      }
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show custom menu
  void _showCustomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuBottomSheet(),
    );
  }

  /// Show info dialog
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => InfoDialogWidget(
        locationData: _locationData,
        prayerTimesData: _prayerTimesData,
        elevation: _elevation,
        notificationsEnabled: _notificationsEnabled,
        onToggleNotifications: _toggleNotifications,
      ),
    );
  }

  /// Format current date for display
  String get _formattedCurrentDate {
    return "${_currentTime.day.toString().padLeft(2, '0')}/${_currentTime.month.toString().padLeft(2, '0')}/${_currentTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PrayerTimesAppBar(
        notificationsEnabled: _notificationsEnabled,
        onToggleNotifications: _toggleNotifications,
        onRefresh: _refreshData,
        onShowInfo: _showInfoDialog,
        onShowMenu: _showCustomMenu,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final location = _locationData;
    final times = _prayerTimesData;
    final status = _prayerStatus;

    if (location != null && times != null && status != null) {
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: MainContentWidget(
          locationData: location,
          prayerTimesData: times,
          prayerStatus: status,
          currentTime: _currentTime,
          formattedCurrentDate: _formattedCurrentDate,
          elevation: _elevation,
          isLoadingElevation: _isLoadingElevation,
        ),
      );
    }

    if (_isLoading) {
      return LoadingWidget(isLoadingLocation: _isLoadingLocation);
    }

    return ErrorWidget(
      locationData: location,
      prayerTimesData: times,
      onRetry: _refreshData,
    );
  }
}
