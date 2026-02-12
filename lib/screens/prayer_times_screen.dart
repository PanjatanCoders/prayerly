import 'package:flutter/material.dart' hide ErrorWidget;
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:prayerly/l10n/app_localizations.dart';

import '../widgets/prayer_times/index.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Timers
  late Timer _timeUpdateTimer;
  late Timer _dailyUpdateTimer;

  // Data
  LocationData? _locationData;
  PrayerTimesData? _prayerTimesData;
  PrayerStatus? _prayerStatus;
  double? _elevation;
  DateTime _currentTime = DateTime.now();
  DateTime _lastFetchDate = DateTime.now();

  // State
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  bool _isLoadingElevation = false;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _setupTimers();
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeUpdateTimer.cancel();
    _dailyUpdateTimer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentTime();
      if (_shouldFetchNewPrayerTimes()) {
        _fetchPrayerTimes();
      }
    }
  }

  /// Initialize both notification services
  Future<void> _initializeServices() async {
    try {
      await AdhanService.initialize();
      await NotificationService.initialize();

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: AdhanService.onNotificationTap,
      );

      final enabled = await NotificationService.areNotificationsEnabled();
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
        });
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  /// Sets up periodic timers for updates - OPTIMIZED for performance
  void _setupTimers() {
    // Update every 30 seconds instead of 1 second for better battery life
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _currentTime = DateTime.now();
        _updatePrayerStatus();

        if (_shouldFetchNewPrayerTimes()) {
          _fetchPrayerTimes();
          _lastFetchDate = DateTime.now();
        }
        setState(() {});
      }
    });

    // Check for day change every hour
    _dailyUpdateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (mounted && _shouldFetchNewPrayerTimes()) {
        debugPrint('Daily update: Fetching new prayer times');
        _fetchPrayerTimes();
        _lastFetchDate = DateTime.now();
      }
    });
  }

  /// Initializes the app by loading all necessary data
  Future<void> _initializeApp() async {
    if (!mounted) return;

    try {
      await _getCurrentLocation();
      await _fetchPrayerTimes();
      
      if (_locationData != null) {
        await _fetchElevation();
      }

      _updatePrayerStatus();

      if (_prayerTimesData != null && _notificationsEnabled) {
        await _scheduleNotifications();
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Gets current location using LocationService
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await LocationService.getCurrentLocation(context: context);
      if (!mounted) return;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        locationData.latitude,
        locationData.longitude,
      );

      if (!mounted) return;

      final placemark = placemarks.first;
      String address = _buildAddressString(placemark);

      setState(() {
        _locationData = locationData.copyWith(address: address);
        _isLoadingLocation = false;
      });
    } catch (e) {
      debugPrint('Error getting location or address: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  /// Build address string from placemark
  String _buildAddressString(Placemark placemark) {
    String address = '';

    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      address = placemark.subLocality!;
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        address += ', ${placemark.locality}';
      }
    } else if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      address = placemark.thoroughfare!;
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        address += ', ${placemark.locality}';
      }
    } else if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      address = placemark.locality!;
      if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
        address += ', ${placemark.administrativeArea}';
      }
    } else if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      address = placemark.administrativeArea!;
    }

    if (placemark.country != null && placemark.country!.isNotEmpty) {
      address += ', ${placemark.country}';
    }

    final l10n = AppLocalizations.of(context)!;
    return address.isEmpty ? l10n.unknownLocation : address;
  }

  /// Fetches elevation data
  Future<void> _fetchElevation() async {
    if (_locationData == null || !mounted) return;

    setState(() {
      _isLoadingElevation = true;
    });

    try {
      final elevation = await ElevationService.getElevation(
        _locationData!.latitude,
        _locationData!.longitude,
      );

      if (mounted) {
        setState(() {
          _elevation = elevation;
          _isLoadingElevation = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching elevation: $e');
      if (mounted) {
        setState(() {
          _isLoadingElevation = false;
        });
      }
    }
  }

  /// Fetches prayer times using PrayerService
  Future<void> _fetchPrayerTimes() async {
    if (_locationData == null || !mounted) return;

    try {
      final prayerTimesData = await PrayerService.getPrayerTimes(
        latitude: _locationData!.latitude,
        longitude: _locationData!.longitude,
      );

      if (mounted) {
        setState(() {
          _prayerTimesData = prayerTimesData;
        });

        if (_notificationsEnabled) {
          await _scheduleNotifications();
        }
      }
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
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
      debugPrint('Adhan notifications scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  /// Updates current prayer status
  void _updatePrayerStatus() {
    if (_prayerTimesData?.prayerTimes.isEmpty ?? true) return;

    final status = PrayerService.getCurrentPrayerStatus(
      _prayerTimesData!.prayerTimes,
      _currentTime,
    );

    if (mounted) {
      setState(() {
        _prayerStatus = status;
      });
    }
  }

  /// Force refresh current time
  void _refreshCurrentTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateTime.now();
        _updatePrayerStatus();
      });
    }
  }

  /// Checks if new prayer times should be fetched
  bool _shouldFetchNewPrayerTimes() {
    final now = DateTime.now();
    final lastFetch = _lastFetchDate;

    return now.day != lastFetch.day ||
        now.month != lastFetch.month ||
        now.year != lastFetch.year ||
        (_prayerTimesData?.prayerTimes.isEmpty ?? true);
  }

  /// Refreshes all data
  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await _initializeApp();
  }

  /// Toggle notifications
  Future<void> _toggleNotifications() async {
    final l10n = AppLocalizations.of(context)!;
    if (_notificationsEnabled) {
      await AdhanService.cancelAllNotifications();
      if (mounted) {
        setState(() {
          _notificationsEnabled = false;
        });
        _showSnackBar(l10n.notificationsDisabled);
      }
    } else {
      final enabled = await NotificationService.requestPermissions();
      if (mounted) {
        if (enabled) {
          setState(() {
            _notificationsEnabled = true;
          });
          await _scheduleNotifications();
          _showSnackBar(l10n.notificationsEnabled);
        } else {
          _showSnackBar(l10n.notificationPermissionDenied);
        }
      }
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
      backgroundColor: Colors.black,
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
    if (_isLoading) {
      return LoadingWidget(
        isLoadingLocation: _isLoadingLocation,
      );
    }

    if (_locationData == null || _prayerTimesData == null || _prayerStatus == null) {
      return ErrorWidget(
        locationData: _locationData,
        prayerTimesData: _prayerTimesData,
        onRetry: _refreshData,
      );
    }

    return MainContentWidget(
      locationData: _locationData!,
      prayerTimesData: _prayerTimesData!,
      prayerStatus: _prayerStatus!,
      currentTime: _currentTime,
      formattedCurrentDate: _formattedCurrentDate,
      elevation: _elevation,
      isLoadingElevation: _isLoadingElevation,
    );
  }
}
