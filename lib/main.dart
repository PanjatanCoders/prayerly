import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prayerly/l10n/app_localizations.dart';
import 'package:prayerly/utils/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'services/notification_service.dart';
import 'services/adhan_service.dart';
import 'services/notification_router.dart';
import 'services/reminder_service.dart';
import 'services/language_service.dart';
import 'screens/splash_screen.dart';
import 'providers/adhan_settings_provider.dart';
import 'providers/reminder_settings_provider.dart';
import 'providers/theme_provider.dart';

// import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Each of these is awaited before runApp() below, so an exception here
  // (e.g. a notification channel failing native validation - this has
  // actually happened, see AdhanService's raw-resource keep.xml) would
  // otherwise stop main() before runApp() ever runs, stranding the user on
  // the native splash screen forever with no way to recover. Degraded
  // functionality (no notifications this session) beats that completely.
  try {
    await NotificationService.initialize();
    await AdhanService.initialize();
    await ReminderService.initialize();
    await LanguageService.initialize();
  } catch (e, stack) {
    debugPrint('Error initializing services: $e\n$stack');
  }

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdhanSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ReminderSettingsProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
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

    // Auto-play itself doesn't go through a listener here - the adhan
    // channel's own native sound (see AdhanService._initializeNotifications)
    // plays automatically, posted by the OS with no Dart isolate involved.
    // This listener only handles explicit user interaction with the
    // notification (the Play/Stop/Pause buttons, or a tap) - routed by
    // onNotificationAction to whichever feature owns that notification.
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onNotificationAction,
    );
    _handleInitialNotificationAction();
  }

  /// Covers the cold-start case: the app process was dead and this exact
  /// notification tap is what launched it, racing MaterialApp's first
  /// build - [onNotificationAction] may fire in a background isolate before
  /// any widget tree exists to find a navigator in. This is the documented
  /// awesome_notifications pattern for catching that launch action
  /// reliably, consumed once so a later warm-start doesn't replay it.
  Future<void> _handleInitialNotificationAction() async {
    final initial = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    if (initial != null) {
      await onNotificationAction(initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              navigatorKey: rootNavigatorKey,
              title: 'Prayerly',
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,

              // Theme configuration using AppTheme
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,

              // Localization configuration
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
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

              home: const SplashScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}
