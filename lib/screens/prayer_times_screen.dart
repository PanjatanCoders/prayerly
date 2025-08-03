// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:prayerly/screens/adhan_settings_screen.dart';
import 'package:prayerly/screens/qaza_tracker_screen.dart';

import '../services/location_service.dart';
import '../services/elevation_service.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';
import '../services/adhan_service.dart'; // Import AdhanService
import '../widgets/circular_timer_widget.dart';
import '../widgets/info_card_widget.dart';
import '../widgets/prayer_times_list_widget.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
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
    _initializeServices(); // Initialize both services
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

    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentTime();
      if (_shouldFetchNewPrayerTimes()) {
        _fetchPrayerTimes();
      }
    }
  }

  /// Force refresh current time (useful for app resume)
  void _refreshCurrentTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateTime.now();
        _updatePrayerStatus();
      });
    }
  }

  /// Initialize both notification services
  Future<void> _initializeServices() async {
    try {
      // Initialize AdhanService first
      await AdhanService.initialize();

      // Initialize NotificationService
      await NotificationService.initialize();

      // Set up notification listeners for AdhanService
      AwesomeNotifications().setListeners(
        onActionReceivedMethod:
            AdhanService.onNotificationTap, // Use AdhanService listener
      );

      // Check if notifications are enabled
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

  /// Sets up periodic timers for updates
  void _setupTimers() {
    // Update current time every second
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
          _updatePrayerStatus();

          // Check if we need to fetch new prayer times for a new day
          if (_shouldFetchNewPrayerTimes()) {
            _fetchPrayerTimes();
            _lastFetchDate = DateTime.now();
          }
        });
      }
    });

    // Daily update timer - check for new prayer times every hour
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

  // Gets current location using LocationService
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await LocationService.getCurrentLocation();

      if (!mounted) return;

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        locationData.latitude,
        locationData.longitude,
      );

      if (!mounted) return;

      final placemark = placemarks.first;

      // Build more specific address with area/sublocality
      String address = '';

      // Priority order: subLocality -> thoroughfare -> locality -> administrativeArea -> country
      if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
        address = placemark.subLocality!;
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          address += ', ${placemark.locality}';
        }
      } else if (placemark.thoroughfare != null &&
          placemark.thoroughfare!.isNotEmpty) {
        address = placemark.thoroughfare!;
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          address += ', ${placemark.locality}';
        }
      } else if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        address = placemark.locality!;
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          address += ', ${placemark.administrativeArea}';
        }
      } else if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        address = placemark.administrativeArea!;
      }

      // Always add country at the end if available
      if (placemark.country != null && placemark.country!.isNotEmpty) {
        address += ', ${placemark.country}';
      }

      // Fallback if no address components found
      if (address.isEmpty) {
        address = 'Unknown Location';
      }

      setState(() {
        _locationData = locationData.copyWith(address: address);
        _isLoadingLocation = false;
      });

      // Debug print to see all available address components
      debugPrint('Address components:');
      debugPrint('  Street: ${placemark.street}');
      debugPrint('  Thoroughfare: ${placemark.thoroughfare}');
      debugPrint('  SubThoroughfare: ${placemark.subThoroughfare}');
      debugPrint('  Locality: ${placemark.locality}');
      debugPrint('  SubLocality: ${placemark.subLocality}');
      debugPrint('  AdministrativeArea: ${placemark.administrativeArea}');
      debugPrint('  SubAdministrativeArea: ${placemark.subAdministrativeArea}');
      debugPrint('  PostalCode: ${placemark.postalCode}');
      debugPrint('  Country: ${placemark.country}');
      debugPrint('  Final address: $address');
    } catch (e) {
      debugPrint('Error getting location or address: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
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

        // Schedule notifications when prayer times are updated
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
      // Get notification settings from AdhanService
      final notificationSettings = await AdhanService.getNotificationSettings();

      // Schedule adhan notifications using AdhanService
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
    if (_notificationsEnabled) {
      // Disable notifications using AdhanService
      await AdhanService.cancelAllNotifications();
      if (mounted) {
        setState(() {
          _notificationsEnabled = false;
        });
        _showSnackBar('Notifications disabled');
      }
    } else {
      // Enable notifications
      final enabled = await NotificationService.requestPermissions();
      if (mounted) {
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

  /// Format current date for display
  String get _formattedCurrentDate {
    return "${_currentTime.day.toString().padLeft(2, '0')}/${_currentTime.month.toString().padLeft(2, '0')}/${_currentTime.year}";
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
        tooltip: _notificationsEnabled
            ? 'Disable Notifications'
            : 'Enable Notifications',
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
      leading: GestureDetector(
        onTap: () {
          _showCustomMenu(context);
        },
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      title: Row(mainAxisSize: MainAxisSize.min, children: titleChildren),
      actions: actionChildren,
    );
  }

  void _showCustomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Qaza Tracker Option - NEW
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.format_list_numbered,
                    color: Colors.green,
                  ),
                ),
                title: const Text(
                  'Qaza Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Track missed prayers',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QazaTrackerScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                subtitle: const Text(
                  'Adhan & notifications',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdhanSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the loading screen
  Widget _buildLoadingScreen() {
    List<Widget> loadingChildren = [
      const CircularProgressIndicator(color: Colors.white),
      const SizedBox(height: 16),
      Text(
        _isLoadingLocation
            ? 'Getting your location...'
            : 'Loading prayer times...',
        style: const TextStyle(color: Colors.white),
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
    if (_locationData == null ||
        _prayerTimesData == null ||
        _prayerStatus == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Error loading data',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _locationData == null
                  ? 'Unable to get location'
                  : _prayerTimesData == null
                  ? 'Unable to fetch prayer times'
                  : 'Unable to calculate prayer status',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
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
          currentDate: _formattedCurrentDate,
          elevation: _elevation,
          isLoadingElevation: _isLoadingElevation,
        ),
      ),
    ];

    mainChildren.add(Row(children: topRowChildren));
    mainChildren.add(const SizedBox(height: 24));

    // Prayer Times List
    mainChildren.add(
      PrayerTimesListWidget(
        prayerTimes: _prayerTimesData!.prayerTimes,
        currentPrayer: _prayerStatus!.currentPrayer,
        nextPrayer: _prayerStatus!.nextPrayer,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: mainChildren),
    );
  }

  /// Shows info dialog
  void _showInfoDialog() {
    List<Widget> infoChildren = [
      _buildInfoItem(
        'Calculation Method',
        'University of Islamic Sciences, Karachi',
      ),
      _buildInfoItem(
        'Location',
        _locationData?.isDefault == true
            ? 'Default (Permission denied)'
            : 'GPS Location',
      ),
      _buildInfoItem(
        'Prayer Times Source',
        _prayerTimesData?.isDefault == true ? 'Fallback Data' : 'API Data',
      ),
      _buildInfoItem(
        'Notifications',
        _notificationsEnabled ? 'Enabled (Auto Adhan)' : 'Disabled',
      ),
    ];

    if (_elevation != null) {
      infoChildren.add(
        _buildInfoItem(
          'Elevation',
          ElevationService.formatElevationWithBothUnits(_elevation),
        ),
      );
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
                child: const Text(
                  'Enable Notifications',
                  style: TextStyle(color: Colors.orange),
                ),
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
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
