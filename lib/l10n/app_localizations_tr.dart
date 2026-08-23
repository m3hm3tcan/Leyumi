// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get welcomeToLeyumi => 'Leyumi\'ye Hoş Geldiniz';

  @override
  String get onboardingWelcomeDescription =>
      'Bebeğinizin günlük bakımını ve gelişimini sakin, düzenli ve özel bir alanda takip edin.';

  @override
  String get onboardingTrackTitle => 'Her şey tek yerde';

  @override
  String get onboardingTrackDescription =>
      'Beslenme, bez değişimi, büyüme ve sağılan süt kayıtlarını küçük ayrıntıları kaybetmeden tutun.';

  @override
  String get onboardingFreePremiumTitle =>
      'Ücretsiz başlayın, ihtiyaç duyduğunuzda daha fazlasını açın';

  @override
  String get freePlan => 'Ücretsiz';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get freePlanFeatures =>
      'Beslenme, bez ve büyüme kayıtları\nBakım takvimi ve yaklaşan etkinlikler\nEksiksiz geçmiş, karanlık mod ve çoklu dil desteği';

  @override
  String get premiumPlanFeatures =>
      'Gelişmiş grafikler ve bakım planları\nSüt stoğu\nPDF bakım raporları\nÇoklu çocuk profili';

  @override
  String get onboardingPrivacyTitle => 'Aile verileriniz size aittir';

  @override
  String get onboardingPrivacyDescription =>
      'Kayıtlarınız bu cihazda yerel olarak saklanır. Raporu ne zaman oluşturup paylaşacağınıza siz karar verirsiniz.';

  @override
  String get createFirstChildProfile => 'Çocuğunuzun profilini oluşturun';

  @override
  String get onboardingChildDescription =>
      'Bu bilgiler kayıtları ve raporları kişiselleştirir. Daha sonra güncelleyebilirsiniz.';

  @override
  String get continueLabel => 'Devam Et';

  @override
  String get getStarted => 'Kullanmaya Başla';

  @override
  String get childProfiles => 'Çocuk Profilleri';

  @override
  String get addChildProfile => 'Çocuk Ekle';

  @override
  String get editChildProfile => 'Çocuğu Düzenle';

  @override
  String get switchChild => 'Çocuk değiştir';

  @override
  String get activeChild => 'Aktif çocuk';

  @override
  String get multipleChildrenPremiumHint =>
      'Ek çocuk profilleri Premium\'a dahildir.';

  @override
  String get deleteChildProfileTitle => 'Çocuk profili silinsin mi?';

  @override
  String get deleteChildProfileContent =>
      'Bu çocuk profili ile ilişkili tüm beslenme, bez, büyüme, süt ve bakım takvimi kayıtları kalıcı olarak silinecektir.';

  @override
  String get nameLengthError => 'İsim 2–30 karakter arasında olmalıdır.';

  @override
  String get weightRangeError => 'Kilo 500–30.000 g arasında olmalıdır.';

  @override
  String get heightRangeError => 'Boy 20–100 cm arasında olmalıdır.';

  @override
  String get headCircumferenceRangeError =>
      'Baş çevresi 20–70 cm arasında olmalıdır.';

  @override
  String get waistCircumferenceRangeError =>
      'Bel çevresi 20–100 cm arasında olmalıdır.';

  @override
  String get milkLabelLengthError => 'Etiket en fazla 30 karakter olabilir.';

  @override
  String get milkAmountRangeError => 'Süt miktarı 1–500 ml arasında olmalıdır.';

  @override
  String get futureDateTimeError => 'Tarih ve saat gelecekte olamaz.';

  @override
  String get selectFeedingTimesError => 'Başlangıç ve bitiş saatlerini seçin.';

  @override
  String get feedingTimeOrderError =>
      'Bitiş saati başlangıç saatinden sonra olmalıdır.';

  @override
  String get feedingDurationRangeError =>
      'Manuel beslenme kaydı 12 saatten uzun olamaz.';

  @override
  String get feedingBeforeBirthError =>
      'Beslenme tarihi çocuğun doğum tarihinden önce olamaz.';

  @override
  String get feedingDate => 'Beslenme tarihi';

  @override
  String get careCalendar => 'Bakım Takvimi';

  @override
  String get careCalendarSubtitle => 'Aşı, randevu ve ilaç takibi';

  @override
  String get addCareEvent => 'Etkinlik ekle';

  @override
  String get editCareEvent => 'Etkinliği düzenle';

  @override
  String get eventType => 'Etkinlik türü';

  @override
  String get eventTitle => 'Başlık';

  @override
  String get careTitleError => 'Başlık en az 2 karakter içermelidir.';

  @override
  String get careBeforeBirthError =>
      'Etkinlik tarihi çocuğun doğumundan önce olamaz.';

  @override
  String get carePastDateTimeError =>
      'Etkinlik tarihi ve saati gelecekte olmalıdır.';

  @override
  String get careTypeVaccine => 'Aşı';

  @override
  String get careTypeAppointment => 'Randevu';

  @override
  String get careTypeMedicine => 'İlaç';

  @override
  String get careTypeCheckup => 'Kontrol';

  @override
  String get careTypeLaboratory => 'Tahlil/Test';

  @override
  String get careTypeTherapy => 'Terapi';

  @override
  String get careTypeCustom => 'Diğer';

  @override
  String get contactOrLocation => 'Kişi veya konum';

  @override
  String get medicineDosage => 'İlaç dozu';

  @override
  String get repeatPlan => 'Tekrar planı';

  @override
  String get repeatNone => 'Tekrarlanmaz';

  @override
  String get repeatDaily => 'Her gün';

  @override
  String get repeatWeekly => 'Her hafta';

  @override
  String get repeatMonthly => 'Her ay';

  @override
  String get reminder => 'Hatırlatma';

  @override
  String get reminderNone => 'Hatırlatma yok';

  @override
  String get reminderOneHour => '1 saat önce';

  @override
  String get reminderOneDay => '1 gün önce';

  @override
  String get reminderTwoDays => '2 gün önce';

  @override
  String get reminderScheduled => 'Hatırlatma planlandı.';

  @override
  String get reminderTimeAlreadyPassed =>
      'Bu hatırlatma zamanı zaten geçmiş. Daha ileri bir etkinlik zamanı veya daha kısa bir hatırlatma seçin.';

  @override
  String get reminderCouldNotBeScheduled =>
      'Hatırlatma planlanamadı. Lütfen bildirim iznini kontrol edin.';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get later => 'Daha sonra';

  @override
  String get advancedCarePremiumHint =>
      'Tekrarlayan planlar ve ilaç dozu Premium\'a dahildir.';

  @override
  String get premiumCarePlanning => 'Gelişmiş bakım ve ilaç planları';

  @override
  String get noCareEventsForDay => 'Bu gün için planlanmış etkinlik yok.';

  @override
  String get markCompleted => 'Tamamlandı olarak işaretle';

  @override
  String get markCancelled => 'İptal edildi olarak işaretle';

  @override
  String get statusScheduled => 'Planlandı';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String get statusCancelled => 'İptal edildi';

  @override
  String get edit => 'Düzenle';

  @override
  String get upcomingCare => 'Yaklaşanlar';

  @override
  String get viewCalendar => 'Takvimi gör';

  @override
  String get tomorrow => 'Yarın';

  @override
  String inDays(int count) {
    return '$count gün içinde';
  }

  @override
  String get milkInventory => 'Süt Stoğu';

  @override
  String get addMilk => 'Süt Ekle';

  @override
  String get saveMilk => 'Sütü Kaydet';

  @override
  String get totalMilkStock => 'Toplam süt stoğu';

  @override
  String get refrigerator => 'Buzdolabı';

  @override
  String get freezer => 'Dondurucu';

  @override
  String get bottles => 'Şişe';

  @override
  String get all => 'Tümü';

  @override
  String get noStoredMilk => 'Henüz kayıtlı süt yok';

  @override
  String get noStoredMilkHint =>
      'İlk sağılmış süt şişenizi ekleyin; Leyumi tazelik süresini takip etsin.';

  @override
  String get labelNumber => 'Etiket numarası';

  @override
  String get amountMl => 'Miktar (ml)';

  @override
  String get storageLocation => 'Saklama yeri';

  @override
  String get expressedAt => 'Sağım tarihi ve saati';

  @override
  String get pumpedFrom => 'Sağılan taraf';

  @override
  String get mixed => 'Karışık';

  @override
  String get unspecified => 'Belirtilmedi';

  @override
  String get freshFor => 'Tazelik süresi';

  @override
  String get useWithin => 'Şu süre içinde kullanın:';

  @override
  String get expired => 'Süresi doldu';

  @override
  String get bestBefore => 'Son kullanım';

  @override
  String get hoursShort => 'sa';

  @override
  String get useMilk => 'Sütü Kullan';

  @override
  String get confirm => 'Onayla';

  @override
  String get moveToFreezer => 'Dondurucuya taşı';

  @override
  String get moveToRefrigerator => 'Buzdolabına taşı';

  @override
  String get deleteMilkTitle => 'Süt şişesi silinsin mi?';

  @override
  String get deleteMilkContent =>
      'Bu süt şişesini stoktan kaldırmak istediğinizden emin misiniz?';

  @override
  String get milkStorageSafetyNote =>
      'Taze süt buzdolabında 4 güne kadar; dondurucuda en iyi 6 ay içinde kullanılır. Küçük porsiyonlar israfı azaltabilir.';

  @override
  String get invalidMilkEntry =>
      'Etiket ve 1–500 ml arasında geçerli bir süt miktarı girin.';

  @override
  String get duplicateMilkLabel => 'Bu etiket numarası zaten kullanılıyor.';

  @override
  String get discardMilk => 'Sütü At';

  @override
  String get editMilkRecord => 'Kaydı Düzenle';

  @override
  String get deleteIncorrectRecord => 'Yanlış Kaydı Sil';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get milkHistory => 'Süt Geçmişi';

  @override
  String get usedAndRemainingMilk => 'Kullanılan ve kalan süt';

  @override
  String get remainingMilk => 'Kalan';

  @override
  String get usedMilk => 'Kullanılan süt';

  @override
  String get discardedMilk => 'Atılan süt';

  @override
  String get activity => 'Hareketler';

  @override
  String get insights => 'Analizler';

  @override
  String get noMilkHistory => 'Henüz süt hareketi yok';

  @override
  String get dailyMilkMovement => 'Eklenen ve kullanılan süt';

  @override
  String get last14Days => 'Son 14 gün';

  @override
  String get stockOverTime => 'Zaman içinde süt stoğu';

  @override
  String get addedMilk => 'Eklenen süt';

  @override
  String get milkAdded => 'Süt eklendi';

  @override
  String get remaining => 'Kalan';

  @override
  String get movedToFreezer => 'Dondurucuya taşındı';

  @override
  String get recordCorrected => 'Kayıt düzeltildi';

  @override
  String get premiumTitle => 'Leyumi Premium';

  @override
  String get unlockPremium => 'Premium ile daha fazlasını keşfedin';

  @override
  String get premiumDescription =>
      'Bebek bakım kayıtlarınızı anlaşılır analizlere dönüştürün ve verilerinizi güvenle bağlantılı tutun.';

  @override
  String get premiumIncludes => 'Premium özellikler';

  @override
  String get premiumAnalytics => 'Gelişmiş beslenme, bez ve büyüme analizleri';

  @override
  String get premiumPdfReports => 'PDF bakım raporları';

  @override
  String get careReport => 'Bakım Raporu';

  @override
  String get careReportDescription =>
      'Beslenme, bez ve büyüme kayıtlarını anlaşılır bir özette birleştirin.';

  @override
  String get createShareableReport => 'Paylaşılabilir bakım özeti oluştur';

  @override
  String get selectReportPeriod => 'Rapor dönemini seçin';

  @override
  String get last7Days => 'Son 7 gün';

  @override
  String get last30Days => 'Son 30 gün';

  @override
  String get last90Days => 'Son 90 gün';

  @override
  String get reportPeriod => 'Rapor dönemi';

  @override
  String get reportSummary => 'Özet';

  @override
  String get minutesShort => 'dk';

  @override
  String get secondsShort => 'sn';

  @override
  String get diaperSummary => 'Bez özeti';

  @override
  String get growthSummary => 'Büyüme özeti';

  @override
  String get dailyActivitySummary => 'Günlük aktivite özeti';

  @override
  String get growthMeasurements => 'Büyüme ölçümleri';

  @override
  String generatedOn(String date) {
    return '$date tarihinde oluşturuldu';
  }

  @override
  String get generatedByLeyumi => 'Leyumi tarafından oluşturuldu';

  @override
  String get noBabyProfile => 'Bebek profil bilgisi bulunamadı.';

  @override
  String get birthDate => 'Doğum tarihi';

  @override
  String get latestMeasurement => 'Son ölçüm';

  @override
  String get weightChange => 'Kilo değişimi';

  @override
  String get heightChange => 'Boy değişimi';

  @override
  String get noDataForPeriod => 'Bu dönem için kayıt bulunamadı.';

  @override
  String get duration => 'Süre';

  @override
  String get reportDisclaimer =>
      'Bu rapor, bakım veren tarafından girilen kayıtların genel bir özetidir ve profesyonel değerlendirme veya önerinin yerine geçmez.';

  @override
  String get createAndSharePdf => 'PDF Oluştur ve Paylaş';

  @override
  String get preparingReport => 'Rapor hazırlanıyor...';

  @override
  String get reportGenerationFailed =>
      'PDF raporu oluşturulamadı. Lütfen tekrar deneyin.';

  @override
  String get reportPrivacyNote =>
      'Rapor bu cihazda oluşturulur. Nerede ve kiminle paylaşılacağını siz seçersiniz.';

  @override
  String get reportIncludes => 'Raporun içeriği';

  @override
  String get babyInformation => 'Bebek bilgileri';

  @override
  String get premiumMultipleChildren => 'Çoklu çocuk profili';

  @override
  String get premiumCloudBackup => 'Bulut yedekleme ve cihaz senkronizasyonu';

  @override
  String get premiumSmartReminders => 'Akıllı hatırlatmalar';

  @override
  String get premiumMilkInventory => 'Süt stoğu yönetimi';

  @override
  String get upgradeToPremium => 'Premium’a Geç';

  @override
  String get premiumPurchaseComingSoon =>
      'Premium satın alma çok yakında kullanıma açılacak.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get premiumActive => 'Premium aktif';

  @override
  String get premiumInactive => 'Premium aktif değil';

  @override
  String get notificationSettings => 'Bildirim ayarları';

  @override
  String get notificationsPremiumHint =>
      'Akıllı hatırlatmalar Premium\'a dahildir.';

  @override
  String get notificationsEnabled => 'Bildirimler açık';

  @override
  String get notificationsDenied =>
      'Bildirim izni kapalı. Tekrar izin istemek veya sistem ayarlarından açmak için dokunun.';

  @override
  String get notificationsNotChecked => 'Bildirim izni henüz kontrol edilmedi.';

  @override
  String get sendTestNotification => 'Test bildirimi gönder';

  @override
  String get sendTestNotificationDescription =>
      'Bildirimlerin çalıştığını kontrol etmek için hemen bir test bildirimi göster.';

  @override
  String get testNotificationTitle => 'Leyumi hatırlatma';

  @override
  String get testNotificationBody =>
      'Bildirimler çalışıyor. Küçük zafer, büyük rahatlık.';

  @override
  String get testNotificationSent => 'Test bildirimi gönderildi.';

  @override
  String get darkMode => 'Karanlık mod';

  @override
  String get darkModeDescription =>
      'Açık ve karanlık görünüm arasında geçiş yap.';

  @override
  String get resetAppDescription =>
      'Yerel kayıtları sil ve onboarding ekranına dön.';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get confirmDeleteTitle => 'Kayıt silinsin mi?';

  @override
  String get confirmDeleteContent =>
      'Bu kaydı silmek istediğinizden emin misiniz? İşlemi kısa bir süre içinde geri alabilirsiniz.';

  @override
  String get confirmSaveTitle => 'Beslenme kaydı kaydedilsin mi?';

  @override
  String get confirmSaveContent =>
      'Bu beslenme kaydını kaydetmek istediğinizden emin misiniz?';

  @override
  String get dontSave => 'Kaydetme';

  @override
  String get appTitle => 'Leyumi';

  @override
  String get appSubtitle => 'Küçük ışığınızla birlikte büyüyoruz. 🌙✨';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get feeding => 'Beslenme';

  @override
  String get history => 'Geçmiş';

  @override
  String get diaper => 'Bez';

  @override
  String get growth => 'Büyüme';

  @override
  String get startSession => 'Emizrme Başlat';

  @override
  String get pastFeedings => 'Kayitli Veriler';

  @override
  String get trackChanges => 'Değişiklikleri takip et';

  @override
  String get updateWeight => 'Kilosu Güncelle';

  @override
  String get dangerZone => 'Tehlike Bölgesi';

  @override
  String get resetApp => 'Uygulamayı Sıfırla (Tüm Verileri Sil)';

  @override
  String get confirmResetTitle => 'Uygulamayı Sıfırla';

  @override
  String get confirmResetContent =>
      'Tüm verileri silmek istediğinizden emin misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get older => 'Daha eski';

  @override
  String get entryDeleted => 'Kayıt silindi';

  @override
  String get swipeToDelete => 'Silmek için sola kaydır';

  @override
  String get swipeHintInfo => 'Bu ipucu ilk 3 açılışta gösterilir.';

  @override
  String get noDiaperRecordsYet => 'Henüz bez kaydı yok';

  @override
  String get addDiaperChangesHint =>
      'Geçmişi takip etmek için ana ekrandan bez değişiklikleri ekleyin.';

  @override
  String get pee => 'İdrar';

  @override
  String get poop => 'Dışkı';

  @override
  String get peeAndPoop => 'İdrar & Dışkı';

  @override
  String get amount => 'Miktar';

  @override
  String get color => 'Renk';

  @override
  String get note => 'Not';

  @override
  String get diaperScreenTitle => 'Bez Kaydı Ekle';

  @override
  String get diaperType => 'Bez Tipi';

  @override
  String get peeAmountTitle => 'İdrar Miktarı';

  @override
  String get poopAmountTitle => 'Dışkı Miktarı';

  @override
  String get poopColor => 'Dışkı Rengi';

  @override
  String get optionalNote => 'Opsiyonel not';

  @override
  String get saveDiaperRecord => 'Bez Kaydını Kaydet';

  @override
  String get diaperRecordSaved => 'Bez kaydı kaydedildi';

  @override
  String get small => 'Küçük';

  @override
  String get medium => 'Orta';

  @override
  String get large => 'Büyük';

  @override
  String get yellow => 'Sarı';

  @override
  String get brown => 'Kahverengi';

  @override
  String get green => 'Yeşil';

  @override
  String get black => 'Siyah';

  @override
  String get mustardYellow => 'Hardal Sarısı';

  @override
  String get yellowGreen => 'Sarı-Yeşil';

  @override
  String get darkGreen => 'Koyu Yeşil';

  @override
  String get whiteGray => 'Gri-Beyaz';

  @override
  String get noFeedingSessionsYet => 'Henüz beslenme kaydı yok';

  @override
  String get startFeedingSessionHint =>
      'Temiz bir zaman çizelgesinde bebeğinizin beslenme geçmişini takip etmek için bir beslenme seansı başlatın.';

  @override
  String get totalFeedingDuration => 'Toplam beslenme süresi';

  @override
  String get milk => 'Süt';

  @override
  String get average => 'Ortalama';

  @override
  String get sessions => 'Oturumlar';

  @override
  String get totalFeedingTime => 'Toplam beslenme süresi';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get babyInfoTitle => 'Bebek Bilgileri';

  @override
  String get babyNameLabel => 'Bebek Adı';

  @override
  String get genderLabel => 'Cinsiyet';

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderFemale => 'Kız';

  @override
  String get birthDateNotSelected => 'Doğum tarihi seçilmedi';

  @override
  String get selectDate => 'Tarih Seç';

  @override
  String get saveContinue => 'Kaydet ve Devam Et';

  @override
  String get requiredField => 'Bu alan zorunludur';

  @override
  String get weightGr => 'Kilo (gr)';

  @override
  String get heightCm => 'Boy (cm)';

  @override
  String get birthWeightGr => 'Doğum kilosu (gr)';

  @override
  String get birthHeightCm => 'Doğum boyu (cm)';

  @override
  String get headCircumferenceOptional => 'Kafa Çevresi (opsiyonel)';

  @override
  String get waistCircumferenceOptional => 'Bel Çevresi (opsiyonel)';

  @override
  String get feedingSessionTitle => 'Beslenme Seansı';

  @override
  String get babyWeightGr => 'Bebeğin Kilosu (gr)';

  @override
  String get exampleWeight => 'Örn: 2500';

  @override
  String get liveSession => 'Canlı Seans';

  @override
  String get backLiveSession => 'Devam eden emizrme arka planda kaydedildi.';

  @override
  String get ready => 'Hazır';

  @override
  String get tapLeftOrRightToStart => 'Başlamak için sola veya sağa dokun';

  @override
  String get leftSide => 'Sol Meme';

  @override
  String get rightSide => 'Sağ Meme';

  @override
  String get live => 'CANLI';

  @override
  String get stop => 'Durdur';

  @override
  String get feedingSummary => 'Beslenme Özeti';

  @override
  String get leftLabel => 'Sol';

  @override
  String get rightLabel => 'Sağ';

  @override
  String get totalLabel => 'Toplam';

  @override
  String get feedingAfterWeight => 'Beslenme Sonrası Kilo';

  @override
  String get save => 'Kaydet';

  @override
  String get saving => 'Kaydediliyor...';

  @override
  String get saveFailed => 'Kayıt kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get operationFailed => 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';

  @override
  String get loadFailed => 'Kayıtlarınız yüklenemedi.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get currentLabel => 'Mevcut';

  @override
  String get enterNewValueHint => 'Yeni değer girin';

  @override
  String get currentGrowthSnapshot => 'Mevcut Büyüme Anlık Görünümü';

  @override
  String get saveGrowthRecord => 'Büyüme Kaydını Kaydet';

  @override
  String get growthUpdateTitle => 'Growth Update';

  @override
  String get historyHubTitle => 'Geçmiş Merkezi';

  @override
  String get historyHubSubtitle => 'Bebeğinizle ilgili her şeyi takip edin';

  @override
  String get timeline => 'Zaman Akışı';

  @override
  String get analytics => 'Analizler';

  @override
  String get reports => 'Raporlar';

  @override
  String get recordsOverview => 'Kayıt özeti';

  @override
  String get recentTimeline => 'Son kayıt akışı';

  @override
  String get noTimelineRecords =>
      'Henüz kayıt yok. Ana ekrandan takip etmeye başlayın.';

  @override
  String get analyticsHubTitle => 'Premium analizler';

  @override
  String get analyticsHubSubtitle =>
      'Beslenme, bez, büyüme ve süt için grafikler ve trendler.';

  @override
  String get reportsHubTitle => 'Raporlar';

  @override
  String get reportsHubSubtitle =>
      'Beslenme, bez ve büyüme kayıtlarının anlaşılır özetlerini oluşturun.';

  @override
  String get diaperPatterns => 'Bez düzeni';

  @override
  String get growthTrends => 'Büyüme trendleri';

  @override
  String get milkTracking => 'Süt takibi';

  @override
  String get weightAndHeight => 'Kilo ve boy';

  @override
  String get diaperChanges => 'Bez değişiklikleri';

  @override
  String diaperChangeCount(int count) {
    return '$count değişim';
  }

  @override
  String get recordedLabel => 'kaydedildi';

  @override
  String diaperDaySummary(int count, int peeCount, int poopCount) {
    return '$count değişim · $peeCount çiş · $poopCount kaka';
  }

  @override
  String get sessionDeleted => 'Oturum silindi';

  @override
  String get undo => 'GERİ AL';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get swipeHistoryTip =>
      'İpucu: Silmek için bir beslenme oturumunu sola kaydırın.';

  @override
  String get noGrowthDataYet => 'Henüz büyüme verisi yok';

  @override
  String get leftBreast => 'Sol meme';

  @override
  String get rightBreast => 'Sağ meme';

  @override
  String get initialWeight => 'İlk kilo';

  @override
  String get finalWeight => 'Son kilo';

  @override
  String get milkIntake => 'İçilen süt';

  @override
  String get weight => 'Kilo';

  @override
  String get height => 'Boy';

  @override
  String get headCircumference => 'Kafa Çevresi';

  @override
  String get waistCircumference => 'Bel Çevresi';

  @override
  String get unitGr => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitCm => 'cm';

  @override
  String get weightHeightRequired => 'Kilo ve Boy zorunludur';

  @override
  String get growthRecordSaved => 'Büyüme kaydı kaydedildi';

  @override
  String get growthHistoryTitle => 'Büyüme Geçmişi';

  @override
  String get yearsShort => 'y';

  @override
  String get monthsShort => 'a';

  @override
  String get daysShort => 'g';

  @override
  String get dateAndTime => 'Tarih ve Saat';

  @override
  String get feedingGraph => 'Beslenme Grafiği';

  @override
  String get growthGraph => 'Büyüme Grafiği';

  @override
  String get diaperGraph => 'Pelenka Grafiği';

  @override
  String get viewCharts => 'Grafikleri Görüntüle';

  @override
  String get growthCharts => 'Büyüme Grafikleri';

  @override
  String get growthJourney => 'Büyüme yolculuğu';

  @override
  String get measurementsByActualAge =>
      'Ölçümler çocuğun gerçek yaşına göre konumlandırılır';

  @override
  String get tapPointForDetails =>
      'Yaş, tarih ve değeri görmek için bir noktaya dokunun';

  @override
  String get tapChartPointForDetails =>
      'Tarih ve değeri görmek için bir noktaya dokunun';

  @override
  String get ageLabel => 'Yaş';

  @override
  String measurementCount(int count) {
    return '$count ölçüm';
  }

  @override
  String get manualFeedingEntry => 'Manuel Beslenme Kaydı';

  @override
  String get startTime => 'Başlangıç Zamanı';

  @override
  String get endTime => 'Bitiş Zamanı';

  @override
  String get select => 'Seç';

  @override
  String get leftRightRatio => 'Sol/Sağ Oranı';

  @override
  String get noData => 'Veri yok';

  @override
  String get noGrowthData => 'Büyüme verisi yok';

  @override
  String get filter7d => '7g';

  @override
  String get filter30d => '30g';

  @override
  String get filter90d => '90g';

  @override
  String get filterAll => 'Tümü';

  @override
  String dateFormat(int day, int month) {
    return '$day.$month';
  }

  @override
  String get quickActions => 'Gorevler';

  @override
  String get todayActivities => 'Bugünkü Aktiviteler';

  @override
  String get todayAtAGlance => 'Bugünün özeti';

  @override
  String todayRecordSummary(int feedingCount, int diaperCount) {
    return '$feedingCount beslenme · $diaperCount bez';
  }

  @override
  String todayFeedingDuration(String duration) {
    return 'Bugünkü beslenme süresi: $duration';
  }

  @override
  String get lastFeeding => 'Son beslenme';

  @override
  String get noFeedingRecordedYet => 'Henüz beslenme kaydı yok';

  @override
  String lastFeedingDetail(String side, String duration) {
    return '$side · $duration';
  }

  @override
  String get lastDiaperChange => 'Son bez değişimi';

  @override
  String get noDiaperRecordedYet => 'Henüz bez kaydı yok';

  @override
  String get justNow => 'Az önce';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get dashboardLoadFailed => 'Ana ekran özeti yüklenemedi.';

  @override
  String get quickDiaperTitle => 'Hızlı bez kaydı';

  @override
  String get quickDiaperSubtitle => 'Türü seç, tek dokunuşla kaydet';

  @override
  String get details => 'Ayrıntılar';

  @override
  String get quickWet => 'Islak';

  @override
  String get quickDirty => 'Kirli';

  @override
  String get quickBoth => 'İkisi';

  @override
  String get quickPeeSaved => 'Islak bez kaydedildi.';

  @override
  String get quickPoopSaved => 'Kirli bez kaydedildi.';

  @override
  String get quickBothSaved => 'Islak ve kirli bez kaydedildi.';

  @override
  String get quickDiaperSaveFailed =>
      'Hızlı bez kaydı kaydedilemedi. Tekrar deneyin.';

  @override
  String get quickDiaperUndone => 'Hızlı bez kaydı geri alındı.';

  @override
  String get quickDiaperUndoFailed => 'Kayıt geri alınamadı.';

  @override
  String get suggested => 'Önerilen';

  @override
  String get last => 'Son';

  @override
  String minutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count sa önce';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get liveFeedingContinues => 'Canlı beslenme devam ediyor';

  @override
  String get unsavedFeedingDraft => 'Kaydedilmemiş beslenme taslağı hazır';

  @override
  String get longFeedingWarning =>
      'Beslenme süresi uzadı. Kaydetmeyi unuttuysanız şimdi kaydedip beslenme geçmişinden saati düzenleyebilirsiniz.';

  @override
  String get activeFeedingNotificationTitle => 'Beslenme devam ediyor';

  @override
  String get activeFeedingNotificationBody =>
      'Beslenme zamanlayıcısı çalışıyor. Durdurmak veya kaydetmek için Leyumi\'yi açın.';

  @override
  String feedingSideProgress(String side, String duration) {
    return '$side tarafı - $duration';
  }

  @override
  String get privacyPolicyTitle => 'Gizlilik Politikası';

  @override
  String get privacyPolicySubtitle => 'Leyumi yerel verilerinizi nasıl korur';

  @override
  String get aboutLeyumiTitle => 'Leyumi Hakkında';

  @override
  String get aboutLeyumiBody =>
      'Leyumi, bakıcı tarafından girilen bebek bakım kayıtlarını düzenlemek için kullanılan çevrimdışı bir kayıt aracıdır. Tıbbi cihaz veya sağlık hizmeti değildir; tanı koymaz, herhangi bir hastalığı tedavi etmez, iyileştirmez ya da önlemez. Sağlıkla ilgili kararlar için yetkili bir sağlık profesyoneline danışılmalıdır.';

  @override
  String get privacyPolicyIntro =>
      'Leyumi çevrimdışı çalışan bir bebek bakım kayıt aracıdır. Bu sürüm hesap gerektirmez ve bakım kayıtlarınızı Leyumi Studio\'ya veya herhangi bir sunucuya göndermez.';

  @override
  String get privacyPurposeTitle => 'Leyumi\'nin amacı';

  @override
  String get privacyPurposeBody =>
      'Leyumi, yalnızca bakıcı tarafından girilen bebek bakım kayıtlarını düzenlemeye yardımcı olan çevrimdışı bir kayıt aracıdır. Tıbbi cihaz veya sağlık hizmeti değildir; sağlık önerisi, tanı, tedavi, acil durum yönlendirmesi ya da profesyonel değerlendirme sunmaz ve herhangi bir hastalığı iyileştirmez veya önlemez. Sağlıkla ilgili kararlar için yetkili bir sağlık profesyoneline danışılmalıdır.';

  @override
  String get privacyDataTitle => 'Uygulamanın kullandığı veriler';

  @override
  String get privacyDataBody =>
      'Leyumi; isteğe bağlı olarak girdiğiniz çocuk profillerini, doğum tarihlerini, büyüme ölçümlerini, beslenme ve bez kayıtlarını, süt stoğunu, bakım planlarını, ilaç ve aşı hatırlatma kayıtlarını ve uygulama tercihlerini yalnızca cihazınızda işler.';

  @override
  String get privacyStorageTitle => 'Yerel saklama';

  @override
  String get privacyStorageBody =>
      'Kayıtlarınız yalnızca bu cihazdaki Leyumi\'ye özel uygulama alanında yerel SQLite veritabanında saklanır. Bulut ve Android sistem yedeklemesi kapalıdır. Uygulamayı kaldırmak veya cihazı kaybetmek bu kayıtları kalıcı olarak kaybetmenize neden olabilir.';

  @override
  String get privacyBackupTitle => 'Kullanıcı kontrollü yedekleme';

  @override
  String get privacyBackupBody =>
      'Parolayla korunan şifreli bir .leyumi dosyası oluşturabilir ve başka bir cihazda geri yükleyebilirsiniz. Dosyanın kaydedileceği veya açılacağı yeri siz seçersiniz. Leyumi Studio dosyayı ya da parolayı almaz ve unutulan parolayı kurtaramaz.';

  @override
  String get privacySharingTitle => 'Veri toplama ve paylaşma';

  @override
  String get privacySharingBody =>
      'Leyumi Studio kişisel verilerinizi veya bakım kayıtlarınızı toplamaz, kendi sunucularına iletmez, satmaz, reklam ya da analiz için kullanmaz ve üçüncü taraflarla paylaşmaz. Bir raporu paylaşmayı veya yazdırmayı açıkça seçerseniz içerik yalnızca sizin seçtiğiniz hedefe aktarılır.';

  @override
  String get privacyRetentionTitle => 'Saklama ve silme';

  @override
  String get privacyRetentionBody =>
      'Kayıtlar siz silene, Leyumi\'yi sıfırlayana, uygulama verilerini temizleyene veya uygulamayı kaldırana kadar cihazınızda kalır. Ayarlar\'daki Leyumi\'yi Sıfırla işlemi yerel olarak saklanan tüm Leyumi verilerini kalıcı biçimde siler.';

  @override
  String get privacySecurityTitle => 'Güvenlik';

  @override
  String get privacySecurityBody =>
      'Leyumi yerel kayıtları korumak için Android uygulama alanına ve cihaz kilidinize dayanır. Cihazınızı güncel tutun ve PIN, parola veya biyometrik kilitle koruyun.';

  @override
  String get privacyContactTitle => 'İletişim';

  @override
  String get privacyContactBody =>
      'Gizlilikle ilgili sorular için Leyumi Studio ile leyumistudio@gmail.com adresinden iletişime geçin.';

  @override
  String get privacyPolicyEffectiveDate => 'Yürürlük tarihi: 20 Ağustos 2026';

  @override
  String get dataManagement => 'Veri yedekleme';

  @override
  String get dataManagementSubtitle => 'Şifreli dışa aktarma ve geri yükleme';

  @override
  String get backupData => 'Verilerimi yedekle';

  @override
  String get backupDataDescription =>
      'Parolayla korunan bir Leyumi yedek dosyası oluştur.';

  @override
  String get restoreData => 'Yedekten geri yükle';

  @override
  String get restoreDataDescription =>
      'Bu cihazdaki kayıtları bir Leyumi yedeğiyle değiştir.';

  @override
  String get createBackupPassword => 'Yedeğinizi koruyun';

  @override
  String get restoreBackupPassword => 'Yedek parolasını girin';

  @override
  String get backupPassword => 'Yedek parolası';

  @override
  String get confirmBackupPassword => 'Parolayı doğrula';

  @override
  String get backupPasswordRequirement =>
      '8–128 karakter kullanın. Bu parola Leyumi Studio tarafından kurtarılamaz.';

  @override
  String get backupPasswordsDoNotMatch => 'Parolalar eşleşmiyor.';

  @override
  String get backupSaved => 'Şifreli yedek kaydedildi.';

  @override
  String get restoreBackupTitle => 'Bu yedek geri yüklensin mi?';

  @override
  String restoreBackupSummary(String date, int profileCount, int recordCount) {
    return 'Oluşturma: $date · $profileCount profil · $recordCount kayıt';
  }

  @override
  String get restoreBackupWarning =>
      'Bu cihazdaki mevcut tüm Leyumi kayıtları değiştirilecek. Önceden alınmış başka bir yedeğiniz yoksa bu işlem geri alınamaz.';

  @override
  String get restoreNow => 'Şimdi geri yükle';

  @override
  String get restoreComplete => 'Yedek başarıyla geri yüklendi.';

  @override
  String get backupNoData =>
      'Yedek oluşturmadan önce bir çocuk profili ekleyin.';

  @override
  String get backupInvalidPassword =>
      'Parola yanlış veya yedek dosyası değiştirilmiş.';

  @override
  String get backupInvalidFile => 'Bu dosya geçerli bir Leyumi yedeği değil.';

  @override
  String get backupUnsupportedVersion =>
      'Bu yedek daha yeni ve desteklenmeyen bir Leyumi sürümüyle oluşturulmuş.';

  @override
  String get backupTooLarge => 'Yedek dosyası çok büyük.';

  @override
  String get backupOperationFailed => 'Yedekleme işlemi tamamlanamadı.';

  @override
  String get feedingAnalytics => 'Beslenme Analizleri';

  @override
  String get noFeedingData => 'Beslenme verisi yok';

  @override
  String get noDataInRange => 'Bu tarih aralığında veri yok';

  @override
  String get widerRangeFeedingHint =>
      'Beslenme eğilimlerini görmek için daha geniş bir tarih aralığı seçin.';

  @override
  String get dailyFeedingTime => 'Günlük beslenme süresi';

  @override
  String get dailyFeedingTimeSubtitle =>
      'Gün başına toplam aktif beslenme dakikası';

  @override
  String get sideBalance => 'Sol ve sağ dengesi';

  @override
  String get sideBalanceSubtitle => 'Her iki tarafın günlük beslenme süresi';

  @override
  String get milkIntakeSubtitle =>
      'Kilo bazlı seanslardan kaydedilen süt alımı';

  @override
  String get noMilkIntakeForPeriod => 'Bu dönem için süt alımı kaydedilmemiş.';

  @override
  String get diaperAnalytics => 'Bez Analizleri';

  @override
  String get noDiaperData => 'Bez verisi yok';

  @override
  String get overview => 'Genel bakış';

  @override
  String get dailyChanges => 'Günlük değişimler';

  @override
  String get dailyChangesSubtitle =>
      'Tam günü ve toplamı görmek için bir noktaya dokunun';

  @override
  String get dailyComposition => 'Günlük dağılım';

  @override
  String get dailyCompositionSubtitle =>
      'Güne göre çiş, kaka ve karışık değişimler';

  @override
  String get both => 'İkisi';

  @override
  String get peeAmountDistribution => 'Çiş miktarı dağılımı';

  @override
  String changesWithAmount(int count) {
    return '$count değişimde miktar bilgisi var';
  }

  @override
  String get activityByHour => 'Saatlere göre aktivite';

  @override
  String get activityByHourSubtitle =>
      'Bez değişimlerinin en sık ne zaman olduğunu görün';

  @override
  String get widerRangeDiaperHint =>
      'Bez eğilimlerini görmek için daha geniş bir tarih aralığı seçin.';

  @override
  String get open => 'Aç';
}
