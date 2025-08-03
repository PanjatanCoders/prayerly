// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'services/notification_service.dart';
import 'screens/prayer_times_screen.dart';

import 'providers/adhan_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AdhanSettingsProvider()..loadSettings(),
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

    // Set up notification listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onNotificationTap,
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
