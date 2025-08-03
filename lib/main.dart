import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'services/notification_service.dart';
import 'services/adhan_service.dart';
import 'screens/welcome_screen.dart';
import 'providers/adhan_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: AdhanService.onNotificationTap,
      onNotificationCreatedMethod: (notification) async {
        // Notification logic...
        final payload = notification.payload;
        if (payload != null && payload['action'] == 'play_adhan') {
          final prayer = payload['prayer'];
          final autoPlay = await AdhanService.getAutoPlayEnabled();
          if (autoPlay && prayer != null) {
            await AdhanService.playAdhan(prayer);
          }
        }
      },
      onNotificationDisplayedMethod: (notification) async {},
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
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
