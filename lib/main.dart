// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'services/notification_service.dart';
import 'services/adhan_service.dart';
import 'screens/prayer_times_screen.dart';
import 'providers/adhan_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize both services
  await NotificationService.initialize();
  await AdhanService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AdhanSettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Set up notification listeners for AdhanService (handles auto-play)
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: AdhanService.onNotificationTap,
      onNotificationCreatedMethod: (ReceivedNotification notification) async {
        // This is called when notification is created - trigger auto-play
        debugPrint('Notification created: ${notification.id} - ${notification.title}');
        
        // Check if this is a prayer notification and auto-play is enabled
        final payload = notification.payload;
        if (payload != null && payload['action'] == 'play_adhan') {
          final prayer = payload['prayer'];
          final autoPlay = await AdhanService.getAutoPlayEnabled();
          
          if (autoPlay && prayer != null) {
            debugPrint('Auto-playing adhan for $prayer');
            await AdhanService.playAdhan(prayer);
          }
        }
      },
      onNotificationDisplayedMethod: (ReceivedNotification notification) async {
        // This is called when notification is displayed
        debugPrint('Notification displayed: ${notification.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayerly',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),
      home: const PrayerTimesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}