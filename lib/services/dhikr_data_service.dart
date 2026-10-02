// services/dhikr_data_service.dart
import '../models/dhikr_models.dart';

/// Service providing pre-defined Dhikr data
class DhikrDataService {
  
  /// Get all available Dhikr
  static List<Dhikr> getAllDhikr() {
    return [
      ..._getTasbihDhikr(),
      ..._getTahmidDhikr(),
      ..._getTakbirDhikr(),
      ..._getTahlilDhikr(),
      ..._getIstighfarDhikr(),
      ..._getSalawatDhikr(),
      ..._getDuaDhikr(),
      ..._getAsmaUlHusnaDhikr(),
      ..._getDailyWazifaDhikr(),
    ];
  }

  /// Get Dhikr by category
  static List<Dhikr> getDhikrByCategory(DhikrCategory category) {
    return getAllDhikr().where((dhikr) => dhikr.category == category).toList();
  }

  /// Get popular/recommended Dhikr
  static List<Dhikr> getPopularDhikr() {
    return [
      _subhanAllah(),
      _alhamdulillah(),
      _allahuAkbar(),
      _laIlahaIllallah(),
      _astaghfirullah(),
      _laHawlaWalaQuwwata(),
    ];
  }

  /// Tasbih (Glorification) Dhikr
  static List<Dhikr> _getTasbihDhikr() {
    return [
      _subhanAllah(),
      Dhikr(
        id: 'subhan_allah_wabihamdihi',
        arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        transliteration: 'Subhan Allah wa bihamdihi',
        translation: 'Glory be to Allah and praise be to Him',
        meaning: 'A comprehensive praise combining glorification and gratitude',
        targetCount: 100,
        category: DhikrCategory.tasbih,
        reward: 100, // Mentioned in hadith
      ),
      Dhikr(
        id: 'subhan_allah_azeem',
        arabic: 'سُبْحَانَ اللَّهِ الْعَظِيمِ',
        transliteration: 'Subhan Allah al-Azeem',
        translation: 'Glory be to Allah, the Great',
        meaning: 'Glorifying Allah with emphasis on His greatness',
        targetCount: 33,
        category: DhikrCategory.tasbih,
      ),
    ];
  }

  /// Tahmid (Praise) Dhikr
  static List<Dhikr> _getTahmidDhikr() {
    return [
      _alhamdulillah(),
      Dhikr(
        id: 'alhamdulillah_rabbil_alameen',
        arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        transliteration: 'Alhamdulillahi rabbil alameen',
        translation: 'All praise is due to Allah, Lord of the worlds',
        meaning: 'Comprehensive praise acknowledging Allah as the Lord of all creation',
        targetCount: 33,
        category: DhikrCategory.tahmid,
      ),
    ];
  }

  /// Takbir (Magnification) Dhikr
  static List<Dhikr> _getTakbirDhikr() {
    return [
      _allahuAkbar(),
      Dhikr(
        id: 'allah_akbar_kabiran',
        arabic: 'اللَّهُ أَكْبَرُ كَبِيرًا',
        transliteration: 'Allahu akbaru kabiran',
        translation: 'Allah is the Greatest, magnificently great',
        meaning: 'Emphasizing the supreme greatness of Allah',
        targetCount: 33,
        category: DhikrCategory.takbir,
      ),
    ];
  }

  /// Tahlil (Declaration of Faith) Dhikr
  static List<Dhikr> _getTahlilDhikr() {
    return [
      _laIlahaIllallah(),
      Dhikr(
        id: 'la_ilaha_illa_allah_wahdahu',
        arabic: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
        transliteration: 'La ilaha illa Allah wahdahu la sharika lah',
        translation: 'There is no god but Allah, alone, without partner',
        meaning: 'Complete declaration of monotheism and Allah\'s uniqueness',
        targetCount: 100,
        category: DhikrCategory.tahlil,
      ),
    ];
  }

