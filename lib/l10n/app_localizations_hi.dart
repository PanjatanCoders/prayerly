// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'प्रेयरली';

  @override
  String get qiblaCompass => 'किबला कम्पास';

  @override
  String get dhikrCounter => 'जिक्र काउंटर';

  @override
  String get prayerTimes => 'नमाज़ का समय';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get refresh => 'रीफ्रेश';

  @override
  String get howToUse => 'उपयोग कैसे करें';

  @override
  String get holdDeviceFlat => 'अपने डिवाइस को समतल रखें (जमीन के समानांतर)';

  @override
  String get rotateUntilMarker =>
      'तब तक घुमाएं जब तक एम्बर मार्कर ऊपर की ओर न हो';

  @override
  String get faceDirection => 'एम्बर मार्कर की दिशा में मुंह करें';

  @override
  String get facingQibla => 'अब आप किबला (काबा दिशा) की ओर मुंह कर रहे हैं';

  @override
  String get dhikrCompleted => 'जिक्र पूरा हुआ!';

  @override
  String get count => 'गिनती';

  @override
  String get duration => 'अवधि';

  @override
  String get remaining => 'शेष';

  @override
  String get progress => 'प्रगति';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get finish => 'समाप्त';

  @override
  String get setTargetCount => 'लक्ष्य संख्या सेट करें';

  @override
  String get targetCount => 'लक्ष्य संख्या';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सेव करें';

  @override
  String get dhikrSettings => 'जिक्र सेटिंग्स';

  @override
  String get hapticFeedback => 'हैप्टिक फीडबैक';

  @override
  String get hapticFeedbackDesc => 'हर गिनती पर कंपन';

  @override
  String get sound => 'आवाज़';

  @override
  String get soundDesc => 'गिनती पर आवाज़ बजाएं';

  @override
  String get showArabicText => 'अरबी टेक्स्ट दिखाएं';

  @override
  String get showArabicTextDesc => 'अरबी जिक्र टेक्स्ट प्रदर्शित करें';

  @override
  String get showTransliteration => 'ट्रांसलिटरेशन दिखाएं';

  @override
  String get showTransliterationDesc => 'ध्वन्यात्मक उच्चारण प्रदर्शित करें';

  @override
  String get showTranslation => 'अनुवाद दिखाएं';

  @override
  String get showTranslationDesc => 'हिंदी अर्थ प्रदर्शित करें';

  @override
  String get autoReset => 'ऑटो रीसेट';

  @override
  String get autoResetDesc => 'लक्ष्य पहुंचने पर काउंटर रीसेट करें';

  @override
  String get searchDhikr => 'जिक्र खोजें...';

  @override
  String get popular => 'लोकप्रिय';

  @override
  String get allDhikr => 'सभी जिक्र';

  @override
  String get categories => 'श्रेणियां';

  @override
  String get morningRecommendations => 'सुबह की सिफारिशें';

  @override
  String get afternoonRecommendations => 'दोपहर की सिफारिशें';

  @override
  String get eveningRecommendations => 'शाम की सिफारिशें';

  @override
  String get noDhikrFound => 'कोई जिक्र नहीं मिला';

  @override
  String get adjustSearchFilter =>
      'अपना खोज या फिल्टर समायोजित करने का प्रयास करें';

  @override
  String dhikrAvailable(int count) {
    return '$count जिक्र उपलब्ध';
  }

  @override
  String get unknownLocation => 'अज्ञात स्थान';

  @override
  String get notificationsDisabled => 'सूचनाएँ बंद की गईं';

  @override
  String get notificationsEnabled => 'सूचनाएँ चालू की गईं';

  @override
  String get notificationPermissionDenied => 'सूचना अनुमति अस्वीकृत';

  @override
  String get savedLocation => 'सहेजा गया स्थान';

  @override
  String get defaultLocation => 'ड़िफ़ॉल्ट स्थान';

  @override
  String get locationNoticeSaved =>
      'आपके अंतिम ज्ञात स्थान के समय दिखाए जा रहे हैं।';

  @override
  String get locationNoticeDefault =>
      'ड़िफ़ॉल्ट स्थान के समय दिखाए जा रहे हैं। सटीक समय के लिए लोकेशन चालू करें।';

  @override
  String get heading => 'दिशा';

  @override
  String get distance => 'दूरी';

  @override
  String get alignment => 'संरेखण';

  @override
  String get facingQiblaNow => 'आप किबला की ओर मुख किए हुए हैं';

  @override
  String turnRightDegrees(String degrees) {
    return '$degrees° दाएं घूमें';
  }

  @override
  String turnLeftDegrees(String degrees) {
    return '$degrees° बाएं घूमें';
  }

  @override
  String degreesFromNorth(String degrees) {
    return 'उत्तर से $degrees°';
  }

  @override
  String get calibrationNeeded => 'कम्पास को कैलिब्रेशन चाहिए';

  @override
  String get calibrationHint =>
      'पढ़त स्थिर होने तक फ़ोन को 8 के आकार में घुमाएं।';

  @override
  String get compassUnavailable => 'कम्पास सेंसर नहीं है';

  @override
  String get compassUnavailableHint =>
      'यह डिवाइस दिशा नहीं बता सकता। ऊपर दिए गए किबला बेयरिंग को किसी कम्पास के साथ उपयोग करें।';

  @override
  String get waitingForCompass => 'कम्पास पढ़ा जा रहा है…';

  @override
  String get locationUnavailable => 'स्थान उपलब्ध नहीं';

  @override
  String get locationUnavailableHint =>
      'किबला की दिशा के लिए आपका स्थान चाहिए। लोकेशन चालू करके पुनः प्रयास करें।';

  @override
  String get locationPermissionRequired => 'लोकेशन अनुमति चाहिए';

  @override
  String get locationPermissionRequiredHint =>
      'किबला की दिशा गणना के लिए लोकेशन की अनुमति दें।';

  @override
  String get locationPermissionBlocked => 'लोकेशन अनुमति ब्लॉक है';

  @override
  String get locationPermissionBlockedHint =>
      'Prayerly के लिए लोकेशन बंद है। डिवाइस सेटिंग्स में चालू करें।';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get magneticNorthNote => 'दिशाएँ चुंबकीय उत्तर के सापेक्ष हैं।';

  @override
  String get avoidInterference => 'धातु और इलेक्ट्रॉनिक्स से दूर रहें।';

  @override
  String get accuracyHigh => 'उच्च';

  @override
  String get accuracyMedium => 'मध्यम';

  @override
  String get accuracyLow => 'कम';

  @override
  String get accuracyUnknown => 'अज्ञात';

  @override
  String get finderTitle => 'किबला की दिशा';
}
