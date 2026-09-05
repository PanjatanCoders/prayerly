// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'پریرلی';

  @override
  String get qiblaCompass => 'قبلہ کمپاس';

  @override
  String get dhikrCounter => 'ذکر کاؤنٹر';

  @override
  String get prayerTimes => 'نماز کے اوقات';

  @override
  String get settings => 'سیٹنگز';

  @override
  String get refresh => 'ریفریش';

  @override
  String get howToUse => 'استعمال کا طریقہ';

  @override
  String get holdDeviceFlat => 'اپنے آلے کو ہموار رکھیں (زمین کے متوازی)';

  @override
  String get rotateUntilMarker =>
      'اس وقت تک گھمائیں جب تک امبر مارکر اوپر کی طرف نہ ہو';

  @override
  String get faceDirection => 'امبر مارکر کی سمت میں منہ کریں';

  @override
  String get facingQibla => 'اب آپ قبلہ (کعبہ کی سمت) کی طرف منہ کر رہے ہیں';

  @override
  String get dhikrCompleted => 'ذکر مکمل!';

  @override
  String get count => 'گنتی';

  @override
  String get duration => 'مدت';

  @override
  String get remaining => 'باقی';

  @override
  String get progress => 'پیش قدمی';

  @override
  String get continueLabel => 'جاری رکھیں';

  @override
  String get finish => 'ختم';

  @override
  String get setTargetCount => 'ہدف کی تعداد سیٹ کریں';

  @override
  String get targetCount => 'ہدف کی تعداد';

  @override
  String get cancel => 'منسوخ';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get dhikrSettings => 'ذکر کی سیٹنگز';

  @override
  String get hapticFeedback => 'ہپٹک فیڈبیک';

  @override
  String get hapticFeedbackDesc => 'ہر گنتی پر کمپن';

  @override
  String get sound => 'آواز';

  @override
  String get soundDesc => 'گنتی پر آواز چلائیں';

  @override
  String get showArabicText => 'عربی متن دکھائیں';

  @override
  String get showArabicTextDesc => 'عربی ذکر کا متن دکھائیں';

  @override
  String get showTransliteration => 'نقل حرفی دکھائیں';

  @override
  String get showTransliterationDesc => 'صوتی تلفظ دکھائیں';

  @override
  String get showTranslation => 'ترجمہ دکھائیں';

  @override
  String get showTranslationDesc => 'اردو معنی دکھائیں';

  @override
  String get autoReset => 'خودکار ری سیٹ';

  @override
  String get autoResetDesc => 'ہدف تک پہنچنے پر کاؤنٹر ری سیٹ کریں';

  @override
  String get searchDhikr => 'ذکر تلاش کریں...';

  @override
  String get popular => 'مقبول';

  @override
  String get allDhikr => 'تمام ذکر';

  @override
  String get categories => 'اقسام';

  @override
  String get morningRecommendations => 'صبح کی تجاویز';

  @override
  String get afternoonRecommendations => 'دوپہر کی تجاویز';

  @override
  String get eveningRecommendations => 'شام کی تجاویز';

  @override
  String get noDhikrFound => 'کوئی ذکر نہیں ملا';

  @override
  String get adjustSearchFilter =>
      'اپنی تلاش یا فلٹر کو ایڈجسٹ کرنے کی کوشش کریں';

  @override
  String dhikrAvailable(int count) {
    return '$count ذکر دستیاب';
  }

  @override
  String get unknownLocation => '??????? ????';

  @override
  String get notificationsDisabled => '?????????? ??? ?? ??? ???';

  @override
  String get notificationsEnabled => '?????????? ???? ?? ??? ???';

  @override
  String get notificationPermissionDenied => '????????? ?? ????? ?????';

  @override
  String get savedLocation => 'محفوظ مقام';

  @override
  String get defaultLocation => 'طے شدہ مقام';

  @override
  String get locationNoticeSaved =>
      'آپ کے آخری معلوم مقام کے اوقات دکھائے جا رہے ہیں۔';

  @override
  String get locationNoticeDefault =>
      'طے شدہ مقام کے اوقات دکھائے جا رہے ہیں۔ درست اوقات کے لیے لوکیشن آن کریں۔';

  @override
  String get heading => 'رخ';

  @override
  String get distance => 'فاصلہ';

  @override
  String get alignment => 'سمت ملاپ';

  @override
  String get facingQiblaNow => 'آپ قبلہ کی طرف رخ کیے ہوئے ہیں';

  @override
  String turnRightDegrees(String degrees) {
    return '$degrees° دائیں مڑیں';
  }

  @override
  String turnLeftDegrees(String degrees) {
    return '$degrees° بائیں مڑیں';
  }

  @override
  String degreesFromNorth(String degrees) {
    return 'شمال سے $degrees°';
  }

  @override
  String get calibrationNeeded => 'کمپاس کی کیلیبریشن درکار ہے';

  @override
  String get calibrationHint =>
      'پڑھت مستحکم ہونے تک فون کو 8 کی شکل میں گھمائیں۔';

  @override
  String get compassUnavailable => 'کمپاس سینسر نہیں';

  @override
  String get compassUnavailableHint =>
      'یہ آلہ سمت معلوم نہیں کر سکتا۔ اوپر دیا گیا قبلہ زاویہ کسی کمپاس کے ساتھ استعمال کریں۔';

  @override
  String get waitingForCompass => 'کمپاس پڑھا جا رہا ہے…';

  @override
  String get locationUnavailable => 'مقام دستیاب نہیں';

  @override
  String get locationUnavailableHint =>
      'قبلہ کی سمت کے لیے آپ کا مقام درکار ہے۔ لوکیشن آن کرکے دوبارہ کوشش کریں۔';

  @override
  String get locationPermissionRequired => 'لوکیشن کی اجازت درکار ہے';

  @override
  String get locationPermissionRequiredHint =>
      'قبلہ کی سمت معلوم کرنے کے لیے لوکیشن کی اجازت دیں۔';

  @override
  String get locationPermissionBlocked => 'لوکیشن کی اجازت بلاک ہے';

  @override
  String get locationPermissionBlockedHint =>
      'Prayerly کے لیے لوکیشن بند ہے۔ آلے کی ترتیبات میں آن کریں۔';

  @override
  String get openSettings => 'ترتیبات کھولیں';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String get magneticNorthNote => 'سمتیں مقناطیسی شمال کے لحاظ سے ہیں۔';

  @override
  String get avoidInterference => 'دھات اور بجلی کے آلات سے دور رہیں۔';

  @override
  String get accuracyHigh => 'بلند';

  @override
  String get accuracyMedium => 'درمیانہ';

  @override
  String get accuracyLow => 'کم';

  @override
  String get accuracyUnknown => 'نامعلوم';

  @override
  String get finderTitle => 'قبلہ کی سمت';
}
