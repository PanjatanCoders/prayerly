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
  String get rotateUntilMarker => 'तब तक घुमाएं जब तक एम्बर मार्कर ऊपर की ओर न हो';

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
  String get continue => 'जारी रखें';

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
  String get adjustSearchFilter => 'अपना खोज या फिल्टर समायोजित करने का प्रयास करें';

  @override
  String dhikrAvailable(int count) {
    return '$count जिक्र उपलब्ध';
  }
}
