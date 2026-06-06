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
      'startSession': 'Start session',
      'pastFeedings': 'Past feedings',
      'trackChanges': 'Track changes',
      'updateWeight': 'Update weight',
      'dangerZone': 'Danger Zone',
      'resetApp': 'Reset App (Clear All Data)',
      'confirmResetTitle': 'Reset App',
      'confirmResetContent': 'Are you sure you want to clear all app data?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'undo': 'UNDO',
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
      'noFeedingSessionsYet': 'No feeding sessions yet',
      'startFeedingSessionHint': 'Start a feeding session to track your baby\'s feeding history in a clean timeline.',
      'totalFeedingDuration': 'Total feeding duration',
      'milk': 'Milk',
      'average': 'Average',
      'sessions': 'Sessions',
      'totalFeedingTime': 'Total feeding time',
      'comingSoon': 'Coming soon',
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
      'weight': 'Weight',
      'height': 'Height',
      'headCircumference': 'Head Circumference',
      'waistCircumference': 'Waist Circumference',
      'unitGr': 'g',
      'unitCm': 'cm',
      'weightHeightRequired': 'Weight and Height are required',
      'growthRecordSaved': 'Growth record saved',
    },
    'tr': {
      'appTitle': 'BabyFeed Pro',
      'homeTitle': 'Ana Sayfa',
      'feeding': 'Beslenme',
      'history': 'Geçmiş',
      'diaper': 'Bez',
      'growth': 'Büyüme',
      'startSession': 'Seansı Başlat',
      'pastFeedings': 'Geçmiş beslenmeler',
      'trackChanges': 'Değişiklikleri takip et',
      'updateWeight': 'Kilosu Güncelle',
      'dangerZone': 'Tehlike Bölgesi',
      'resetApp': 'Uygulamayı Sıfırla (Tüm Verileri Sil)',
      'confirmResetTitle': 'Uygulamayı Sıfırla',
      'confirmResetContent': 'Tüm verileri silmek istediğinizden emin misiniz?',
      'cancel': 'İptal',
      'delete': 'Sil',
      'undo': 'GERİ AL',
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
      'noFeedingSessionsYet': 'Henüz beslenme kaydı yok',
      'startFeedingSessionHint': 'Temiz bir zaman çizelgesinde bebeğinizin beslenme geçmişini takip etmek için bir beslenme seansı başlatın.',
      'totalFeedingDuration': 'Toplam beslenme süresi',
      'milk': 'Süt',
      'average': 'Ortalama',
      'sessions': 'Oturumlar',
      'totalFeedingTime': 'Toplam beslenme süresi',
      'comingSoon': 'Yakında',
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
      'growthUpdateTitle': 'Büyüme Güncelle',
      'weight': 'Kilo',
      'height': 'Boy',
      'headCircumference': 'Kafa Çevresi',
      'waistCircumference': 'Bel Çevresi',
      'unitGr': 'g',
      'unitCm': 'cm',
      'weightHeightRequired': 'Kilo ve Boy zorunludur',
      'growthRecordSaved': 'Büyüme kaydı kaydedildi',
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
  String get undo => _getString('undo');
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
  String get comingSoon => _getString('comingSoon');
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
  String get weight => _getString('weight');
  String get height => _getString('height');
  String get headCircumference => _getString('headCircumference');
  String get waistCircumference => _getString('waistCircumference');
  String get unitGr => _getString('unitGr');
  String get unitCm => _getString('unitCm');
  String get weightHeightRequired => _getString('weightHeightRequired');
  String get growthRecordSaved => _getString('growthRecordSaved');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
