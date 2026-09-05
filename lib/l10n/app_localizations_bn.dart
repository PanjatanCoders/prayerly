// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'প্রেয়ারলি';

  @override
  String get qiblaCompass => 'কিবলা কম্পাস';

  @override
  String get dhikrCounter => 'জিকির কাউন্টার';

  @override
  String get prayerTimes => 'নামাজের সময়';

  @override
  String get settings => 'সেটিংস';

  @override
  String get refresh => 'রিফ্রেশ';

  @override
  String get howToUse => 'কিভাবে ব্যবহার করবেন';

  @override
  String get holdDeviceFlat => 'আপনার ডিভাইসটি সমতল রাখুন (মাটির সমানে)';

  @override
  String get rotateUntilMarker =>
      'অ্যাম্বার মার্কার উপরের দিকে না হওয়া পর্যন্ত ঘুরান';

  @override
  String get faceDirection => 'অ্যাম্বার মার্কারের দিকে মুখ করুন';

  @override
  String get facingQibla => 'এখন আপনি কিবলা (কাবার দিক) মুখ করে আছেন';

  @override
  String get dhikrCompleted => 'জিকির সম্পন্ন!';

  @override
  String get count => 'গণনা';

  @override
  String get duration => 'সময়কাল';

  @override
  String get remaining => 'অবশিষ্ট';

  @override
  String get progress => 'অগ্রগতি';

  @override
  String get continueLabel => 'চালিয়ে যান';

  @override
  String get finish => 'শেষ';

  @override
  String get setTargetCount => 'লক্ষ্য সংখ্যা সেট করুন';

  @override
  String get targetCount => 'লক্ষ্য সংখ্যা';

  @override
  String get cancel => 'বাতিল';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get dhikrSettings => 'জিকির সেটিংস';

  @override
  String get hapticFeedback => 'হ্যাপটিক ফিডব্যাক';

  @override
  String get hapticFeedbackDesc => 'প্রতিটি গণনায় কম্পন';

  @override
  String get sound => 'শব্দ';

  @override
  String get soundDesc => 'গণনায় শব্দ চালান';

  @override
  String get showArabicText => 'আরবি টেক্সট দেখান';

  @override
  String get showArabicTextDesc => 'আরবি জিকির টেক্সট প্রদর্শন করুন';

  @override
  String get showTransliteration => 'প্রতিবর্ণীকরণ দেখান';

  @override
  String get showTransliterationDesc => 'ধ্বনিগত উচ্চারণ প্রদর্শন করুন';

  @override
  String get showTranslation => 'অনুবাদ দেখান';

  @override
  String get showTranslationDesc => 'বাংলা অর্থ প্রদর্শন করুন';

  @override
  String get autoReset => 'অটো রিসেট';

  @override
  String get autoResetDesc => 'লক্ষ্যে পৌঁছালে কাউন্টার রিসেট করুন';

  @override
  String get searchDhikr => 'জিকির খুঁজুন...';

  @override
  String get popular => 'জনপ্রিয়';

  @override
  String get allDhikr => 'সব জিকির';

  @override
  String get categories => 'বিভাগসমূহ';

  @override
  String get morningRecommendations => 'সকালের সুপারিশ';

  @override
  String get afternoonRecommendations => 'দুপুরের সুপারিশ';

  @override
  String get eveningRecommendations => 'সন্ধ্যার সুপারিশ';

  @override
  String get noDhikrFound => 'কোন জিকির পাওয়া যায়নি';

  @override
  String get adjustSearchFilter =>
      'আপনার অনুসন্ধান বা ফিল্টার সামঞ্জস্য করার চেষ্টা করুন';

  @override
  String dhikrAvailable(int count) {
    return '$count জিকির উপলব্ধ';
  }

  @override
  String get unknownLocation => '????? ???????';

  @override
  String get notificationsDisabled => '?????????? ???? ??? ??????';

  @override
  String get notificationsEnabled => '?????????? ???? ??? ??????';

  @override
  String get notificationPermissionDenied =>
      '???????????? ?????? ???????????? ??? ??????';

  @override
  String get savedLocation => 'সংরক্ষিত অবস্থান';

  @override
  String get defaultLocation => 'ডিফল্ট অবস্থান';

  @override
  String get locationNoticeSaved =>
      'আপনার সর্বশেষ জানা অবস্থানের সময় দেখানো হচ্ছে।';

  @override
  String get locationNoticeDefault =>
      'ডিফল্ট অবস্থানের সময় দেখানো হচ্ছে। সঠিক সময়ের জন্য লোকেশন চালু করুন।';

  @override
  String get heading => 'মুখের দিক';

  @override
  String get distance => 'দূরত্ব';

  @override
  String get alignment => 'সারিবদ্ধতা';

  @override
  String get facingQiblaNow => 'আপনি কিবলার দিকে মুখ করে আছেন';

  @override
  String turnRightDegrees(String degrees) {
    return 'ডানে $degrees° ঘুরুন';
  }

  @override
  String turnLeftDegrees(String degrees) {
    return 'বামে $degrees° ঘুরুন';
  }

  @override
  String degreesFromNorth(String degrees) {
    return 'উত্তর থেকে $degrees°';
  }

  @override
  String get calibrationNeeded => 'কম্পাস ক্যালিব্রেশন প্রয়োজন';

  @override
  String get calibrationHint =>
      'পাঠ স্থির না হওয়া পর্যন্ত ফোনটি 8 আকারে ঘোরান।';

  @override
  String get compassUnavailable => 'কম্পাস সেন্সর নেই';

  @override
  String get compassUnavailableHint =>
      'এই ডিভাইস দিক নির্ণয় করতে পারে না। উপরের কিবলা বিয়ারিং একটি সাধারণ কম্পাসে ব্যবহার করুন।';

  @override
  String get waitingForCompass => 'কম্পাস পড়া হচ্ছে…';

  @override
  String get locationUnavailable => 'অবস্থান পাওয়া যায়নি';

  @override
  String get locationUnavailableHint =>
      'কিবলার দিক নির্ণয়ে আপনার অবস্থান প্রয়োজন। লোকেশন চালু করে আবার চেষ্টা করুন।';

  @override
  String get locationPermissionRequired => 'লোকেশন অনুমতি প্রয়োজন';

  @override
  String get locationPermissionRequiredHint =>
      'কিবলার দিক নির্ণয়ের জন্য লোকেশন অনুমতি দিন।';

  @override
  String get locationPermissionBlocked => 'লোকেশন অনুমতি বন্ধ';

  @override
  String get locationPermissionBlockedHint =>
      'Prayerly-এর জন্য লোকেশন বন্ধ আছে। ডিভাইস সেটিংস থেকে চালু করুন।';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get magneticNorthNote =>
      'দিকসমূহ চুম্বকীয় উত্তর অনুসারে দেখানো হয়েছে।';

  @override
  String get avoidInterference => 'ধাতব বস্তু ও ইলেকট্রনিকস থেকে দূরে থাকুন।';

  @override
  String get accuracyHigh => 'উচ্চ';

  @override
  String get accuracyMedium => 'মধ্যম';

  @override
  String get accuracyLow => 'কম';

  @override
  String get accuracyUnknown => 'অজানা';

  @override
  String get finderTitle => 'কিবলার দিক';
}
