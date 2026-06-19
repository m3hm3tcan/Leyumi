import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations == null) {
      throw Exception('AppLocalizations not found in context');
    }
    return localizations;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'appTitle': 'BabyFeed Pro',
      'homeTitle': 'Home',
      'feeding': 'Feeding',
      'history': 'History',
      'diaper': 'Diaper',
      'growth': 'Growth',
      'startSession': 'Start feeding session',
      'pastFeedings': 'Past feedings',
      'trackChanges': 'Track changes',
      'updateWeight': 'Update weight',
      'dangerZone': 'Danger Zone',
      'resetApp': 'Reset App (Clear All Data)',
      'confirmResetTitle': 'Reset App',
      'confirmResetContent': 'Are you sure you want to clear all app data?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'today': 'Today',
      'older': 'Older',
      'entryDeleted': 'Entry deleted',
      'swipeToDelete': 'Swipe left to delete',
      'swipeHintInfo': 'This hint shows during the first 3 opens.',
      'noDiaperRecordsYet': 'No diaper records yet',
      'addDiaperChangesHint': 'Add diaper changes from the home screen to track history.',
      'pee': 'Pee',
      'poop': 'Poop',
      'peeAndPoop': 'Pee & Poop',
      'amount': 'Amount',
      'color': 'Color',
      'note': 'Note',
      'diaperScreenTitle': 'Add Diaper Entry',
      'diaperType': 'Diaper Type',
      'peeAmountTitle': 'Pee Amount',
      'poopColor': 'Poop Color',
      'optionalNote': 'Optional note',
      'saveDiaperRecord': 'Save Diaper Record',
      'diaperRecordSaved': 'Diaper record saved',
      'small': 'Small',
      'medium': 'Medium',
      'large': 'Large',
      'yellow': 'Yellow',
      'brown': 'Brown',
      'green': 'Green',
      'black': 'Black',
      'mustardYellow': 'Mustard Yellow',
      'yellowGreen': 'Yellow Green',
      'darkGreen': 'Dark Green',
      'whiteGray': 'Gray White',
      'noFeedingSessionsYet': 'No feeding sessions yet',
      'startFeedingSessionHint': 'Start a feeding session to track your baby\'s feeding history in a clean timeline.',
      'totalFeedingDuration': 'Total feeding duration',
      'milk': 'Milk',
      'average': 'Average',
      'sessions': 'Sessions',
      'totalFeedingTime': 'Total feeding time',
      'comingSoon': 'Coming soon',
      'sleepTitle': 'Sleep',
      'babyInfoTitle': 'Baby Information',
      'babyNameLabel': 'Baby Name',
      'genderLabel': 'Gender',
      'genderMale': 'Male',
      'genderFemale': 'Female',
      'birthDateNotSelected': 'Birth date not selected',
      'selectDate': 'Select date',
      'saveContinue': 'Save and Continue',
      'requiredField': 'This field is required',
      'weightGr': 'Weight (g)',
      'heightCm': 'Height (cm)',
      'headCircumferenceOptional': 'Head Circumference (optional)',
      'waistCircumferenceOptional': 'Waist Circumference (optional)',
      'feedingSessionTitle': 'Feeding Session',
      'babyWeightGr': 'Baby Weight (g)',
      'exampleWeight': 'e.g. 2500',
      'liveSession': 'Live Session',
      'ready': 'Ready',
      'tapLeftOrRightToStart': 'Tap left or right to start',
      'leftSide': 'Left Side',
      'rightSide': 'Right Side',
      'live': 'Live',
      'stop': 'Stop',
      'feedingSummary': 'Feeding Summary',
      'leftLabel': 'Left',
      'rightLabel': 'Right',
      'totalLabel': 'Total',
      'feedingAfterWeight': 'Feeding After Weight',
      'save': 'Save',
      'currentLabel': 'Current',
      'enterNewValueHint': 'Enter new value',
      'currentGrowthSnapshot': 'Current Growth Snapshot',
      'saveGrowthRecord': 'Save Growth Record',
      'growthUpdateTitle': 'Growth Update',
      'historyHubTitle': 'History Hub',
      'historyHubSubtitle': 'Track everything about your baby',
      'milkTracking': 'Milk tracking',
      'weightAndHeight': 'Weight & height',
      'diaperChanges': 'Diaper changes',
      'sessionDeleted': 'Session deleted',
      'undo': 'UNDO',
      'yesterday': 'Yesterday',
      'thisWeek': 'This Week',
      'swipeHistoryTip': 'Tip: Swipe left on a feeding session to delete it.',
      'noGrowthDataYet': 'No growth data yet',
      'leftBreast': 'Left breast',
      'rightBreast': 'Right breast',
      'initialWeight': 'Initial weight',
      'finalWeight': 'Final weight',
      'milkIntake': 'Milk intake',
      'weight': 'Weight',
      'height': 'Height',
      'headCircumference': 'Head Circumference',
      'waistCircumference': 'Waist Circumference',
      'unitGr': 'g',
      'unitCm': 'cm',
      'weightHeightRequired': 'Weight and Height are required',
      'growthRecordSaved': 'Growth record saved',
      "growthHistoryTitle": 'Growth History',
      "yearsShort": "y",
      "monthsShort": "m",
      "daysShort": "d",
      "dateAndTime": "Date & Time",
      "feedingGraph": "Feeding Graph",
      "growthGraph": "Growth Graph",
      "diaperGraph": "Diaper Graph",
      "viewCharts" : "View charts",
      "growthCharts" : "Growth Charts",
      "manualFeedingEntry": "Manual Feeding Entry",
      "startTime": "Start Time",
      "endTime": "End Time",
      "select" : "Select",
      "leftRightRatio": "Left/Right Ratio",
      "noData": "No data",
      "noGrowthData": "No growth data",
      "filter7d": "7d",
      "filter30d": "30d",
      "filter90d": "90d",
      "filterAll": "All",
      "dateFormat": "{day}.{month}",
      "quickActions" : "Actions",
      "todayActivities" : "Today's Activity",
      "last" : "Last",
    },
    'tr': {
      'appTitle': 'BabyFeed Pro',
      'homeTitle': 'Ana Sayfa',
      'feeding': 'Beslenme',
      'history': 'Geçmiş',
      'diaper': 'Bez',
      'growth': 'Büyüme',
      'startSession': 'Emizrme Başlat',
      'pastFeedings': 'Kayitli Veriler',
      'trackChanges': 'Değişiklikleri takip et',
      'updateWeight': 'Kilosu Güncelle',
      'dangerZone': 'Tehlike Bölgesi',
      'resetApp': 'Uygulamayı Sıfırla (Tüm Verileri Sil)',
      'confirmResetTitle': 'Uygulamayı Sıfırla',
      'confirmResetContent': 'Tüm verileri silmek istediğinizden emin misiniz?',
      'cancel': 'İptal',
      'delete': 'Sil',
      'today': 'Bugün',
      'older': 'Daha eski',
      'entryDeleted': 'Kayıt silindi',
      'swipeToDelete': 'Silmek için sola kaydır',
      'swipeHintInfo': 'Bu ipucu ilk 3 açılışta gösterilir.',
      'noDiaperRecordsYet': 'Henüz bez kaydı yok',
      'addDiaperChangesHint': 'Geçmişi takip etmek için ana ekrandan bez değişiklikleri ekleyin.',
      'pee': 'İdrar',
      'poop': 'Dışkı',
      'peeAndPoop': 'İdrar & Dışkı',
      'amount': 'Miktar',
      'color': 'Renk',
      'note': 'Not',
      'diaperScreenTitle': 'Bez Kaydı Ekle',
      'diaperType': 'Bez Tipi',
      'peeAmountTitle': 'İdrar Miktarı',
      'poopColor': 'Dışkı Rengi',
      'optionalNote': 'Opsiyonel not',
      'saveDiaperRecord': 'Bez Kaydını Kaydet',
      'diaperRecordSaved': 'Bez kaydı kaydedildi',
      'small': 'Küçük',
      'medium': 'Orta',
      'large': 'Büyük',
      'yellow': 'Sarı',
      'brown': 'Kahverengi',
      'green': 'Yeşil',
      'black': 'Siyah',
      'mustardYellow': 'Hardal Sarısı',
      'yellowGreen': 'Sarı-Yeşil',
      'darkGreen': 'Koyu Yeşil',
      'whiteGray': 'Gri-Beyaz',
      'noFeedingSessionsYet': 'Henüz beslenme kaydı yok',
      'startFeedingSessionHint': 'Temiz bir zaman çizelgesinde bebeğinizin beslenme geçmişini takip etmek için bir beslenme seansı başlatın.',
      'totalFeedingDuration': 'Toplam beslenme süresi',
      'milk': 'Süt',
      'average': 'Ortalama',
      'sessions': 'Oturumlar',
      'totalFeedingTime': 'Toplam beslenme süresi',
      'comingSoon': 'Yakında',
      'sleepTitle': 'Uyku',
      'babyInfoTitle': 'Bebek Bilgileri',
      'babyNameLabel': 'Bebek Adı',
      'genderLabel': 'Cinsiyet',
      'genderMale': 'Erkek',
      'genderFemale': 'Kız',
      'birthDateNotSelected': 'Doğum tarihi seçilmedi',
      'selectDate': 'Tarih Seç',
      'saveContinue': 'Kaydet ve Devam Et',
      'requiredField': 'Bu alan zorunludur',
      'weightGr': 'Kilo (gr)',
      'heightCm': 'Boy (cm)',
      'headCircumferenceOptional': 'Kafa Çevresi (opsiyonel)',
      'waistCircumferenceOptional': 'Bel Çevresi (opsiyonel)',
      'feedingSessionTitle': 'Beslenme Seansı',
      'babyWeightGr': 'Bebeğin Kilosu (gr)',
      'exampleWeight': 'Örn: 2500',
      'liveSession': 'Canlı Seans',
      'ready': 'Hazır',
      'tapLeftOrRightToStart': 'Başlamak için sola veya sağa dokun',
      'leftSide': 'Sol Meme',
      'rightSide': 'Sağ Meme',
      'live': 'CANLI',
      'stop': 'Durdur',
      'feedingSummary': 'Beslenme Özeti',
      'leftLabel': 'Sol',
      'rightLabel': 'Sağ',
      'totalLabel': 'Toplam',
      'feedingAfterWeight': 'Beslenme Sonrası Kilo',
      'save': 'Kaydet',
      'currentLabel': 'Mevcut',
      'enterNewValueHint': 'Yeni değer girin',
      'currentGrowthSnapshot': 'Mevcut Büyüme Anlık Görünümü',
      'saveGrowthRecord': 'Büyüme Kaydını Kaydet',
      'historyHubTitle': 'Geçmiş Merkezi',
      'historyHubSubtitle': 'Bebeğinizle ilgili her şeyi takip edin',
      'milkTracking': 'Süt takibi',
      'weightAndHeight': 'Kilo ve boy',
      'diaperChanges': 'Bez değişiklikleri',
      'sessionDeleted': 'Oturum silindi',
      'undo': 'GERİ AL',
      'yesterday': 'Dün',
      'thisWeek': 'Bu Hafta',
      'swipeHistoryTip': 'İpucu: Silmek için bir beslenme oturumunu sola kaydırın.',
      'noGrowthDataYet': 'Henüz büyüme verisi yok',
      'leftBreast': 'Sol meme',
      'rightBreast': 'Sağ meme',
      'initialWeight': 'İlk kilo',
      'finalWeight': 'Son kilo',
      'milkIntake': 'İçilen süt',
      'weight': 'Kilo',
      'height': 'Boy',
      'headCircumference': 'Kafa Çevresi',
      'waistCircumference': 'Bel Çevresi',
      'unitGr': 'g',
      'unitCm': 'cm',
      'growthHistoryTitle': 'Büyüme Geçmişi',
      'weightHeightRequired': 'Kilo ve Boy zorunludur',
      'growthRecordSaved': 'Büyüme kaydı kaydedildi',
      "yearsShort": "y",
      "monthsShort": "a",
      "daysShort": "g",
      "dateAndTime": "Tarih ve Saat",
      "feedingGraph": "Beslenme Grafiği",
      "growthGraph": "Büyüme Grafiği",
      "diaperGraph": "Pelenka Grafiği",
      "viewCharts" : "Grafikleri Görüntüle",
      "growthCharts" : "Büyüme Grafikleri",
      "manualFeedingEntry": "Manuel Beslenme Kaydı",
      "startTime": "Başlangıç Zamanı",
      "endTime": "Bitiş Zamanı",
      "select" : "Seç",
      "leftRightRatio": "Sol/Sağ Oranı",
      "noData": "Veri yok",
      "noGrowthData": "Büyüme verisi yok",
      "filter7d": "7g",
      "filter30d": "30g",
      "filter90d": "90g",
      "filterAll": "Tümü",
      "dateFormat": "{day}.{month}",
      "quickActions" : "Gorevler",
      "todayActivities" : "Bugünkü Aktiviteler",
      "last" : "Son",
    },
    'hu': {
        'appTitle': 'BabyFeed Pro',
        'homeTitle': 'Főoldal',
        'feeding': 'Etetés',
        'history': 'Előzmények',
        'diaper': 'Pelenka',
        'growth': 'Növekedés',
        'startSession': 'Etetés indítása',
        'pastFeedings': 'Korábbi etetések',
        'trackChanges': 'Változások követése',
        'updateWeight': 'Súly frissítése',
        'dangerZone': 'Veszélyzóna',
        'resetApp': 'Alkalmazás visszaállítása (Összes adat törlése)',
        'confirmResetTitle': 'Alkalmazás visszaállítása',
        'confirmResetContent': 'Biztosan törölni szeretnéd az összes adatot?',
        'cancel': 'Mégse',
        'delete': 'Törlés',
        'today': 'Ma',
        'older': 'Korábbiak',
        'entryDeleted': 'Bejegyzés törölve',
        'swipeToDelete': 'Húzd balra a törléshez',
        'swipeHintInfo': 'Ez a tipp az első 3 megnyitáskor jelenik meg.',
        'noDiaperRecordsYet': 'Még nincs pelenka bejegyzés',
        'addDiaperChangesHint': 'Adj hozzá pelenkacserét a főoldalról az előzmények követéséhez.',
        'pee': 'Pisi',
        'poop': 'Kaki',
        'peeAndPoop': 'Pisi & Kaki',
        'amount': 'Mennyiség',
        'color': 'Szín',
        'note': 'Megjegyzés',
        'diaperScreenTitle': 'Pelenka bejegyzés hozzáadása',
        'diaperType': 'Pelenka típusa',
        'peeAmountTitle': 'Pisi mennyisége',
        'poopColor': 'Kaki színe',
        'optionalNote': 'Opcionális megjegyzés',
        'saveDiaperRecord': 'Pelenka bejegyzés mentése',
        'diaperRecordSaved': 'Pelenka bejegyzés mentve',
        'small': 'Kicsi',
        'medium': 'Közepes',
        'large': 'Nagy',
        'yellow': 'Sárga',
        'brown': 'Barna',
        'green': 'Zöld',
        'black': 'Fekete',
        'mustardYellow': 'Mustársárga',
        'yellowGreen': 'Sárga-zöld',
        'darkGreen': 'Sötétzöld',
        'whiteGray': 'Szürke-fehér',
        'noFeedingSessionsYet': 'Még nincs etetési bejegyzés',
        'startFeedingSessionHint': 'Indíts etetési folyamatot, hogy tiszta idővonalon követhesd a baba etetési előzményeit.',
        'totalFeedingDuration': 'Összes etetési idő',
        'milk': 'Tej',
        'average': 'Átlag',
        'sessions': 'Etetések',
        'totalFeedingTime': 'Összes etetési idő',
        'comingSoon': 'Hamarosan',
        'sleepTitle': 'Alvás',
        'babyInfoTitle': 'Baba adatai',
        'babyNameLabel': 'Baba neve',
        'genderLabel': 'Nem',
        'genderMale': 'Fiú',
        'genderFemale': 'Lány',
        'birthDateNotSelected': 'Születési dátum nincs kiválasztva',
        'selectDate': 'Dátum kiválasztása',
        'saveContinue': 'Mentés és folytatás',
        'requiredField': 'Ez a mező kötelező',
        'weightGr': 'Súly (g)',
        'heightCm': 'Magasság (cm)',
        'headCircumferenceOptional': 'Fejkörfogat (opcionális)',
        'waistCircumferenceOptional': 'Derékkörfogat (opcionális)',
        'feedingSessionTitle': 'Etetési folyamat',
        'babyWeightGr': 'Baba súlya (g)',
        'exampleWeight': 'pl. 2500',
        'liveSession': 'Élő folyamat',
        'ready': 'Kész',
        'tapLeftOrRightToStart': 'Kezdéshez érintsd meg a bal vagy jobb oldalt',
        'leftSide': 'Bal oldal',
        'rightSide': 'Jobb oldal',
        'live': 'ÉLŐ',
        'stop': 'Leállítás',
        'feedingSummary': 'Etetési összegzés',
        'leftLabel': 'Bal',
        'rightLabel': 'Jobb',
        'totalLabel': 'Összesen',
        'feedingAfterWeight': 'Etetés utáni súly',
        'save': 'Mentés',
        'currentLabel': 'Jelenlegi',
        'enterNewValueHint': 'Adj meg új értéket',
        'currentGrowthSnapshot': 'Aktuális növekedési állapot',
        'saveGrowthRecord': 'Növekedési adat mentése',
        'historyHubTitle': 'Előzmények központ',
        'historyHubSubtitle': 'Kövesd a babával kapcsolatos összes adatot',
        'milkTracking': 'Tej követése',
        'weightAndHeight': 'Súly és magasság',
        'diaperChanges': 'Pelenkacserék',
        'sessionDeleted': 'Etetés törölve',
        'undo': 'VISSZAVONÁS',
        'yesterday': 'Tegnap',
        'thisWeek': 'Ezen a héten',
        'swipeHistoryTip': 'Tipp: Húzd balra az etetési bejegyzést a törléshez.',
        'noGrowthDataYet': 'Még nincs növekedési adat',
        'leftBreast': 'Bal mell',
        'rightBreast': 'Jobb mell',
        'initialWeight': 'Kezdő súly',
        'finalWeight': 'Végső súly',
        'milkIntake': 'Elfogyasztott tej',
        'weight': 'Súly',
        'height': 'Magasság',
        'headCircumference': 'Fejkörfogat',
        'waistCircumference': 'Derékkörfogat',
        'unitGr': 'g',
        'unitCm': 'cm',
        'growthHistoryTitle': 'Növekedési előzmények',
        'weightHeightRequired': 'Súly és magasság kötelező',
        'growthRecordSaved': 'Növekedési adat mentve',
        "yearsShort": "év",
        "monthsShort": "hó",
        "daysShort": "nap",
        "dateAndTime": "Datum és idő",
        "feedingGraph": "Etetési grafikon",
        "growthGraph": "Növekedési grafikon",
        "diaperGraph": "Pelenka grafikon",
        "viewCharts" : "Grafikonok megtekintése",
        "growthCharts" : "Növekedési grafikonok",
        "manualFeedingEntry": "Manuális etetési bejegyzés",
        "startTime": "Kezdési idő",
        "endTime": "Befejezési idő",
        "select" : "Kiválasztás",
        "leftRightRatio": "Bal/Jobb arány",
        "noData": "Nincs adat",
        "noGrowthData": "Nincs növekedési adat",
        "filter7d": "7n",
        "filter30d": "30n",
        "filter90d": "90n",
        "filterAll": "Összes",
        "dateFormat": "{day}.{month}",
        "quickActions" : "Akciók",
        "todayActivities" : "Mai Tevékenységek",
        "last" : "Utolsó",

      },

  };

  String _getString(String key) {
    return _localizedStrings[locale.languageCode]?[key] ??
        _localizedStrings['en']![key] ??
        key;
  }

  String get appTitle => _getString('appTitle');
  String get homeTitle => _getString('homeTitle');
  String get feeding => _getString('feeding');
  String get history => _getString('history');
  String get diaper => _getString('diaper');
  String get growth => _getString('growth');
  String get startSession => _getString('startSession');
  String get pastFeedings => _getString('pastFeedings');
  String get trackChanges => _getString('trackChanges');
  String get updateWeight => _getString('updateWeight');
  String get dangerZone => _getString('dangerZone');
  String get resetApp => _getString('resetApp');
  String get confirmResetTitle => _getString('confirmResetTitle');
  String get confirmResetContent => _getString('confirmResetContent');
  String get cancel => _getString('cancel');
  String get delete => _getString('delete');
  String get today => _getString('today');
  String get older => _getString('older');
  String get noFeedingSessionsYet => _getString('noFeedingSessionsYet');
  String get startFeedingSessionHint => _getString('startFeedingSessionHint');
  String get totalFeedingDuration => _getString('totalFeedingDuration');
  String get milk => _getString('milk');
  String get average => _getString('average');
  String get sessions => _getString('sessions');
  String get totalFeedingTime => _getString('totalFeedingTime');
  String get entryDeleted => _getString('entryDeleted');
  String get swipeToDelete => _getString('swipeToDelete');
  String get swipeHintInfo => _getString('swipeHintInfo');
  String get noDiaperRecordsYet => _getString('noDiaperRecordsYet');
  String get addDiaperChangesHint => _getString('addDiaperChangesHint');
  String get pee => _getString('pee');
  String get poop => _getString('poop');
  String get peeAndPoop => _getString('peeAndPoop');
  String get amount => _getString('amount');
  String get color => _getString('color');
  String get note => _getString('note');
  String get diaperScreenTitle => _getString('diaperScreenTitle');
  String get diaperType => _getString('diaperType');
  String get peeAmountTitle => _getString('peeAmountTitle');
  String get poopColor => _getString('poopColor');
  String get optionalNote => _getString('optionalNote');
  String get saveDiaperRecord => _getString('saveDiaperRecord');
  String get diaperRecordSaved => _getString('diaperRecordSaved');
  String get small => _getString('small');
  String get medium => _getString('medium');
  String get large => _getString('large');
  String get yellow => _getString('yellow');
  String get brown => _getString('brown');
  String get green => _getString('green');
  String get black => _getString('black');
  String get mustardYellow => _getString('mustardYellow');
  String get yellowGreen => _getString('yellowGreen');
  String get darkGreen => _getString('darkGreen');
  String get whiteGray => _getString('whiteGray');
  String get comingSoon => _getString('comingSoon');
  String get sleepTitle => _getString('sleepTitle');
  String get babyInfoTitle => _getString('babyInfoTitle');
  String get babyNameLabel => _getString('babyNameLabel');
  String get genderLabel => _getString('genderLabel');
  String get genderMale => _getString('genderMale');
  String get genderFemale => _getString('genderFemale');
  String get birthDateNotSelected => _getString('birthDateNotSelected');
  String get selectDate => _getString('selectDate');
  String get saveContinue => _getString('saveContinue');
  String get requiredField => _getString('requiredField');
  String get weightGr => _getString('weightGr');
  String get heightCm => _getString('heightCm');
  String get headCircumferenceOptional => _getString('headCircumferenceOptional');
  String get waistCircumferenceOptional => _getString('waistCircumferenceOptional');
  String get feedingSessionTitle => _getString('feedingSessionTitle');
  String get babyWeightGr => _getString('babyWeightGr');
  String get exampleWeight => _getString('exampleWeight');
  String get liveSession => _getString('liveSession');
  String get ready => _getString('ready');
  String get tapLeftOrRightToStart => _getString('tapLeftOrRightToStart');
  String get leftSide => _getString('leftSide');
  String get rightSide => _getString('rightSide');
  String get live => _getString('live');
  String get stop => _getString('stop');
  String get feedingSummary => _getString('feedingSummary');
  String get leftLabel => _getString('leftLabel');
  String get rightLabel => _getString('rightLabel');
  String get totalLabel => _getString('totalLabel');
  String get feedingAfterWeight => _getString('feedingAfterWeight');
  String get save => _getString('save');
  String get currentLabel => _getString('currentLabel');
  String get enterNewValueHint => _getString('enterNewValueHint');
  String get currentGrowthSnapshot => _getString('currentGrowthSnapshot');
  String get saveGrowthRecord => _getString('saveGrowthRecord');
  String get growthUpdateTitle => _getString('growthUpdateTitle');
  String get growthHistoryTitle => _getString('growthHistoryTitle');
  String get historyHubTitle => _getString('historyHubTitle');
  String get historyHubSubtitle => _getString('historyHubSubtitle');
  String get milkTracking => _getString('milkTracking');
  String get weightAndHeight => _getString('weightAndHeight');
  String get diaperChanges => _getString('diaperChanges');
  String get sessionDeleted => _getString('sessionDeleted');
  String get undo => _getString('undo');
  String get yesterday => _getString('yesterday');
  String get thisWeek => _getString('thisWeek');
  String get swipeHistoryTip => _getString('swipeHistoryTip');
  String get noGrowthDataYet => _getString('noGrowthDataYet');
  String get leftBreast => _getString('leftBreast');
  String get rightBreast => _getString('rightBreast');
  String get initialWeight => _getString('initialWeight');
  String get finalWeight => _getString('finalWeight');
  String get milkIntake => _getString('milkIntake');
  String get weight => _getString('weight');
  String get height => _getString('height');
  String get headCircumference => _getString('headCircumference');
  String get waistCircumference => _getString('waistCircumference');
  String get unitGr => _getString('unitGr');
  String get unitCm => _getString('unitCm');
  String get weightHeightRequired => _getString('weightHeightRequired');
  String get growthRecordSaved => _getString('growthRecordSaved');
  String get yearsShort => _getString('yearsShort');
  String get monthsShort => _getString('monthsShort');
  String get daysShort => _getString('daysShort');
  String get dateAndTime => _getString('dateAndTime');
  String get feedingGraph => _getString('feedingGraph');
  String get growthGraph => _getString('growthGraph');
  String get diaperGraph => _getString('diaperGraph');
  String get growthCharts => _getString('growthCharts');
  String get viewCharts => _getString('viewCharts');
  String get manualFeedingEntry => _getString('manualFeedingEntry');
  String get startTime => _getString('startTime');
  String get endTime => _getString('endTime');
  String get select => _getString('select');
  String get leftRightRatio => _getString('leftRightRatio');
  String get noData => _getString('noData');
  String get noGrowthData => _getString('noGrowthData');
  String get filter7d => _getString('filter7d');
  String get filter30d => _getString('filter30d');
  String get filter90d => _getString('filter90d');
  String get filterAll => _getString('filterAll');
  String get dateFormat => _getString('dateFormat');
  String get quickActions => _getString('quickActions');
  String get todayActivities => _getString('todayActivities');
  String get last => _getString('last');

}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr', 'hu'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
