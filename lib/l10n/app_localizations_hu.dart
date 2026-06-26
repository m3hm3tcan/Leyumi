// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get welcomeToLeyumi => 'Üdvözöl a Leyumi';

  @override
  String get onboardingWelcomeDescription =>
      'Nyugodt és privát hely a baba mindennapi gondozásának és fejlődésének követéséhez.';

  @override
  String get onboardingTrackTitle => 'Minden egy helyen';

  @override
  String get onboardingTrackDescription =>
      'Rögzítsd az etetést, pelenkacserét, növekedést és lefejt tejet az apró részletek elvesztése nélkül.';

  @override
  String get onboardingFreePremiumTitle =>
      'Kezdd ingyen, és oldj fel többet, amikor szükséged van rá';

  @override
  String get freePlan => 'Ingyenes';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get freePlanFeatures =>
      'Etetési, pelenka- és növekedési adatok\nGondozási naptár és közelgő események\nTeljes előzmény, sötét mód és 3 nyelv';

  @override
  String get premiumPlanFeatures =>
      'Fejlett grafikonok és gondozási tervek\nTejkészlet\nPDF orvosi jelentések\nTöbb gyermekprofil';

  @override
  String get onboardingPrivacyTitle => 'A családi adataid a tieid maradnak';

  @override
  String get onboardingPrivacyDescription =>
      'A bejegyzések helyben, ezen az eszközön tárolódnak. Te döntöd el, mikor készítesz vagy osztasz meg jelentést.';

  @override
  String get createFirstChildProfile => 'Hozd létre gyermeked profilját';

  @override
  String get onboardingChildDescription =>
      'Ezek az adatok személyre szabják a bejegyzéseket és jelentéseket. Később módosíthatók.';

  @override
  String get continueLabel => 'Tovább';

  @override
  String get getStarted => 'Kezdés';

  @override
  String get childProfiles => 'Gyermekprofilok';

  @override
  String get addChildProfile => 'Gyermek hozzáadása';

  @override
  String get editChildProfile => 'Gyermek szerkesztése';

  @override
  String get switchChild => 'Gyermekváltás';

  @override
  String get activeChild => 'Aktív gyermek';

  @override
  String get multipleChildrenPremiumHint =>
      'További gyermekprofilok a Premium részei.';

  @override
  String get deleteChildProfileTitle => 'Törlöd a gyermekprofilt?';

  @override
  String get deleteChildProfileContent =>
      'A gyermekprofilhoz tartozó összes etetési, pelenka-, növekedési, tej- és gondozási naptáradat véglegesen törlődik.';

  @override
  String get nameLengthError => 'A névnek 2–30 karakter hosszúnak kell lennie.';

  @override
  String get weightRangeError =>
      'A súlynak 500 és 30 000 g között kell lennie.';

  @override
  String get heightRangeError =>
      'A magasságnak 20 és 100 cm között kell lennie.';

  @override
  String get headCircumferenceRangeError =>
      'A fejkörfogatnak 20 és 70 cm között kell lennie.';

  @override
  String get waistCircumferenceRangeError =>
      'A derékbőségnek 20 és 100 cm között kell lennie.';

  @override
  String get milkLabelLengthError =>
      'A címke legfeljebb 30 karakter hosszú lehet.';

  @override
  String get milkAmountRangeError =>
      'A tejmennyiségnek 1 és 500 ml között kell lennie.';

  @override
  String get futureDateTimeError => 'A dátum és az idő nem lehet a jövőben.';

  @override
  String get selectFeedingTimesError =>
      'Válaszd ki a kezdési és befejezési időt.';

  @override
  String get feedingTimeOrderError =>
      'A befejezési időnek későbbinek kell lennie a kezdési időnél.';

  @override
  String get feedingDurationRangeError =>
      'A kézi etetési bejegyzés nem lehet hosszabb 12 óránál.';

  @override
  String get feedingBeforeBirthError =>
      'Az etetés dátuma nem lehet korábbi a gyermek születési dátumánál.';

  @override
  String get feedingDate => 'Etetés dátuma';

  @override
  String get careCalendar => 'Gondozási naptár';

  @override
  String get careCalendarSubtitle => 'Oltások, időpontok és gyógyszerek';

  @override
  String get addCareEvent => 'Esemény hozzáadása';

  @override
  String get editCareEvent => 'Esemény szerkesztése';

  @override
  String get eventType => 'Esemény típusa';

  @override
  String get eventTitle => 'Cím';

  @override
  String get careTitleError => 'A cím legalább 2 karakterből álljon.';

  @override
  String get careBeforeBirthError =>
      'Az esemény dátuma nem lehet korábbi a gyermek születésénél.';

  @override
  String get careTypeVaccine => 'Oltás';

  @override
  String get careTypeDoctor => 'Orvos';

  @override
  String get careTypeMedicine => 'Gyógyszer';

  @override
  String get careTypeCheckup => 'Ellenőrzés';

  @override
  String get careTypeLaboratory => 'Labor/Teszt';

  @override
  String get careTypeTherapy => 'Terápia';

  @override
  String get careTypeCustom => 'Egyéb';

  @override
  String get doctorOrLocation => 'Orvos vagy helyszín';

  @override
  String get medicineDosage => 'Gyógyszeradag';

  @override
  String get repeatPlan => 'Ismétlődési terv';

  @override
  String get repeatNone => 'Nem ismétlődik';

  @override
  String get repeatDaily => 'Naponta';

  @override
  String get repeatWeekly => 'Hetente';

  @override
  String get repeatMonthly => 'Havonta';

  @override
  String get reminder => 'Emlékeztető';

  @override
  String get reminderNone => 'Nincs emlékeztető';

  @override
  String get reminderOneHour => '1 órával előtte';

  @override
  String get reminderOneDay => '1 nappal előtte';

  @override
  String get reminderTwoDays => '2 nappal előtte';

  @override
  String get advancedCarePremiumHint =>
      'Az ismétlődő tervek és gyógyszeradagok a Premium részei.';

  @override
  String get premiumCarePlanning => 'Fejlett gondozási és gyógyszertervek';

  @override
  String get noCareEventsForDay => 'Erre a napra nincs tervezett esemény.';

  @override
  String get markCompleted => 'Megjelölés teljesítettként';

  @override
  String get markCancelled => 'Megjelölés töröltként';

  @override
  String get statusScheduled => 'Tervezett';

  @override
  String get statusCompleted => 'Teljesítve';

  @override
  String get statusCancelled => 'Törölve';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get upcomingCare => 'Közelgő események';

  @override
  String get viewCalendar => 'Naptár megnyitása';

  @override
  String get tomorrow => 'Holnap';

  @override
  String inDays(int count) {
    return '$count nap múlva';
  }

  @override
  String get milkInventory => 'Tejkészlet';

  @override
  String get addMilk => 'Tej hozzáadása';

  @override
  String get saveMilk => 'Tej mentése';

  @override
  String get totalMilkStock => 'Teljes tejkészlet';

  @override
  String get refrigerator => 'Hűtőszekrény';

  @override
  String get freezer => 'Fagyasztó';

  @override
  String get bottles => 'Palackok';

  @override
  String get all => 'Összes';

  @override
  String get noStoredMilk => 'Még nincs tárolt tej';

  @override
  String get noStoredMilkHint =>
      'Add hozzá az első lefejt tejet, és a Leyumi követi a frissességét.';

  @override
  String get labelNumber => 'Címkeszám';

  @override
  String get amountMl => 'Mennyiség (ml)';

  @override
  String get storageLocation => 'Tárolás helye';

  @override
  String get expressedAt => 'Fejés dátuma és ideje';

  @override
  String get pumpedFrom => 'Fejés oldala';

  @override
  String get mixed => 'Vegyes';

  @override
  String get unspecified => 'Nincs megadva';

  @override
  String get freshFor => 'Friss még';

  @override
  String get useWithin => 'Használd fel';

  @override
  String get expired => 'Lejárt';

  @override
  String get bestBefore => 'Minőségét megőrzi';

  @override
  String get hoursShort => 'ó';

  @override
  String get useMilk => 'Tej felhasználása';

  @override
  String get confirm => 'Megerősítés';

  @override
  String get moveToFreezer => 'Áthelyezés a fagyasztóba';

  @override
  String get moveToRefrigerator => 'Áthelyezés a hűtőbe';

  @override
  String get deleteMilkTitle => 'Törlöd a tejes palackot?';

  @override
  String get deleteMilkContent =>
      'Biztosan eltávolítod ezt a tejes palackot a készletből?';

  @override
  String get milkStorageSafetyNote =>
      'A friss tej hűtőben legfeljebb 4 napig, fagyasztva lehetőleg 6 hónapon belül használható fel. A kisebb adagok csökkenthetik a pazarlást.';

  @override
  String get invalidMilkEntry =>
      'Adj meg egy címkét és 1–500 ml közötti tejmennyiséget.';

  @override
  String get duplicateMilkLabel => 'Ez a címkeszám már használatban van.';

  @override
  String get discardMilk => 'Tej kiöntése';

  @override
  String get editMilkRecord => 'Bejegyzés szerkesztése';

  @override
  String get deleteIncorrectRecord => 'Hibás bejegyzés törlése';

  @override
  String get saveChanges => 'Módosítások mentése';

  @override
  String get milkHistory => 'Tejelőzmények';

  @override
  String get usedAndRemainingMilk => 'Felhasznált és megmaradt tej';

  @override
  String get remainingMilk => 'Megmaradt';

  @override
  String get usedMilk => 'Felhasznált tej';

  @override
  String get discardedMilk => 'Kiöntött tej';

  @override
  String get activity => 'Tevékenység';

  @override
  String get insights => 'Elemzések';

  @override
  String get noMilkHistory => 'Még nincs tejjel kapcsolatos esemény';

  @override
  String get dailyMilkMovement => 'Hozzáadott és felhasznált tej';

  @override
  String get last14Days => 'Utolsó 14 nap';

  @override
  String get stockOverTime => 'Tejkészlet időbeli változása';

  @override
  String get addedMilk => 'Hozzáadott tej';

  @override
  String get milkAdded => 'Tej hozzáadva';

  @override
  String get remaining => 'Megmaradt';

  @override
  String get movedToFreezer => 'Fagyasztóba helyezve';

  @override
  String get recordCorrected => 'Bejegyzés javítva';

  @override
  String get premiumTitle => 'Leyumi Premium';

  @override
  String get unlockPremium => 'Fedezz fel többet a Premiummal';

  @override
  String get premiumDescription =>
      'Alakítsd a babaápolási adatokat áttekinthető elemzésekké, és tarts mindent biztonságosan összekapcsolva.';

  @override
  String get premiumIncludes => 'Premium funkciók';

  @override
  String get premiumAnalytics =>
      'Fejlett etetési, pelenka- és növekedési elemzések';

  @override
  String get premiumPdfReports => 'PDF orvosi jelentések';

  @override
  String get doctorReport => 'Orvosi jelentés';

  @override
  String get doctorReportDescription =>
      'Készíts áttekinthető összefoglalót az etetési, pelenka- és növekedési adatokról az orvos számára.';

  @override
  String get createShareableReport => 'Megosztható egészségügyi összefoglaló';

  @override
  String get selectReportPeriod => 'Jelentési időszak kiválasztása';

  @override
  String get last7Days => 'Utolsó 7 nap';

  @override
  String get last30Days => 'Utolsó 30 nap';

  @override
  String get last90Days => 'Utolsó 90 nap';

  @override
  String get reportPeriod => 'Jelentési időszak';

  @override
  String get reportSummary => 'Összefoglaló';

  @override
  String get minutesShort => 'perc';

  @override
  String get secondsShort => 'mp';

  @override
  String get diaperSummary => 'Pelenka összefoglaló';

  @override
  String get growthSummary => 'Növekedési összefoglaló';

  @override
  String get dailyActivitySummary => 'Napi tevékenységek';

  @override
  String get growthMeasurements => 'Növekedési mérések';

  @override
  String generatedOn(String date) {
    return 'Létrehozva: $date';
  }

  @override
  String get generatedByLeyumi => 'Készítette a Leyumi';

  @override
  String get noBabyProfile => 'A baba profiladatai nem érhetők el.';

  @override
  String get birthDate => 'Születési dátum';

  @override
  String get latestMeasurement => 'Legutóbbi mérés';

  @override
  String get weightChange => 'Súlyváltozás';

  @override
  String get heightChange => 'Magasságváltozás';

  @override
  String get noDataForPeriod => 'Ebben az időszakban nincs rögzített adat.';

  @override
  String get duration => 'Időtartam';

  @override
  String get reportMedicalDisclaimer =>
      'Ez a jelentés a gondozó által rögzített adatokat foglalja össze. Nem minősül orvosi tanácsnak vagy diagnózisnak. Az adatokat szakképzett egészségügyi szakemberrel értékelje.';

  @override
  String get createAndSharePdf => 'PDF létrehozása és megosztása';

  @override
  String get preparingReport => 'Jelentés készítése...';

  @override
  String get reportGenerationFailed =>
      'A PDF-jelentést nem sikerült létrehozni. Próbáld újra.';

  @override
  String get reportPrivacyNote =>
      'A jelentés ezen az eszközön készül. Te döntöd el, hol és kivel osztod meg.';

  @override
  String get reportIncludes => 'A jelentés tartalma';

  @override
  String get babyInformation => 'Baba adatai';

  @override
  String get premiumMultipleChildren => 'Több gyermekprofil';

  @override
  String get premiumCloudBackup => 'Felhőmentés és eszközszinkronizálás';

  @override
  String get premiumSmartReminders => 'Intelligens emlékeztetők';

  @override
  String get premiumMilkInventory => 'Tejkészlet kezelése';

  @override
  String get upgradeToPremium => 'Váltás Premiumra';

  @override
  String get premiumPurchaseComingSoon =>
      'A Premium vásárlás hamarosan elérhető lesz.';

  @override
  String get confirmDeleteTitle => 'Törlöd a bejegyzést?';

  @override
  String get confirmDeleteContent =>
      'Biztosan törölni szeretnéd ezt a bejegyzést? A művelet rövid ideig visszavonható.';

  @override
  String get confirmSaveTitle => 'Mented az etetési bejegyzést?';

  @override
  String get confirmSaveContent =>
      'Biztosan menteni szeretnéd ezt az etetési bejegyzést?';

  @override
  String get dontSave => 'Ne mentsd';

  @override
  String get appTitle => 'Leyumi';

  @override
  String get appSubtitle => 'Együtt növekszünk a kis fényeddel. 🌙✨';

  @override
  String get homeTitle => 'Főoldal';

  @override
  String get feeding => 'Etetés';

  @override
  String get history => 'Előzmények';

  @override
  String get diaper => 'Pelenka';

  @override
  String get growth => 'Növekedés';

  @override
  String get startSession => 'Etetés indítása';

  @override
  String get pastFeedings => 'Korábbi etetések';

  @override
  String get trackChanges => 'Változások követése';

  @override
  String get updateWeight => 'Súly frissítése';

  @override
  String get dangerZone => 'Veszélyzóna';

  @override
  String get resetApp => 'Alkalmazás visszaállítása (Összes adat törlése)';

  @override
  String get confirmResetTitle => 'Alkalmazás visszaállítása';

  @override
  String get confirmResetContent =>
      'Biztosan törölni szeretnéd az összes adatot?';

  @override
  String get cancel => 'Mégse';

  @override
  String get delete => 'Törlés';

  @override
  String get today => 'Ma';

  @override
  String get older => 'Korábbiak';

  @override
  String get entryDeleted => 'Bejegyzés törölve';

  @override
  String get swipeToDelete => 'Húzd balra a törléshez';

  @override
  String get swipeHintInfo => 'Ez a tipp az első 3 megnyitáskor jelenik meg.';

  @override
  String get noDiaperRecordsYet => 'Még nincs pelenka bejegyzés';

  @override
  String get addDiaperChangesHint =>
      'Adj hozzá pelenkacserét a főoldalról az előzmények követéséhez.';

  @override
  String get pee => 'Pisi';

  @override
  String get poop => 'Kaki';

  @override
  String get peeAndPoop => 'Pisi & Kaki';

  @override
  String get amount => 'Mennyiség';

  @override
  String get color => 'Szín';

  @override
  String get note => 'Megjegyzés';

  @override
  String get diaperScreenTitle => 'Pelenka bejegyzés hozzáadása';

  @override
  String get diaperType => 'Pelenka típusa';

  @override
  String get peeAmountTitle => 'Pisi mennyisége';

  @override
  String get poopAmountTitle => 'Kaki mennyisége';

  @override
  String get poopColor => 'Kaki színe';

  @override
  String get optionalNote => 'Opcionális megjegyzés';

  @override
  String get saveDiaperRecord => 'Pelenka bejegyzés mentése';

  @override
  String get diaperRecordSaved => 'Pelenka bejegyzés mentve';

  @override
  String get small => 'Kicsi';

  @override
  String get medium => 'Közepes';

  @override
  String get large => 'Nagy';

  @override
  String get yellow => 'Sárga';

  @override
  String get brown => 'Barna';

  @override
  String get green => 'Zöld';

  @override
  String get black => 'Fekete';

  @override
  String get mustardYellow => 'Mustársárga';

  @override
  String get yellowGreen => 'Sárga-zöld';

  @override
  String get darkGreen => 'Sötétzöld';

  @override
  String get whiteGray => 'Szürke-fehér';

  @override
  String get noFeedingSessionsYet => 'Még nincs etetési bejegyzés';

  @override
  String get startFeedingSessionHint =>
      'Indíts etetési folyamatot, hogy tiszta idővonalon követhesd a baba etetési előzményeit.';

  @override
  String get totalFeedingDuration => 'Összes etetési idő';

  @override
  String get milk => 'Tej';

  @override
  String get average => 'Átlag';

  @override
  String get sessions => 'Etetések';

  @override
  String get totalFeedingTime => 'Összes etetési idő';

  @override
  String get comingSoon => 'Hamarosan';

  @override
  String get sleepTitle => 'Alvás';

  @override
  String get babyInfoTitle => 'Baba adatai';

  @override
  String get babyNameLabel => 'Baba neve';

  @override
  String get genderLabel => 'Nem';

  @override
  String get genderMale => 'Fiú';

  @override
  String get genderFemale => 'Lány';

  @override
  String get birthDateNotSelected => 'Születési dátum nincs kiválasztva';

  @override
  String get selectDate => 'Dátum kiválasztása';

  @override
  String get saveContinue => 'Mentés és folytatás';

  @override
  String get requiredField => 'Ez a mező kötelező';

  @override
  String get weightGr => 'Súly (g)';

  @override
  String get heightCm => 'Magasság (cm)';

  @override
  String get headCircumferenceOptional => 'Fejkörfogat (opcionális)';

  @override
  String get waistCircumferenceOptional => 'Derékkörfogat (opcionális)';

  @override
  String get feedingSessionTitle => 'Etetési folyamat';

  @override
  String get babyWeightGr => 'Baba súlya (g)';

  @override
  String get exampleWeight => 'pl. 2500';

  @override
  String get liveSession => 'Élő folyamat';

  @override
  String get backLiveSession =>
      'A háttérben rögzítették a folyamatos szoptatást.';

  @override
  String get ready => 'Kész';

  @override
  String get tapLeftOrRightToStart =>
      'Kezdéshez érintsd meg a bal vagy jobb oldalt';

  @override
  String get leftSide => 'Bal oldal';

  @override
  String get rightSide => 'Jobb oldal';

  @override
  String get live => 'ÉLŐ';

  @override
  String get stop => 'Leállítás';

  @override
  String get feedingSummary => 'Etetési összegzés';

  @override
  String get leftLabel => 'Bal';

  @override
  String get rightLabel => 'Jobb';

  @override
  String get totalLabel => 'Összesen';

  @override
  String get feedingAfterWeight => 'Etetés utáni súly';

  @override
  String get save => 'Mentés';

  @override
  String get currentLabel => 'Jelenlegi';

  @override
  String get enterNewValueHint => 'Adj meg új értéket';

  @override
  String get currentGrowthSnapshot => 'Aktuális növekedési állapot';

  @override
  String get saveGrowthRecord => 'Növekedési adat mentése';

  @override
  String get growthUpdateTitle => 'Growth Update';

  @override
  String get historyHubTitle => 'Előzmények központ';

  @override
  String get historyHubSubtitle => 'Kövesd a babával kapcsolatos összes adatot';

  @override
  String get milkTracking => 'Tej követése';

  @override
  String get weightAndHeight => 'Súly és magasság';

  @override
  String get diaperChanges => 'Pelenkacserék';

  @override
  String get sessionDeleted => 'Etetés törölve';

  @override
  String get undo => 'VISSZAVONÁS';

  @override
  String get yesterday => 'Tegnap';

  @override
  String get thisWeek => 'Ezen a héten';

  @override
  String get swipeHistoryTip =>
      'Tipp: Húzd balra az etetési bejegyzést a törléshez.';

  @override
  String get noGrowthDataYet => 'Még nincs növekedési adat';

  @override
  String get leftBreast => 'Bal mell';

  @override
  String get rightBreast => 'Jobb mell';

  @override
  String get initialWeight => 'Kezdő súly';

  @override
  String get finalWeight => 'Végső súly';

  @override
  String get milkIntake => 'Elfogyasztott tej';

  @override
  String get weight => 'Súly';

  @override
  String get height => 'Magasság';

  @override
  String get headCircumference => 'Fejkörfogat';

  @override
  String get waistCircumference => 'Derékkörfogat';

  @override
  String get unitGr => 'g';

  @override
  String get unitCm => 'cm';

  @override
  String get weightHeightRequired => 'Súly és magasság kötelező';

  @override
  String get growthRecordSaved => 'Növekedési adat mentve';

  @override
  String get growthHistoryTitle => 'Növekedési előzmények';

  @override
  String get yearsShort => 'év';

  @override
  String get monthsShort => 'hó';

  @override
  String get daysShort => 'nap';

  @override
  String get dateAndTime => 'Datum és idő';

  @override
  String get feedingGraph => 'Etetési grafikon';

  @override
  String get growthGraph => 'Növekedési grafikon';

  @override
  String get diaperGraph => 'Pelenka grafikon';

  @override
  String get viewCharts => 'Grafikonok megtekintése';

  @override
  String get growthCharts => 'Növekedési grafikonok';

  @override
  String get manualFeedingEntry => 'Manuális etetési bejegyzés';

  @override
  String get startTime => 'Kezdési idő';

  @override
  String get endTime => 'Befejezési idő';

  @override
  String get select => 'Kiválasztás';

  @override
  String get leftRightRatio => 'Bal/Jobb arány';

  @override
  String get noData => 'Nincs adat';

  @override
  String get noGrowthData => 'Nincs növekedési adat';

  @override
  String get filter7d => '7n';

  @override
  String get filter30d => '30n';

  @override
  String get filter90d => '90n';

  @override
  String get filterAll => 'Összes';

  @override
  String dateFormat(int day, int month) {
    return '$day.$month';
  }

  @override
  String get quickActions => 'Akciók';

  @override
  String get todayActivities => 'Mai Tevékenységek';

  @override
  String get last => 'Utolsó';

  @override
  String minutesAgo(int count) {
    return '$count perce';
  }

  @override
  String hoursAgo(int count) {
    return '$count órája';
  }

  @override
  String daysAgo(int count) {
    return '$count napja';
  }

  @override
  String get liveFeedingContinues => 'Az élő etetés folyamatban van';

  @override
  String get unsavedFeedingDraft => 'Egy nem mentett etetési vázlat vár';

  @override
  String feedingSideProgress(String side, String duration) {
    return '$side oldal - $duration';
  }

  @override
  String get open => 'Megnyitás';
}