  /// Istighfar (Seeking Forgiveness) Dhikr
  static List<Dhikr> _getIstighfarDhikr() {
    return [
      _astaghfirullah(),
      Dhikr(
        id: 'rabbighfirli',
        arabic: 'رَبِّ اغْفِرْ لِي',
        transliteration: 'Rabbi ghfir li',
        translation: 'My Lord, forgive me',
        meaning: 'Simple yet powerful plea for Allah\'s forgiveness',
        targetCount: 70,
        category: DhikrCategory.istighfar,
      ),
      Dhikr(
        id: 'astaghfirullah_aleem',
        arabic: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ',
        transliteration: 'Astaghfirullah al-azeem',
        translation: 'I seek forgiveness from Allah, the Great',
        meaning: 'Seeking forgiveness while acknowledging Allah\'s greatness',
        targetCount: 100,
        category: DhikrCategory.istighfar,
      ),
    ];
  }

  /// Salawat (Blessings on Prophet) Dhikr
  static List<Dhikr> _getSalawatDhikr() {
    return [
      Dhikr(
        id: 'salawat_simple',
        arabic: 'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
        transliteration: 'Sallallahu alayhi wa sallam',
        translation: 'May Allah\'s peace and blessings be upon him',
        meaning: 'Sending blessings upon Prophet Muhammad (PBUH)',
        targetCount: 100,
        category: DhikrCategory.salawat,
      ),
      Dhikr(
        id: 'salawat_ibrahimiya',
        arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
        transliteration: 'Allahumma salli ala Muhammad wa ala ali Muhammad',
        translation: 'O Allah, send blessings upon Muhammad and the family of Muhammad',
        meaning: 'The complete Salawat taught by the Prophet',
        targetCount: 10,
        category: DhikrCategory.salawat,
      ),
      Dhikr(
        id: 'salawat_shab_e_jumuah',
        arabic: 'اَللّٰھُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلٰی سَیِّدِنَا مُحَمَّدِنِ '
            'النَّبِیِّ الْاُمِّیِّ الْحَبِیْبِ الْعَالِی الْقَدْرِ الْعَظِیْمِ '
            'الْجَاہِ وَعَلٰی اٰلِہٖ وَصَحْبِہٖ وَسَلِّمْ',
        transliteration: "Allahumma salli wa sallim wa baarik 'alaa Sayyidinaa "
            "Muhammadinin-Nabiyyil Ummiyyil Habeebil 'Aalil Qadril 'Azeemil "
            "Jaahi, wa 'alaa aalihee wa sahbihee wa sallim",
        // Urdu wording as it appears in the source image (Dawat-e-Islami),
        // verbatim - not an English translation, per the user's preference.
        translation: 'بزرگوں نے فرمایا ہے کہ جو شخص ہر شب جمعہ (جمعہ اور جمعرات '
            'کی درمیانی رات) اس درود شریف کو پابندی سے کم از کم ایک مرتبہ '
            'پڑھے گا، موت کے وقت سرکارِ مدینہ صلی اللہ علیہ وسلم کی زیارت '
            'کرے گا اور قبر میں داخل ہوتے وقت بھی، یہاں تک کہ وہ دیکھے گا کہ '
            'سرکارِ مدینہ صلی اللہ علیہ وسلم اسے قبر میں اپنے رحمت بھرے '
            'ہاتھوں سے اُتار رہے ہیں۔ (افضل الصلوات علٰی سید السادات، '
            'ص۱۵۱ الملخصاً)',
        meaning: "Buzurgon ne farmaya hai ke jo shakhs har Shab-e-Jumu'ah "
            "(Jumu'ah aur Jumeraat ki darmiyani raat) is Durood Sharif ko "
            "pabandi se kam az kam ek martaba parhega, maut ke waqt "
            "Sarkar-e-Madina (sallallahu alaihi wasallam) ki ziyarat karega "
            "aur qabr mein dakhil hote waqt bhi, yahan tak ke woh dekhega ke "
            "Sarkar-e-Madina (sallallahu alaihi wasallam) use qabr mein apne "
            "rehmat bhare hathon se utaar rahe hain. (Afzal-us-Salawat ala "
            "Sayyid-is-Sadat, safha 151, Mulakhkhasan)",
        targetCount: 1,
        category: DhikrCategory.salawat,
      ),
    ];
  }

