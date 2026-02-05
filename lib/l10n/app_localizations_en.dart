// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayerly';

  @override
  String get qiblaCompass => 'Qibla Compass';

  @override
  String get dhikrCounter => 'Dhikr Counter';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get settings => 'Settings';

  @override
  String get refresh => 'Refresh';

  @override
  String get howToUse => 'How to Use';

  @override
  String get holdDeviceFlat => 'Hold your device flat (parallel to ground)';

  @override
  String get rotateUntilMarker => 'Rotate until the amber marker points upward';

  @override
  String get faceDirection => 'Face the direction of the amber marker';

  @override
  String get facingQibla => 'You are now facing Qibla (Kaaba direction)';

  @override
  String get dhikrCompleted => 'Dhikr Completed!';

  @override
  String get count => 'Count';

  @override
  String get duration => 'Duration';

  @override
  String get remaining => 'Remaining';

  @override
  String get progress => 'Progress';

  @override
  String get continueLabel => 'Continue';

  @override
  String get finish => 'Finish';

  @override
  String get setTargetCount => 'Set Target Count';

  @override
  String get targetCount => 'Target Count';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get dhikrSettings => 'Dhikr Settings';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDesc => 'Vibrate on each count';

  @override
  String get sound => 'Sound';

  @override
  String get soundDesc => 'Play sound on count';

  @override
  String get showArabicText => 'Show Arabic Text';

  @override
  String get showArabicTextDesc => 'Display Arabic dhikr text';

  @override
  String get showTransliteration => 'Show Transliteration';

  @override
  String get showTransliterationDesc => 'Display phonetic pronunciation';

  @override
  String get showTranslation => 'Show Translation';

  @override
  String get showTranslationDesc => 'Display English meaning';

  @override
  String get autoReset => 'Auto Reset';

  @override
  String get autoResetDesc => 'Reset counter when target reached';

  @override
  String get searchDhikr => 'Search dhikr...';

  @override
  String get popular => 'Popular';

  @override
  String get allDhikr => 'All Dhikr';

  @override
  String get categories => 'Categories';

  @override
  String get morningRecommendations => 'Morning Recommendations';

  @override
  String get afternoonRecommendations => 'Afternoon Recommendations';

  @override
  String get eveningRecommendations => 'Evening Recommendations';

  @override
  String get noDhikrFound => 'No dhikr found';

  @override
  String get adjustSearchFilter => 'Try adjusting your search or filter';

  @override
  String dhikrAvailable(int count) {
    return '$count dhikr available';
  }

  @override
  String get unknownLocation => 'Unknown Location';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationPermissionDenied => 'Notification permissions denied';
}
