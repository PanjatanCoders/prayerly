// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';

import '../services/location_service.dart';
import '../services/elevation_service.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart'; // Add this import
import '../widgets/circular_timer_widget.dart';
import '../widgets/info_card_widget.dart';
import '../widgets/prayer_times_list_widget.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
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
  bool _isLoadingElevation = false;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupTimers();
    _initializeApp();
  }

  @override
  void dispose() {
    _timeUpdateTimer.cancel();
    _dailyUpdateTimer.cancel();
    super.dispose();
  }

  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.initialize();

      // Set up notification listeners
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationService.onNotificationTap,
      );

      // Check if notifications are enabled
      final enabled = await NotificationService.areNotificationsEnabled();
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Sets up periodic timers for updates
  void _setupTimers() {
    // Update current time every second
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updatePrayerStatus();

        // Check if we need to fetch new prayer times for a new day
        if (_shouldFetchNewPrayerTimes()) {
          _fetchPrayerTimes();
          _lastFetchDate = DateTime.now();
        }
      });
    });

    // Daily update timer - check for new prayer times every hour
    _dailyUpdateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (_shouldFetchNewPrayerTimes()) {
        debugPrint('Daily update: Fetching new prayer times');
        _fetchPrayerTimes();
        _lastFetchDate = DateTime.now();
      }
    });
  }

  /// Initializes the app by loading all necessary data
  Future<void> _initializeApp() async {
    try {
      // Get location
      await _getCurrentLocation();

      // Fetch prayer times
      await _fetchPrayerTimes();

      // Fetch elevation if location is available
      if (_locationData != null) {
        await _fetchElevation();
      }

      // Update prayer status
      _updatePrayerStatus();

      // Schedule notifications if prayer times are available
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
    try {
      final locationData = await LocationService.getCurrentLocation();
      setState(() {
        _locationData = locationData;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      // LocationService handles fallback, so we should still have data
    }
  }

  /// Fetches elevation data
  Future<void> _fetchElevation() async {
    if (_locationData == null) return;

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
    if (_locationData == null) return;

    try {
      final prayerTimesData = await PrayerService.getPrayerTimes(
        latitude: _locationData!.latitude,
        longitude: _locationData!.longitude,
      );

      setState(() {
        _prayerTimesData = prayerTimesData;
      });

      // Schedule notifications when prayer times are updated
      if (_notificationsEnabled) {
        await _scheduleNotifications();
      }

    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
    }
  }

  /// Schedule notifications for prayer times
  Future<void> _scheduleNotifications() async {
    if (_prayerTimesData?.prayerTimes.isEmpty ?? true) return;

    try {
      await NotificationService.schedulePrayerNotifications(_prayerTimesData!.prayerTimes);
      debugPrint('Prayer notifications scheduled successfully');
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

    setState(() {
      _prayerStatus = status;
    });
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
    setState(() {
      _isLoading = true;
    });

    await _initializeApp();
  }

  /// Toggle notifications
  Future<void> _toggleNotifications() async {
    if (_notificationsEnabled) {
      // Disable notifications
      await NotificationService.cancelAllNotifications();
      setState(() {
        _notificationsEnabled = false;
      });
      _showSnackBar('Notifications disabled');
    } else {
      // Enable notifications
      final enabled = await NotificationService.requestPermissions();
      if (enabled) {
        setState(() {
          _notificationsEnabled = true;
        });
        await _scheduleNotifications();
        _showSnackBar('Notifications enabled');
      } else {
        _showSnackBar('Notification permissions denied');
      }
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar() {
    List<Widget> titleChildren = [
      const Icon(Icons.brightness_6, color: Colors.white),
      const SizedBox(width: 8),
      const Text(
        'Prayerly',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ];

    List<Widget> actionChildren = [
      // Notification toggle button
      IconButton(
        icon: Icon(
          _notificationsEnabled ? Icons.notifications : Icons.notifications_off,
          color: _notificationsEnabled ? Colors.orange : Colors.grey,
        ),
        onPressed: _toggleNotifications,
        tooltip: _notificationsEnabled ? 'Disable Notifications' : 'Enable Notifications',
      ),
      IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white),
        onPressed: _refreshData,
      ),
      IconButton(
        icon: const Icon(Icons.info_outline, color: Colors.white),
        onPressed: () {
          _showInfoDialog();
        },
      ),
    ];

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(Icons.menu, color: Colors.white),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: titleChildren,
      ),
      actions: actionChildren,
    );
  }

  /// Builds the loading screen
  Widget _buildLoadingScreen() {
    List<Widget> loadingChildren = [
      const CircularProgressIndicator(color: Colors.white),
      const SizedBox(height: 16),
      const Text(
        'Loading prayer times...',
        style: TextStyle(color: Colors.white),
      ),
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: loadingChildren,
      ),
    );
  }

  /// Builds the main content
  Widget _buildMainContent() {
    if (_locationData == null || _prayerTimesData == null || _prayerStatus == null) {
      return const Center(
        child: Text(
          'Error loading data. Please try refreshing.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    List<Widget> mainChildren = [];

    // Top section with circular timer and info
    List<Widget> topRowChildren = [
      CircularTimerWidget(
        nextPrayer: _prayerStatus!.nextPrayer,
        timeRemaining: _prayerStatus!.timeRemaining,
        currentTime: _currentTime,
        progress: _prayerStatus!.progress,
      ),
      const SizedBox(width: 16),
      Expanded(
        child: InfoCardWidget(
          location: _locationData!.address,
          islamicDate: _prayerTimesData!.islamicDate,
          elevation: _elevation,
          isLoadingElevation: _isLoadingElevation,
        ),
      ),
    ];

    mainChildren.add(Row(children: topRowChildren));
    mainChildren.add(const SizedBox(height: 24));

    // Prayer Times List
    mainChildren.add(PrayerTimesListWidget(
      prayerTimes: _prayerTimesData!.prayerTimes,
      currentPrayer: _prayerStatus!.currentPrayer,
      nextPrayer: _prayerStatus!.nextPrayer,
    ));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: mainChildren),
    );
  }

  /// Shows info dialog
  void _showInfoDialog() {
    List<Widget> infoChildren = [
      _buildInfoItem('Calculation Method', 'University of Islamic Sciences, Karachi'),
      _buildInfoItem('Location', _locationData?.isDefault == true ? 'Default (Permission denied)' : 'GPS Location'),
      _buildInfoItem('Prayer Times Source', _prayerTimesData?.isDefault == true ? 'Fallback Data' : 'API Data'),
      _buildInfoItem('Notifications', _notificationsEnabled ? 'Enabled (15 min before)' : 'Disabled'),
    ];

    if (_elevation != null) {
      infoChildren.add(_buildInfoItem('Elevation', ElevationService.formatElevationWithBothUnits(_elevation)));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'App Information',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: infoChildren,
          ),
          actions: [
            if (!_notificationsEnabled)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _toggleNotifications();
                },
                child: const Text('Enable Notifications', style: TextStyle(color: Colors.orange)),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Builds info item for dialog
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}