  /// Dua (Supplications) Dhikr
  static List<Dhikr> _getDuaDhikr() {
    return [
      _laHawlaWalaQuwwata(),
      Dhikr(
        id: 'hasbi_allah',
        arabic: 'حَسْبِيَ اللَّهُ',
        transliteration: 'Hasbi Allah',
        translation: 'Allah is sufficient for me',
        meaning: 'Expressing complete trust and reliance on Allah',
        targetCount: 70,
        category: DhikrCategory.dua,
      ),
      Dhikr(
        id: 'rabbana_atina',
        arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
        transliteration: 'Rabbana atina fi\'d-dunya hasanatan wa fi\'l-akhirati hasanatan',
        translation: 'Our Lord, give us good in this world and good in the hereafter',
        meaning: 'Comprehensive dua for success in both worlds',
        targetCount: 7,
        category: DhikrCategory.dua,
      ),
    ];
  }

  /// Asma ul-Husna (99 Names of Allah) - Sample
  static List<Dhikr> _getAsmaUlHusnaDhikr() {
    return [
      Dhikr(
        id: 'ar_rahman',
        arabic: 'الرَّحْمَنُ',
        transliteration: 'Ar-Rahman',
        translation: 'The Most Merciful',
        meaning: 'Allah who shows mercy to all creation',
        targetCount: 99,
        category: DhikrCategory.asmaUlHusna,
      ),
      Dhikr(
        id: 'ar_raheem',
        arabic: 'الرَّحِيمُ',
        transliteration: 'Ar-Raheem',
        translation: 'The Most Compassionate',
        meaning: 'Allah who shows special mercy to believers',
        targetCount: 99,
        category: DhikrCategory.asmaUlHusna,
      ),
      Dhikr(
        id: 'al_ghafoor',
        arabic: 'الْغَفُورُ',
        transliteration: 'Al-Ghafoor',
        translation: 'The Most Forgiving',
        meaning: 'Allah who forgives sins repeatedly',
        targetCount: 99,
        category: DhikrCategory.asmaUlHusna,
      ),
    ];
  }

  // Individual Dhikr constructors for reuse
  static Dhikr _subhanAllah() {
    return const Dhikr(
      id: 'subhan_allah',
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'Subhan Allah',
      translation: 'Glory be to Allah',
      meaning: 'Glorifying Allah and declaring Him free from any imperfection',
      targetCount: 33,
      category: DhikrCategory.tasbih,
    );
  }

  static Dhikr _alhamdulillah() {
    return const Dhikr(
      id: 'alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      translation: 'All praise is due to Allah',
      meaning: 'Praising Allah for all His blessings and attributes',
      targetCount: 33,
      category: DhikrCategory.tahmid,
    );
  }

  static Dhikr _allahuAkbar() {
    return const Dhikr(
      id: 'allahu_akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translation: 'Allah is the Greatest',
      meaning: 'Declaring Allah\'s supreme greatness above all creation',
      targetCount: 34,
      category: DhikrCategory.takbir,
    );
  }

  static Dhikr _laIlahaIllallah() {
    return const Dhikr(
      id: 'la_ilaha_illa_allah',
      arabic: 'لَا إِلَهَ إِلَّا اللَّهُ',
      transliteration: 'La ilaha illa Allah',
      translation: 'There is no god but Allah',
      meaning: 'The fundamental declaration of Islamic monotheism',
      targetCount: 100,
      category: DhikrCategory.tahlil,
    );
  }

  static Dhikr _astaghfirullah() {
    return const Dhikr(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      translation: 'I seek forgiveness from Allah',
      meaning: 'Asking Allah for forgiveness of sins and shortcomings',
      targetCount: 100,
      category: DhikrCategory.istighfar,
    );
  }

  static Dhikr _laHawlaWalaQuwwata() {
    return const Dhikr(
      id: 'la_hawla_wala_quwwata',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      transliteration: 'La hawla wa la quwwata illa billah',
      translation: 'There is no power except with Allah',
      meaning: 'Acknowledging that all strength and ability come from Allah alone',
      targetCount: 100,
      category: DhikrCategory.dua,
    );
  }

