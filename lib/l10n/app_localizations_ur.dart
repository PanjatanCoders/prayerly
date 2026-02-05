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
}
