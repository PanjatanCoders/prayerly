// ignore_for_file: unused_element

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static const String _channelKey = 'prayer_notifications';
  static const String _channelName = 'Prayer Time Notifications';
  static const String _channelDescription = 'Notifications for upcoming prayer times';

  /// Initialize awesome notifications
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: _channelName,
          channelDescription: _channelDescription,
          defaultColor: Colors.orange,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: false,
        )
      ],
      debug: true,
    );
  }

  /// Request notification permissions
  ///
  /// Includes [NotificationPermission.PreciseAlarms] - without it, every
  /// scheduled notification (adhan and makruh/reminder alike) falls back to
  /// an inexact alarm that Android can batch or drop under Doze, which is
  /// most noticeable for the pre-dawn/early-morning ones (Fajr-ending,
  /// sunrise) since the phone has usually been idle the longest by then.
  /// Also includes [NotificationPermission.FullScreenIntent] and
  /// [NotificationPermission.CriticalAlert], which the adhan channel's
  /// notifications request but which need explicit user consent on modern
  /// Android to actually take effect.
  static Future<bool> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: const [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.PreciseAlarms,
          NotificationPermission.FullScreenIntent,
          NotificationPermission.CriticalAlert,
        ],
      );
    }
    return isAllowed;
  }

  /// Schedule notifications for all prayer times
  static Future<void> schedulePrayerNotifications(
      Map<String, DateTime> prayerTimes,
      ) async {
    // Cancel existing notifications first
    await cancelAllNotifications();

    // Request permissions
    bool isAllowed = await requestPermissions();
    if (!isAllowed) {
      debugPrint('Notification permissions denied');
      return;
    }

    int notificationId = 1;

    for (String prayerName in prayerTimes.keys) {
      // Skip sunrise as it's not a prayer time
      if (prayerName.toLowerCase() == 'sunrise') continue;

      DateTime prayerTime = prayerTimes[prayerName]!;
      DateTime notificationTime = prayerTime.subtract(const Duration(minutes: 15));

      // Only schedule if the notification time is in the future
      if (notificationTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: notificationId,
          title: 'Prayer Time Approaching',
          body: '$prayerName prayer is in 15 minutes',
          scheduledDate: notificationTime,
          prayerName: prayerName,
        );

        debugPrint('Scheduled notification for $prayerName at ${notificationTime.toString()}');
        notificationId++;
      }
    }
  }

  /// Schedule a single notification
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String prayerName,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: _channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        payload: {
          'prayer_name': prayerName,
          'type': 'prayer_reminder',
        },
      ),
      schedule: NotificationCalendar(
        year: scheduledDate.year,
        month: scheduledDate.month,
        day: scheduledDate.day,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Cancel notifications for a specific prayer
  static Future<void> cancelPrayerNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Get all scheduled notifications (for debugging)
  static Future<List<NotificationModel>> getScheduledNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  /// Handle notification taps
  static Future<void> onNotificationTap(ReceivedNotification receivedNotification) async {
    // Handle what happens when user taps the notification
    String? prayerName = receivedNotification.payload?['prayer_name'];
    debugPrint('Notification tapped for prayer: $prayerName');

    // You can navigate to a specific screen or perform other actions here
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  /// Get prayer icon based on prayer name
  static String _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'resource://drawable/ic_fajr';
      case 'dhuhr':
        return 'resource://drawable/ic_dhuhr';
      case 'asr':
        return 'resource://drawable/ic_asr';
      case 'maghrib':
        return 'resource://drawable/ic_maghrib';
      case 'isha':
        return 'resource://drawable/ic_isha';
      default:
        return 'resource://drawable/ic_prayer';
    }
  }

  /// Schedule immediate test notification (for testing purposes)
  static Future<void> scheduleTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: _channelKey,
        title: 'Prayer Alert',
        body: 'Your next prayer is approaching soon!',
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }
}