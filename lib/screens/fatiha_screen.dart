import 'package:flutter/material.dart';
import 'package:prayerly/utils/theme/app_theme.dart';

class _FatihaStep {
  const _FatihaStep(this.instruction, this.arabic);

  final String instruction;
  final String arabic;
}

// Source: a Fatiha Ka Tarika reference the user supplied (PDF, printed from
// mudassirnoori.com). The Arabic text for every step below is fully legible
// in that source. The Hindi instruction wording for steps 6, 8, and 11 was
// reconstructed to match the pattern of the other (fully visible) headings,
// because the PDF's page-scroll capture cut off those three specific
// headings — the Quranic text itself was never in question, only the
// phrasing of the instruction line above it. Worth a glance before treating
// this as final.
const _steps = [
  _FatihaStep(
    'सब से पहले 3 बार दरूद शरीफ पढ़ें',
    'اَللّٰهُمَّ صَلِّ عَلٰی سَیِّدِنَا مُحَمَّدٍ وَّاٰلِ سَیِّدِنَا مُحَمَّدٍ وَبَارِکْ وَسَلِّمْ',
  ),
  _FatihaStep(
    'फिर ये पढ़ें (ताउज़ और तस्मिया)',
    'اَعُوْذُ بِاللّٰهِ مِنَ الشَّیْطٰنِ الرَّجِیْمِ\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِیْمِ',
  ),
  _FatihaStep(
    'फिर इस के बाद 1 बार सूरह काफ़िरून पढ़ें',
    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِیْمِ\n'
        'قُلْ یٰٓاَیُّهَا الْکٰفِرُوْنَ۔ لَآ اَعْبُدُ مَا تَعْبُدُوْنَ۔ وَلَآ اَنْتُمْ عٰبِدُوْنَ مَآ اَعْبُدُ۔ '
        'وَلَآ اَنَا۠ عَابِدٌ مَّا عَبَدْتُّمْ۔ وَلَآ اَنْتُمْ عٰبِدُوْنَ مَآ اَعْبُدُ۔ لَکُمْ دِیْنُکُمْ وَلِیَ دِیْنِ',
  ),
  _FatihaStep(
    'फिर इस के बाद 3 बार सूरा इख़्लास पढ़ें',
    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِیْمِ\n'
        'قُلْ هُوَ اللّٰهُ اَحَدٌ۔ اَللّٰهُ الصَّمَدُ۔ لَمْ یَلِدْ وَلَمْ یُوْلَدْ۔ وَلَمْ یَکُنْ لَّهٗ کُفُوًا اَحَدٌ',
  ),
  _FatihaStep(
    'फिर इस के बाद 1 बार सूरा फ़लक़ पढ़ें',
    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِیْمِ\n'
        'قُلْ اَعُوْذُ بِرَبِّ الْفَلَقِ۔ مِنْ شَرِّ مَا خَلَقَ۔ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَ۔ '
        'وَمِنْ شَرِّ النَّفّٰثٰتِ فِی الْعُقَدِ۔ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ',
  ),
  _FatihaStep(
    'फिर इस के बाद 1 बार सूरा नास पढ़ें',
    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِیْمِ\n'
        'قُلْ اَعُوْذُ بِرَبِّ النَّاسِ۔ مَلِکِ النَّاسِ۔ اِلٰهِ النَّاسِ۔ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ۔ '
        'الَّذِیْ یُوَسْوِسُ فِیْ صُدُوْرِ النَّاسِ۔ مِنَ الْجِنَّةِ وَالنَّاسِ',
  ),
  _FatihaStep(
    'फिर इस के बाद 1 बार सूरह फातिहा पढ़ें',
    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِیْمِ\n'
        'اَلْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِیْنَ۔ الرَّحْمٰنِ الرَّحِیْمِ۔ مٰلِکِ یَوْمِ الدِّیْنِ۔ '
        'اِیَّاکَ نَعْبُدُ وَاِیَّاکَ نَسْتَعِیْنُ۔ اِهْدِنَا الصِّرَاطَ الْمُسْتَقِیْمَ۔ '
        'صِرَاطَ الَّذِیْنَ اَنْعَمْتَ عَلَیْهِمْ غَیْرِ الْمَغْضُوْبِ عَلَیْهِمْ وَلَا الضَّآلِّیْنَ',
  ),
  _FatihaStep(
    'फिर इस के बाद सूरह बक़रा की शुरुआती आयतें पढ़ें',
    'الٓمّٓ۔ ذٰلِکَ الْکِتٰبُ لَا رَیْبَ ۛ فِیْهِ ۛ هُدًی لِّلْمُتَّقِیْنَ۔ '
        'الَّذِیْنَ یُؤْمِنُوْنَ بِالْغَیْبِ وَیُقِیْمُوْنَ الصَّلٰوةَ وَمِمَّا رَزَقْنٰهُمْ یُنْفِقُوْنَ۔ '
        'وَالَّذِیْنَ یُؤْمِنُوْنَ بِمَآ اُنْزِلَ اِلَیْکَ وَمَآ اُنْزِلَ مِنْ قَبْلِکَ وَبِالْاٰخِرَةِ هُمْ یُوْقِنُوْنَ۔ '
        'اُولٰٓئِکَ عَلٰی هُدًی مِّنْ رَّبِّهِمْ ۖ وَاُولٰٓئِکَ هُمُ الْمُفْلِحُوْنَ',
  ),
  _FatihaStep(
    'फिर इस के बाद 1 बार आयतुल कुर्सी पढ़ें',
    'اَللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ الْحَیُّ الْقَیُّوْمُ ۚ لَا تَاْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌ ۭ '
        'لَهٗ مَا فِی السَّمٰوٰتِ وَمَا فِی الْاَرْضِ ۭ مَنْ ذَا الَّذِیْ یَشْفَعُ عِنْدَهٗ اِلَّا بِاِذْنِهٖ ۭ '
        'یَعْلَمُ مَا بَیْنَ اَیْدِیْهِمْ وَمَا خَلْفَهُمْ ۚ وَلَا یُحِیْطُوْنَ بِشَیْءٍ مِّنْ عِلْمِهٖ اِلَّا بِمَا شَآءَ ۚ '
        'وَسِعَ کُرْسِیُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۚ وَلَا یَـُٔوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِیُّ الْعَظِیْمُ',
  ),
  _FatihaStep(
    'फिर इस के बाद ये आयतें पढ़ें',
    'وَاِلٰـهُکُمْ اِلٰهٌ وَّاحِدٌ ۚ لَآ اِلٰهَ اِلَّا هُوَ الرَّحْمٰنُ الرَّحِیْمُ\n\n'
        'اِنَّ رَحْمَتَ اللّٰهِ قَرِیْبٌ مِّنَ الْمُحْسِنِیْنَ\n\n'
        'وَمَآ اَرْسَلْنٰکَ اِلَّا رَحْمَةً لِّلْعٰلَمِیْنَ\n\n'
        'مَا کَانَ مُحَمَّدٌ اَبَآ اَحَدٍ مِّنْ رِّجَالِکُمْ وَلٰکِنْ رَّسُوْلَ اللّٰهِ وَخَاتَمَ النَّبِیّٖنَ ۭ '
        'وَکَانَ اللّٰهُ بِکُلِّ شَیْءٍ عَلِیْمًا\n\n'
        'اِنَّ اللّٰهَ وَمَلٰٓئِکَتَهٗ یُصَلُّوْنَ عَلَی النَّبِیِّ ۭ یٰٓاَیُّهَا الَّذِیْنَ اٰمَنُوْا '
        'صَلُّوْا عَلَیْهِ وَسَلِّمُوْا تَسْلِیْمًا',
  ),
  _FatihaStep(
    'फिर आख़िर में 3 बार दरूद शरीफ पढ़ें',
    'اَللّٰهُمَّ صَلِّ عَلٰی سَیِّدِنَا مُحَمَّدٍ وَّاٰلِ سَیِّدِنَا مُحَمَّدٍ وَبَارِکْ وَسَلِّمْ',
  ),
];