  /// Daily Wazifa: a recitation and virtue specific to each day of the
  /// week, per Imam Ghazali's Ihya Ulum-id-Din / Kimiya-e-Sa'adat (as
  /// compiled/circulated by Jamat Raza-e-Mustafa, Ajmer Sharif). Looked up
  /// by weekday via [DailyWazifaService] for the morning reminder and its
  /// tap-to-recite dialog; also browsable/countable here like any other
  /// Dhikr since each is a 100x count.
  static List<Dhikr> _getDailyWazifaDhikr() {
    return [
      const Dhikr(
        id: 'wazifa_sunday',
        arabic: 'يَا حَيُّ يَا قَيُّوْم',
        transliteration: 'Ya Hayyu Ya Qayyum',
        translation: '100 مرتبہ یَا حَیُّ یَا قَیُّوم پڑھنے سے غیب سے روزی ملتی '
            'ہے۔ (اِن شاء اللہ) (حجۃ الاسلام امام محمد غزالی رحمۃ اللہ علیہ '
            '- احیاء العلوم، کیمیا ے سعادت)',
        meaning: '100 martaba Ya Hayyu Ya Qayyum padhne se gaib se roji milti '
            'hai. (In Sha Allah) (Hujjat-ul-Islam Imam Muhammad Ghazali '
            "rahmatullahi alaih - Ihya-ul-Uloom, Kimiya-e-Sa'adat)",
        targetCount: 100,
        category: DhikrCategory.wazifa,
      ),
      const Dhikr(
        id: 'wazifa_monday',
        arabic: 'اَللّٰهُمَّ صَلِّ عَلٰی سَیِّدِنَا وَمَوْلَانَا مُحَمَّدٍ صَلَاةً '
            'تُحَلُّ بِهَا عُقَدَتِیْ وَتُفَرَّجُ بِهَا کُرْبَتِیْ وَتُنْقَذُ بِهَا '
            'وَحْلَتِیْ وَعَلٰی اٰلِہٖ وَصَحْبِہٖ وَسَلِّمْ عَدَدَ تَقَالِیْبِ '
            'الْاَیَّامِ وَالسِّنِیْنَ وَالْحَمْدُلِلّٰہِ رَبِّ الْعَالَمِیْنَ',
        transliteration: "Allahumma salli 'alaa Sayyidinaa wa Maulaanaa "
            "Muhammadin, salaatan tuhallu bihaa 'uqdatee wa tufarriju bihaa "
            "kurbatee wa tunqadhu bihaa wahlatee, wa 'alaa aalihee wa "
            "sahbihee wa sallim, 'adada taqaalibil ayyaami was-sineen, wal "
            "hamdu lillaahi rabbil 'aalameen",
        translation: '100 مرتبہ یہ درود شریف پڑھنے سے مقبولیت حاصل ہوتی ہے۔ '
            '(اِن شاء اللہ) (حجۃ الاسلام امام محمد غزالی رحمۃ اللہ علیہ - '
            'احیاء العلوم، کیمیا ے سعادت)',
        meaning: 'Durood Sharif 100 martaba padhne se maqbuliyat hasil hoti '
            'hai. (In Sha Allah) (Hujjat-ul-Islam Imam Muhammad Ghazali '
            "rahmatullahi alaih - Ihya-ul-Uloom, Kimiya-e-Sa'adat)",
        targetCount: 100,
        category: DhikrCategory.wazifa,
      ),
      const Dhikr(
        id: 'wazifa_tuesday',
        arabic: 'أَسْتَغْفِرُ اللّٰه',
        transliteration: 'Astaghfirullah',
        translation: '100 مرتبہ اَستغفراللہ پڑھنے سے بلا ٹلتی ہے۔ (اِن شاء '
            'اللہ) (حجۃ الاسلام امام محمد غزالی رحمۃ اللہ علیہ - احیاء '
            'العلوم، کیمیا ے سعادت)',
        meaning: '100 martaba Astaghfirullah padhne se bala talti hai. (In '
            "Sha Allah) (Hujjat-ul-Islam Imam Muhammad Ghazali rahmatullahi "
            "alaih - Ihya-ul-Uloom, Kimiya-e-Sa'adat)",
        targetCount: 100,
        category: DhikrCategory.wazifa,
      ),
      const Dhikr(
        id: 'wazifa_wednesday',
        arabic: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
        transliteration: 'Bismillah hir-Rahman nir-Raheem',
        translation: '100 مرتبہ بِسْمِ اللہِ الرَّحْمٰنِ الرَّحِیْم پڑھنے سے '
            'قبر کے عذاب سے نجات ملے گی۔ (اِن شاء اللہ) (حجۃ الاسلام امام '
            'محمد غزالی رحمۃ اللہ علیہ - احیاء العلوم، کیمیا ے سعادت)',
        meaning: '100 martaba Bismillah hir-Rahman nir-Rahim padhne se qabr '
            'ke azaab se najaat milegi. (In Sha Allah) (Hujjat-ul-Islam Imam '
            "Muhammad Ghazali rahmatullahi alaih - Ihya-ul-Uloom, "
            "Kimiya-e-Sa'adat)",
        targetCount: 100,
        category: DhikrCategory.wazifa,
      ),
      const Dhikr(
        id: 'wazifa_thursday',
        arabic: 'لَا اِلٰهَ اِلَّا اللّٰهُ الْمَلِکُ الْحَقُّ الْمُبِیْن',
        transliteration: 'La ilaha illallahul Malikul Haqqul Mubeen',
        translation: '100 مرتبہ لَا اِلٰہَ اِلَّا اللّٰہُ الْمَلِکُ الْحَقُّ '
            'الْمُبِیْن پڑھنے سے ایمان سے مالامال ہو جاتے ہیں۔ (اِن شاء اللہ) '
            '(حجۃ الاسلام امام محمد غزالی رحمۃ اللہ علیہ - احیاء العلوم، '
            'کیمیا ے سعادت)',
        meaning: '100 martaba La ilaha illallahul Malikul Haqqul Mubeen '
            'padhne se imaan se malamaal ho jate hain. (In Sha Allah) '
            "(Hujjat-ul-Islam Imam Muhammad Ghazali rahmatullahi alaih - "
            "Ihya-ul-Uloom, Kimiya-e-Sa'adat)",
        targetCount: 100,
        category: DhikrCategory.wazifa,
      ),
      const Dhikr(
        id: 'wazifa_friday',
        arabic: 'اللّٰه',
        transliteration: 'Allah',
        translation: '100 مرتبہ اللہ پڑھنے سے تنگی دور ہوتی ہے۔ (اِن شاء اللہ) '
            '(حجۃ الاسلام امام محمد غزالی رحمۃ اللہ علیہ - احیاء العلوم، '
            'کیمیا ے سعادت)',
        meaning: '100 martaba Allah padhne se tangi door hoti hai. (In Sha '
            "Allah) (Hujjat-ul-Islam Imam Muhammad Ghazali rahmatullahi "
            "alaih - Ihya-ul-Uloom, Kimiya-e-Sa'adat)",
        targetCount: 100,
        category: DhikrCategory.wazifa,
      ),
      const Dhikr(
        id: 'wazifa_saturday',
        arabic: 'لَا اِلٰهَ اِلَّا اللّٰه',
        transliteration: 'La ilaha illallah',
        translation: '100 مرتبہ لَا اِلٰہَ اِلَّا اللّٰہ پڑھنے سے دنیا کے غم '
            'دور ہوتے ہیں۔ (اِن شاء اللہ) (حجۃ الاسلام امام محمد غزالی رحمۃ '
            'اللہ علیہ - احیاء العلوم، کیمیا ے سعادت)',
        meaning: '100 martaba La ilaha illallah padhne se duniya ke gham '
            'door hote hain. (In Sha Allah) (Hujjat-ul-Islam Imam Muhammad '
            "Ghazali rahmatullahi alaih - Ihya-ul-Uloom, Kimiya-e-Sa'adat)",
        targetCount: 100,
        category: DhikrCategory.wazifa,
      ),
    ];
  }
}