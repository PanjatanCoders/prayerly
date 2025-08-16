import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'services/notification_service.dart';
import 'services/adhan_service.dart';
import 'services/language_service.dart';
import 'screens/welcome_screen.dart';
import 'providers/adhan_settings_provider.dart';
// import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService.initialize();
  await AdhanService.initialize();
  await LanguageService.initialize();

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
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'Prayerly',
          
          // Theme configuration using AppTheme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          
          // Localization configuration
          locale: locale,
          localizationsDelegates: const [
            // AppLocalizations.delegate, // Uncomment when you have ARB files
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageService.supportedLocales,
          
          // Locale resolution callback
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale != null) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }
            return const Locale('en'); // Default to English
          },
          
          // RTL support for Urdu and text scaling
          builder: (context, child) {
            return Directionality(
              textDirection: LanguageService.textDirection,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Ensure proper text scaling
                  textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: 0.8, 
                    maxScaleFactor: 1.5,
                  ),
                ),
                child: child!,
              ),
            );
          },
          
          home: const WelcomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}