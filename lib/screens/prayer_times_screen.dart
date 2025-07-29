import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../utils/circular_progress_painter.dart';
import '../utils/time_info_card.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Timer _timeUpdateTimer;

  Map<String, DateTime> prayerTimes = {};
  String currentLocation = "Loading...";
  String currentPrayer = "Loading...";
  String nextPrayer = "Loading...";
  Duration timeRemaining = Duration.zero;
  bool isLoading = true;
  double latitude = 0.0;
  double longitude = 0.0;
  DateTime currentTime = DateTime.now();
  String islamicDate = "";
  late DateTime lastFetchDate;
  late Timer _dailyUpdateTimer;

  // University of Islamic Sciences, Karachi method = 1
  final int calculationMethod = 1;

  @override
  void initState() {
    super.initState();

    // Initialize lastFetchDate to prevent null errors
    lastFetchDate = DateTime.now();

    _animationController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    )..repeat();

    // Update current time every second
    _timeUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = DateTime.now();
        _updateCurrentPrayer();

        // Check if we need to fetch new prayer times for a new day
        if (_shouldFetchNewPrayerTimes()) {
          _fetchPrayerTimes();
          lastFetchDate = DateTime.now();
        }
      });
    });

    // Daily update timer - fetch new prayer times at midnight
    _dailyUpdateTimer = Timer.periodic(Duration(hours: 1), (timer) {
      if (_shouldFetchNewPrayerTimes()) {
        print('Daily update: Fetching new prayer times');
        _fetchPrayerTimes();
        lastFetchDate = DateTime.now();
      }
    });

    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timeUpdateTimer.cancel();
    _dailyUpdateTimer.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _getCurrentLocation();
    await _fetchPrayerTimes();
    _updateCurrentPrayer();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: locationSettings
        );

        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });

        // Get address from coordinates
        await _getAddressFromCoordinates(position.latitude, position.longitude);
      }
    } catch (e) {
      setState(() {
        currentLocation = "Pune, Maharashtra";
        latitude = 18.5204; // Default Pune coordinates
        longitude = 73.8567;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        setState(() {
          currentLocation =
          '${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
        });
      } else {
        setState(() {
          currentLocation = "Unknown location";
        });
      }
    } catch (e) {
      setState(() {
        currentLocation = "Location unavailable";
      });
    }
  }

  bool _shouldFetchNewPrayerTimes() {
    final now = DateTime.now();
    final lastFetch = lastFetchDate;

    return now.day != lastFetch.day ||
        now.month != lastFetch.month ||
        now.year != lastFetch.year ||
        prayerTimes.isEmpty;
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final now = DateTime.now();
      final dateString = DateFormat('dd-MM-yyyy').format(now);

      final response = await http.get(
        Uri.parse(
            'http://api.aladhan.com/v1/timings/$dateString?latitude=$latitude&longitude=$longitude&method=$calculationMethod'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        final hijriDate = data['data']['date']['hijri'];

        setState(() {
          prayerTimes = {
            'Fajr': _parseTimeString(timings['Fajr']),
            'Sunrise': _parseTimeString(timings['Sunrise']),
            'Dhuhr': _parseTimeString(timings['Dhuhr']),
            'Asr': _parseTimeString(timings['Asr']),
            'Maghrib': _parseTimeString(timings['Maghrib']),
            'Isha': _parseTimeString(timings['Isha']),
          };

          islamicDate = "${hijriDate['day']} ${hijriDate['month']['en']}, ${hijriDate['year']}";
        });
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      _setDefaultPrayerTimes();
    }
  }

  DateTime _parseTimeString(String timeString) {
    final now = DateTime.now();
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _setDefaultPrayerTimes() {
    DateTime now = DateTime.now();
    print('Using fallback prayer times - API unavailable');
    setState(() {
      prayerTimes = {
        'Fajr': DateTime(now.year, now.month, now.day, 4, 51, 0),
        'Sunrise': DateTime(now.year, now.month, now.day, 6, 7, 0),
        'Dhuhr': DateTime(now.year, now.month, now.day, 12, 41, 0),
        'Asr': DateTime(now.year, now.month, now.day, 17, 12, 0),
        'Maghrib': DateTime(now.year, now.month, now.day, 19, 14, 0),
        'Isha': DateTime(now.year, now.month, now.day, 20, 30, 0),
      };
      islamicDate = "1 Safar, 1447";
    });
  }

  void _updateCurrentPrayer() {
    if (prayerTimes.isEmpty) return;

    final now = currentTime;
    String current = "None";
    String next = "Fajr";
    Duration remaining = Duration.zero;

    List<MapEntry<String, DateTime>> prayers = prayerTimes.entries
        .where((entry) => entry.key != 'Sunrise')
        .toList();

    prayers.sort((a, b) => a.value.compareTo(b.value));

    for (int i = 0; i < prayers.length; i++) {
      if (now.isBefore(prayers[i].value)) {
        next = prayers[i].key;
        remaining = prayers[i].value.difference(now);

        if (i > 0) {
          current = prayers[i - 1].key;
        } else {
          current = "Isha";
        }
        break;
      }
    }

    if (now.isAfter(prayers.last.value)) {
      current = prayers.last.key;
      next = "Fajr";
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final fajrTomorrow = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
          prayerTimes['Fajr']!.hour, prayerTimes['Fajr']!.minute);
      remaining = fajrTomorrow.difference(now);
    }

    setState(() {
      currentPrayer = current;
      nextPrayer = next;
      timeRemaining = remaining;
    });
  }

  String _getIslamicDate() {
    return islamicDate.isNotEmpty ? islamicDate : "Loading...";
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  String _formatCurrentTime() {
    return DateFormat('hh:mm:ss a').format(currentTime);
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Colors.blue;
      case 'Sunrise':
        return Colors.orange;
      case 'Dhuhr':
        return Colors.red;
      case 'Asr':
        return Colors.amber;
      case 'Maghrib':
        return Colors.purple;
      case 'Isha':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  double _getTimerProgress() {
    if (timeRemaining.inSeconds <= 0) return 1.0;

    // Get time between current and next prayer for more accurate progress
    final now = currentTime;
    DateTime? currentPrayerTime;
    DateTime? nextPrayerTime;

    // Find current and next prayer times
    List<MapEntry<String, DateTime>> prayers = prayerTimes.entries
        .where((entry) => entry.key != 'Sunrise')
        .toList();
    prayers.sort((a, b) => a.value.compareTo(b.value));

    for (int i = 0; i < prayers.length; i++) {
      if (now.isBefore(prayers[i].value)) {
        nextPrayerTime = prayers[i].value;
        if (i > 0) {
          currentPrayerTime = prayers[i - 1].value;
        } else {
          // Before Fajr, current prayer is Isha from previous day
          final yesterday = DateTime(now.year, now.month, now.day - 1);
          currentPrayerTime = DateTime(yesterday.year, yesterday.month, yesterday.day,
              prayerTimes['Isha']!.hour, prayerTimes['Isha']!.minute);
        }
        break;
      }
    }

    // After Isha
    if (now.isAfter(prayers.last.value)) {
      currentPrayerTime = prayers.last.value;
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      nextPrayerTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
          prayerTimes['Fajr']!.hour, prayerTimes['Fajr']!.minute);
    }

    if (currentPrayerTime != null && nextPrayerTime != null) {
      final totalDuration = nextPrayerTime.difference(currentPrayerTime);
      final elapsedDuration = now.difference(currentPrayerTime);
      return (elapsedDuration.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
    }

    return 0.0;
  }

  // Integrated Circular Timer Widget
  Widget _buildCircularTimer() {
    double size = 200;

    // Debug prints to check if values are updating
    print('CircularTimer Debug:');
    print('- Current Time: ${_formatCurrentTime()}');
    print('- Next Prayer: $nextPrayer');
    print('- Time Remaining: ${timeRemaining.inHours}:${timeRemaining.inMinutes % 60}:${timeRemaining.inSeconds % 60}');
    print('- Progress: ${_getTimerProgress()}');

    return Container(
      key: ValueKey('${currentTime.millisecondsSinceEpoch}'), // Force rebuild
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
          ),
          // Progress circle
          CustomPaint(
            key: ValueKey('progress_${_getTimerProgress()}_${nextPrayer}'),
            size: Size(size, size),
            painter: CircularProgressPainter(
              progress: _getTimerProgress(),
              color: _getPrayerColor(nextPrayer),
            ),
          ),
          // Timer text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nextPrayer,
                key: ValueKey('prayer_$nextPrayer'),
                style: TextStyle(
                  color: _getPrayerColor(nextPrayer),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "${timeRemaining.inHours.toString().padLeft(2, '0')}:"
                    "${(timeRemaining.inMinutes % 60).toString().padLeft(2, '0')}:"
                    "${(timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}",
                key: ValueKey('remaining_${timeRemaining.inSeconds}'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _formatCurrentTime(),
                key: ValueKey('current_${currentTime.millisecondsSinceEpoch}'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Info Card Widget
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  currentLocation,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getIslamicDate(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.gps_fixed, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeItem(String prayer, DateTime time, bool hasNotification) {
    bool isCurrentPrayer = prayer == currentPrayer;
    bool isNextPrayer = prayer == nextPrayer;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? Colors.green.withOpacity(0.1)
            : isNextPrayer
            ? Colors.red.withOpacity(0.1)
            : Colors.transparent,
        border: isCurrentPrayer
            ? Border.all(color: Colors.green, width: 2)
            : isNextPrayer
            ? Border.all(color: Colors.red, width: 2)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getPrayerColor(prayer),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prayer,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isCurrentPrayer)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isNextPrayer)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (prayer == 'Asr')
                  Text(
                    '(Hanafi)',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatTime(time),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          if (hasNotification)
            Icon(
              Icons.notifications_active,
              color: Colors.amber,
              size: 20,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.brightness_6, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Prayerly',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              _initializeApp();
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading prayer times...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Top section with circular timer and info
            Row(
              children: [
                _buildCircularTimer(),
                SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Prayer Times List
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Prayer Times',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Prayer times
                  ...prayerTimes.entries.map((entry) {
                    bool hasNotification = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
                        .contains(entry.key);
                    return _buildPrayerTimeItem(
                      entry.key,
                      entry.value,
                      hasNotification,
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}