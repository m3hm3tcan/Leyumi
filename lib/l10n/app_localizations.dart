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
      'milkInventory': 'Milk Inventory',
      'addMilk': 'Add Milk',
      'saveMilk': 'Save Milk',
      'totalMilkStock': 'Total milk stock',
      'refrigerator': 'Refrigerator',
      'freezer': 'Freezer',
      'bottles': 'Bottles',
      'all': 'All',
      'noStoredMilk': 'No stored milk yet',
      'noStoredMilkHint':
          'Add your first expressed milk bottle and Leyumi will track its freshness.',
      'labelNumber': 'Label number',
      'amountMl': 'Amount (ml)',
      'storageLocation': 'Storage location',
      'expressedAt': 'Expressed date and time',
      'pumpedFrom': 'Pumped from',
      'mixed': 'Mixed',
      'unspecified': 'Not specified',
      'freshFor': 'Fresh for',
      'useWithin': 'Use within',
      'expired': 'Expired',
      'bestBefore': 'Best before',
      'hoursShort': 'h',
      'useMilk': 'Use milk',
      'confirm': 'Confirm',
      'moveToFreezer': 'Move to freezer',
      'moveToRefrigerator': 'Move to refrigerator',
      'deleteMilkTitle': 'Delete milk bottle?',
      'deleteMilkContent':
          'Are you sure you want to remove this milk bottle from inventory?',
      'milkStorageSafetyNote':
          'Fresh milk: up to 4 days refrigerated; best used within 6 months frozen. Smaller portions can help reduce waste.',
      'invalidMilkEntry':
          'Enter a label and a milk amount between 1 and 500 ml.',
      'duplicateMilkLabel': 'This label number is already in use.',
      'discardMilk': 'Discard milk',
      'editMilkRecord': 'Edit record',
      'deleteIncorrectRecord': 'Delete incorrect record',
      'saveChanges': 'Save changes',
      'milkHistory': 'Milk History',
      'usedAndRemainingMilk': 'Used and remaining milk',
      'remainingMilk': 'Remaining',
      'usedMilk': 'Used milk',
      'discardedMilk': 'Discarded',
      'activity': 'Activity',
      'insights': 'Insights',
      'noMilkHistory': 'No milk activity yet',
      'dailyMilkMovement': 'Added and used milk',
      'last14Days': 'Last 14 days',
      'stockOverTime': 'Milk stock over time',
      'addedMilk': 'Added milk',
      'milkAdded': 'Milk added',
      'remaining': 'Remaining',
      'movedToFreezer': 'Moved to freezer',
      'recordCorrected': 'Record corrected',
      'premiumTitle': 'Leyumi Premium',
      'unlockPremium': 'Unlock more with Premium',
      'premiumDescription':
          'Turn your baby care records into clear insights and keep everything safely connected.',
      'premiumIncludes': 'Premium features',
      'premiumAnalytics': 'Advanced feeding, diaper and growth analytics',
      'premiumPdfReports': 'PDF doctor reports',
      'premiumMultipleChildren': 'Multiple child profiles',
      'premiumCloudBackup': 'Cloud backup and device sync',
      'premiumSmartReminders': 'Smart reminders',
      'premiumMilkInventory': 'Milk inventory management',
      'upgradeToPremium': 'Upgrade to Premium',
      'premiumPurchaseComingSoon':
          'Premium purchasing will be available soon.',
      'confirmDeleteTitle': 'Delete record?',
      'confirmDeleteContent':
          'Are you sure you want to delete this record? This action can be undone for a short time.',
      'confirmSaveTitle': 'Save feeding record?',
      'confirmSaveContent':
          'Are you sure you want to save this feeding record?',
      'dontSave': "Don't save",
      'appTitle': 'Leyumi',
      'appSubtitle': 'Growing with your little light. 🌙✨',
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
      'poopAmountTitle': 'Poop Amount',
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
      'backLiveSession': 'Ongoing breastfeeding was recorded in the background.',
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
      'milkInventory': 'Süt Stoğu',
      'addMilk': 'Süt Ekle',
      'saveMilk': 'Sütü Kaydet',
      'totalMilkStock': 'Toplam süt stoğu',
      'refrigerator': 'Buzdolabı',
      'freezer': 'Dondurucu',
      'bottles': 'Şişe',
      'all': 'Tümü',
      'noStoredMilk': 'Henüz kayıtlı süt yok',
      'noStoredMilkHint':
          'İlk sağılmış süt şişenizi ekleyin; Leyumi tazelik süresini takip etsin.',
      'labelNumber': 'Etiket numarası',
      'amountMl': 'Miktar (ml)',
      'storageLocation': 'Saklama yeri',
      'expressedAt': 'Sağım tarihi ve saati',
      'pumpedFrom': 'Sağılan taraf',
      'mixed': 'Karışık',
      'unspecified': 'Belirtilmedi',
      'freshFor': 'Tazelik süresi',
      'useWithin': 'Şu süre içinde kullanın:',
      'expired': 'Süresi doldu',
      'bestBefore': 'Son kullanım',
      'hoursShort': 'sa',
      'useMilk': 'Sütü Kullan',
      'confirm': 'Onayla',
      'moveToFreezer': 'Dondurucuya taşı',
      'moveToRefrigerator': 'Buzdolabına taşı',
      'deleteMilkTitle': 'Süt şişesi silinsin mi?',
      'deleteMilkContent':
          'Bu süt şişesini stoktan kaldırmak istediğinizden emin misiniz?',
      'milkStorageSafetyNote':
          'Taze süt buzdolabında 4 güne kadar; dondurucuda en iyi 6 ay içinde kullanılır. Küçük porsiyonlar israfı azaltabilir.',
      'invalidMilkEntry':
          'Etiket ve 1–500 ml arasında geçerli bir süt miktarı girin.',
      'duplicateMilkLabel': 'Bu etiket numarası zaten kullanılıyor.',
      'discardMilk': 'Sütü At',
      'editMilkRecord': 'Kaydı Düzenle',
      'deleteIncorrectRecord': 'Yanlış Kaydı Sil',
      'saveChanges': 'Değişiklikleri Kaydet',
      'milkHistory': 'Süt Geçmişi',
      'usedAndRemainingMilk': 'Kullanılan ve kalan süt',
      'remainingMilk': 'Kalan',
      'usedMilk': 'Kullanılan süt',
      'discardedMilk': 'Atılan süt',
      'activity': 'Hareketler',
      'insights': 'Analizler',
      'noMilkHistory': 'Henüz süt hareketi yok',
      'dailyMilkMovement': 'Eklenen ve kullanılan süt',
      'last14Days': 'Son 14 gün',
      'stockOverTime': 'Zaman içinde süt stoğu',
      'addedMilk': 'Eklenen süt',
      'milkAdded': 'Süt eklendi',
      'remaining': 'Kalan',
      'movedToFreezer': 'Dondurucuya taşındı',
      'recordCorrected': 'Kayıt düzeltildi',
      'premiumTitle': 'Leyumi Premium',
      'unlockPremium': 'Premium ile daha fazlasını keşfedin',
      'premiumDescription':
          'Bebek bakım kayıtlarınızı anlaşılır analizlere dönüştürün ve verilerinizi güvenle bağlantılı tutun.',
      'premiumIncludes': 'Premium özellikler',
      'premiumAnalytics': 'Gelişmiş beslenme, bez ve büyüme analizleri',
      'premiumPdfReports': 'PDF doktor raporları',
      'premiumMultipleChildren': 'Çoklu çocuk profili',
      'premiumCloudBackup': 'Bulut yedekleme ve cihaz senkronizasyonu',
      'premiumSmartReminders': 'Akıllı hatırlatmalar',
      'premiumMilkInventory': 'Süt stoğu yönetimi',
      'upgradeToPremium': 'Premium’a Geç',
      'premiumPurchaseComingSoon':
          'Premium satın alma çok yakında kullanıma açılacak.',
      'confirmDeleteTitle': 'Kayıt silinsin mi?',
      'confirmDeleteContent':
          'Bu kaydı silmek istediğinizden emin misiniz? İşlemi kısa bir süre içinde geri alabilirsiniz.',
      'confirmSaveTitle': 'Beslenme kaydı kaydedilsin mi?',
      'confirmSaveContent':
          'Bu beslenme kaydını kaydetmek istediğinizden emin misiniz?',
      'dontSave': 'Kaydetme',
      'appTitle': 'Leyumi',
      'appSubtitle': 'Küçük ışığınızla birlikte büyüyoruz. 🌙✨',
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
      'poopAmountTitle': 'Dışkı Miktarı',
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
      'backLiveSession' : 'Devam eden emizrme arka planda kaydedildi.',
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
        'milkInventory': 'Tejkészlet',
        'addMilk': 'Tej hozzáadása',
        'saveMilk': 'Tej mentése',
        'totalMilkStock': 'Teljes tejkészlet',
        'refrigerator': 'Hűtőszekrény',
        'freezer': 'Fagyasztó',
        'bottles': 'Palackok',
        'all': 'Összes',
        'noStoredMilk': 'Még nincs tárolt tej',
        'noStoredMilkHint':
            'Add hozzá az első lefejt tejet, és a Leyumi követi a frissességét.',
        'labelNumber': 'Címkeszám',
        'amountMl': 'Mennyiség (ml)',
        'storageLocation': 'Tárolás helye',
        'expressedAt': 'Fejés dátuma és ideje',
        'pumpedFrom': 'Fejés oldala',
        'mixed': 'Vegyes',
        'unspecified': 'Nincs megadva',
        'freshFor': 'Friss még',
        'useWithin': 'Használd fel',
        'expired': 'Lejárt',
        'bestBefore': 'Minőségét megőrzi',
        'hoursShort': 'ó',
        'useMilk': 'Tej felhasználása',
        'confirm': 'Megerősítés',
        'moveToFreezer': 'Áthelyezés a fagyasztóba',
        'moveToRefrigerator': 'Áthelyezés a hűtőbe',
        'deleteMilkTitle': 'Törlöd a tejes palackot?',
        'deleteMilkContent':
            'Biztosan eltávolítod ezt a tejes palackot a készletből?',
        'milkStorageSafetyNote':
            'A friss tej hűtőben legfeljebb 4 napig, fagyasztva lehetőleg 6 hónapon belül használható fel. A kisebb adagok csökkenthetik a pazarlást.',
        'invalidMilkEntry':
            'Adj meg egy címkét és 1–500 ml közötti tejmennyiséget.',
        'duplicateMilkLabel': 'Ez a címkeszám már használatban van.',
        'discardMilk': 'Tej kiöntése',
        'editMilkRecord': 'Bejegyzés szerkesztése',
        'deleteIncorrectRecord': 'Hibás bejegyzés törlése',
        'saveChanges': 'Módosítások mentése',
        'milkHistory': 'Tejelőzmények',
        'usedAndRemainingMilk': 'Felhasznált és megmaradt tej',
        'remainingMilk': 'Megmaradt',
        'usedMilk': 'Felhasznált tej',
        'discardedMilk': 'Kiöntött tej',
        'activity': 'Tevékenység',
        'insights': 'Elemzések',
        'noMilkHistory': 'Még nincs tejjel kapcsolatos esemény',
        'dailyMilkMovement': 'Hozzáadott és felhasznált tej',
        'last14Days': 'Utolsó 14 nap',
        'stockOverTime': 'Tejkészlet időbeli változása',
        'addedMilk': 'Hozzáadott tej',
        'milkAdded': 'Tej hozzáadva',
        'remaining': 'Megmaradt',
        'movedToFreezer': 'Fagyasztóba helyezve',
        'recordCorrected': 'Bejegyzés javítva',
        'premiumTitle': 'Leyumi Premium',
        'unlockPremium': 'Fedezz fel többet a Premiummal',
        'premiumDescription':
            'Alakítsd a babaápolási adatokat áttekinthető elemzésekké, és tarts mindent biztonságosan összekapcsolva.',
        'premiumIncludes': 'Premium funkciók',
        'premiumAnalytics':
            'Fejlett etetési, pelenka- és növekedési elemzések',
        'premiumPdfReports': 'PDF orvosi jelentések',
        'premiumMultipleChildren': 'Több gyermekprofil',
        'premiumCloudBackup': 'Felhőmentés és eszközszinkronizálás',
        'premiumSmartReminders': 'Intelligens emlékeztetők',
        'premiumMilkInventory': 'Tejkészlet kezelése',
        'upgradeToPremium': 'Váltás Premiumra',
        'premiumPurchaseComingSoon':
            'A Premium vásárlás hamarosan elérhető lesz.',
        'confirmDeleteTitle': 'Törlöd a bejegyzést?',
        'confirmDeleteContent':
            'Biztosan törölni szeretnéd ezt a bejegyzést? A művelet rövid ideig visszavonható.',
        'confirmSaveTitle': 'Mented az etetési bejegyzést?',
        'confirmSaveContent':
            'Biztosan menteni szeretnéd ezt az etetési bejegyzést?',
        'dontSave': 'Ne mentsd',
        'appTitle': 'Leyumi',
        'appSubtitle': 'Együtt növekszünk a kis fényeddel. 🌙✨',
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
        'poopAmountTitle': 'Kaki mennyisége',
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
        'backLiveSession': 'A háttérben rögzítették a folyamatos szoptatást.',
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

  String get milkInventory => _getString('milkInventory');
  String get addMilk => _getString('addMilk');
  String get saveMilk => _getString('saveMilk');
  String get totalMilkStock => _getString('totalMilkStock');
  String get refrigerator => _getString('refrigerator');
  String get freezer => _getString('freezer');
  String get bottles => _getString('bottles');
  String get all => _getString('all');
  String get noStoredMilk => _getString('noStoredMilk');
  String get noStoredMilkHint => _getString('noStoredMilkHint');
  String get labelNumber => _getString('labelNumber');
  String get amountMl => _getString('amountMl');
  String get storageLocation => _getString('storageLocation');
  String get expressedAt => _getString('expressedAt');
  String get pumpedFrom => _getString('pumpedFrom');
  String get mixed => _getString('mixed');
  String get unspecified => _getString('unspecified');
  String get freshFor => _getString('freshFor');
  String get useWithin => _getString('useWithin');
  String get expired => _getString('expired');
  String get bestBefore => _getString('bestBefore');
  String get hoursShort => _getString('hoursShort');
  String get useMilk => _getString('useMilk');
  String get confirm => _getString('confirm');
  String get moveToFreezer => _getString('moveToFreezer');
  String get moveToRefrigerator => _getString('moveToRefrigerator');
  String get deleteMilkTitle => _getString('deleteMilkTitle');
  String get deleteMilkContent => _getString('deleteMilkContent');
  String get milkStorageSafetyNote => _getString('milkStorageSafetyNote');
  String get invalidMilkEntry => _getString('invalidMilkEntry');
  String get duplicateMilkLabel => _getString('duplicateMilkLabel');
  String get discardMilk => _getString('discardMilk');
  String get editMilkRecord => _getString('editMilkRecord');
  String get deleteIncorrectRecord => _getString('deleteIncorrectRecord');
  String get saveChanges => _getString('saveChanges');
  String get milkHistory => _getString('milkHistory');
  String get usedAndRemainingMilk => _getString('usedAndRemainingMilk');
  String get remainingMilk => _getString('remainingMilk');
  String get usedMilk => _getString('usedMilk');
  String get discardedMilk => _getString('discardedMilk');
  String get activity => _getString('activity');
  String get insights => _getString('insights');
  String get noMilkHistory => _getString('noMilkHistory');
  String get dailyMilkMovement => _getString('dailyMilkMovement');
  String get last14Days => _getString('last14Days');
  String get stockOverTime => _getString('stockOverTime');
  String get addedMilk => _getString('addedMilk');
  String get milkAdded => _getString('milkAdded');
  String get remaining => _getString('remaining');
  String get movedToFreezer => _getString('movedToFreezer');
  String get recordCorrected => _getString('recordCorrected');
  String get premiumTitle => _getString('premiumTitle');
  String get unlockPremium => _getString('unlockPremium');
  String get premiumDescription => _getString('premiumDescription');
  String get premiumIncludes => _getString('premiumIncludes');
  String get premiumAnalytics => _getString('premiumAnalytics');
  String get premiumPdfReports => _getString('premiumPdfReports');
  String get premiumMultipleChildren => _getString('premiumMultipleChildren');
  String get premiumCloudBackup => _getString('premiumCloudBackup');
  String get premiumSmartReminders => _getString('premiumSmartReminders');
  String get premiumMilkInventory => _getString('premiumMilkInventory');
  String get upgradeToPremium => _getString('upgradeToPremium');
  String get premiumPurchaseComingSoon =>
      _getString('premiumPurchaseComingSoon');
  String get appTitle => _getString('appTitle');
  String get appSubtitle => _getString('appSubtitle');
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
  String get confirmDeleteTitle => _getString('confirmDeleteTitle');
  String get confirmDeleteContent => _getString('confirmDeleteContent');
  String get confirmSaveTitle => _getString('confirmSaveTitle');
  String get confirmSaveContent => _getString('confirmSaveContent');
  String get dontSave => _getString('dontSave');
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
  String get poopAmountTitle => _getString('poopAmountTitle');
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
  String get backLiveSession => _getString('backLiveSession');
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
