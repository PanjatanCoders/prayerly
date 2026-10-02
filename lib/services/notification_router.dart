import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../widgets/daily_wazifa_dialog.dart';
import '../widgets/jumuah_durood_dialog.dart';
import 'adhan_service.dart';

/// App-wide navigator key so a notification tap - which runs with no
/// [BuildContext] of its own, and can even cold-start the app - can still
/// open a dialog/navigate once the widget tree exists.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Payload `action` value used by [ReminderService]'s Jumu'ah Mubarak
/// notification.
const String jumuahDuroodAction = 'show_jumuah_durood';

/// Payload `action` value used by [ReminderService]'s daily morning wazifa
/// notification.
const String dailyWazifaAction = 'show_daily_wazifa';

/// The single `onActionReceivedMethod` registered in `main.dart` - every
/// notification tap across the whole app comes through here, since
/// awesome_notifications' `setListeners` unconditionally overwrites whatever
/// was registered before it (see the history in AdhanService), so there can
/// only be one registration point. Routes by the payload's `action` field to
/// whichever feature owns that notification; anything not recognized here
/// falls through to [AdhanService.onNotificationTap]. **Adding another
/// notification-triggered dialog/navigation? Add another branch here, not a
/// second `setListeners()` call.**
///
/// Must stay a bare top-level function (not a closure) - the same
/// requirement `AdhanService.onNotificationTap` documents, since this is the
/// one callback awesome_notifications can resurrect in a background isolate
/// when Android has killed the app process.
@pragma('vm:entry-point')
Future<void> onNotificationAction(ReceivedAction receivedAction) async {
  switch (receivedAction.payload?['action']) {
    case jumuahDuroodAction:
      await _runWhenNavigatorReady(showJumuahDuroodDialog);
      return;
    case dailyWazifaAction:
      await _runWhenNavigatorReady(showDailyWazifaDialog);
      return;
  }
  await AdhanService.onNotificationTap(receivedAction);
}

/// The navigator may not be mounted yet - most notably when this very tap is
/// what's cold-starting the app, racing [MaterialApp]'s first build - so
/// this polls briefly instead of silently giving up on a null context.
Future<void> _runWhenNavigatorReady(
  Future<void> Function(BuildContext context) action,
) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      await action(context);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