/// "Fatiha ki Tariqa": step-by-step guide to reciting Fatiha for the
/// departed. Content ported from the Tasbih app.
class FatihaScreen extends StatelessWidget {
  const FatihaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fatiha ki Tariqa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < _steps.length; i++)
            _FatihaStepCard(index: i + 1, step: _steps[i]),
          const _FatihaClosingCard(),
        ],
      ),
    );
  }
}

class _FatihaStepCard extends StatelessWidget {
  final int index;
  final _FatihaStep step;

  const _FatihaStepCard({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = AppTheme.legibleAccent(context, AppTheme.primaryGreen);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: accent,
                  child: Text(
                    '$index',
                    style: textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.instruction,
                    style: textTheme.titleMedium?.copyWith(color: accent),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              step.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                height: 1.9,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FatihaClosingCard extends StatelessWidget {
  const _FatihaClosingCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = AppTheme.legibleAccent(context, AppTheme.primaryAmber);

    return Card(
      color: accent.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'अगर आप को कोई सूरह याद ना हो तो देख कर पढ़ सकते हैं।',
              style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Text(
              'तमाम सूरह पढ़ने के बाद अपने दो हाथों को उठाएं और अल्लाह की बरगाह में दुआ करें:',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text('दुआ', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '• या अल्लाह! अभी हम ने जो कुरान ए पाक की तिलावत की, इस में जो ख़ता ग़लती हुई हो माफ़ फ़रमा।',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• या अल्लाह! इस फ़ातिहा ख़्वानी को हुज़ूर सल्लल्लाहु अलैहि वसल्लम की बरगाह में पेश करते हैं, '
              'इसे तू क़बूल फ़रमा।',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
