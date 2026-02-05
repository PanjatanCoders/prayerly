import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayerly'**
  String get appTitle;

  /// No description provided for @qiblaCompass.
  ///
  /// In en, this message translates to:
  /// **'Qibla Compass'**
  String get qiblaCompass;

  /// No description provided for @dhikrCounter.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Counter'**
  String get dhikrCounter;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @holdDeviceFlat.
  ///
  /// In en, this message translates to:
  /// **'Hold your device flat (parallel to ground)'**
  String get holdDeviceFlat;

  /// No description provided for @rotateUntilMarker.
  ///
  /// In en, this message translates to:
  /// **'Rotate until the amber marker points upward'**
  String get rotateUntilMarker;

  /// No description provided for @faceDirection.
  ///
  /// In en, this message translates to:
  /// **'Face the direction of the amber marker'**
  String get faceDirection;

  /// No description provided for @facingQibla.
  ///
  /// In en, this message translates to:
  /// **'You are now facing Qibla (Kaaba direction)'**
  String get facingQibla;

  /// No description provided for @dhikrCompleted.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Completed!'**
  String get dhikrCompleted;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @setTargetCount.
  ///
  /// In en, this message translates to:
  /// **'Set Target Count'**
  String get setTargetCount;

  /// No description provided for @targetCount.
  ///
  /// In en, this message translates to:
  /// **'Target Count'**
  String get targetCount;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @dhikrSettings.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Settings'**
  String get dhikrSettings;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on each count'**
  String get hapticFeedbackDesc;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundDesc.
  ///
  /// In en, this message translates to:
  /// **'Play sound on count'**
  String get soundDesc;

  /// No description provided for @showArabicText.
  ///
  /// In en, this message translates to:
  /// **'Show Arabic Text'**
  String get showArabicText;

  /// No description provided for @showArabicTextDesc.
  ///
  /// In en, this message translates to:
  /// **'Display Arabic dhikr text'**
  String get showArabicTextDesc;

  /// No description provided for @showTransliteration.
  ///
  /// In en, this message translates to:
  /// **'Show Transliteration'**
  String get showTransliteration;

  /// No description provided for @showTransliterationDesc.
  ///
  /// In en, this message translates to:
  /// **'Display phonetic pronunciation'**
  String get showTransliterationDesc;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show Translation'**
  String get showTranslation;

  /// No description provided for @showTranslationDesc.
  ///
  /// In en, this message translates to:
  /// **'Display English meaning'**
  String get showTranslationDesc;

  /// No description provided for @autoReset.
  ///
  /// In en, this message translates to:
  /// **'Auto Reset'**
  String get autoReset;

  /// No description provided for @autoResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Reset counter when target reached'**
  String get autoResetDesc;

  /// No description provided for @searchDhikr.
  ///
  /// In en, this message translates to:
  /// **'Search dhikr...'**
  String get searchDhikr;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @allDhikr.
  ///
  /// In en, this message translates to:
  /// **'All Dhikr'**
  String get allDhikr;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @morningRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Morning Recommendations'**
  String get morningRecommendations;

  /// No description provided for @afternoonRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Recommendations'**
  String get afternoonRecommendations;

  /// No description provided for @eveningRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Evening Recommendations'**
  String get eveningRecommendations;

  /// No description provided for @noDhikrFound.
  ///
  /// In en, this message translates to:
  /// **'No dhikr found'**
  String get noDhikrFound;

  /// No description provided for @adjustSearchFilter.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter'**
  String get adjustSearchFilter;

  /// No description provided for @dhikrAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} dhikr available'**
  String dhikrAvailable(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
