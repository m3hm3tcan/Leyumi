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
      'Beslenme, bez ve büyüme kayıtları\nEksiksiz geçmiş\nKaranlık mod ve 3 dil';

  @override
  String get premiumPlanFeatures =>
      'Gelişmiş grafikler\nSüt stoğu\nPDF doktor raporları\nÇoklu çocuk profili';

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
      'Bu çocuk profili ile ilişkili tüm beslenme, bez, büyüme ve süt kayıtları kalıcı olarak silinecektir.';

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
  String get premiumPdfReports => 'PDF doktor raporları';

  @override
  String get doctorReport => 'Doktor Raporu';

  @override
  String get doctorReportDescription =>
      'Beslenme, bez ve büyüme kayıtlarını doktorunuz için anlaşılır bir özette birleştirin.';

  @override
  String get createShareableReport => 'Paylaşılabilir sağlık özeti oluştur';

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
  String get reportMedicalDisclaimer =>
      'Bu rapor, bakım veren tarafından girilen kayıtları özetler. Tıbbi tavsiye veya teşhis değildir. Bilgileri yetkili bir sağlık uzmanıyla değerlendiriniz.';

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
  String get sleepTitle => 'Uyku';

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
  String get milkTracking => 'Süt takibi';

  @override
  String get weightAndHeight => 'Kilo ve boy';

  @override
  String get diaperChanges => 'Bez değişiklikleri';

  @override
  String get sessionDeleted => 'Oturum silindi';

  @override
  String get undo => 'GERİ AL';

  @override
  String get yesterday => 'Dün';

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
  String feedingSideProgress(String side, String duration) {
    return '$side tarafı - $duration';
  }

  @override
  String get open => 'Aç';
}
