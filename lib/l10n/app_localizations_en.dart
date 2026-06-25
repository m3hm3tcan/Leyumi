// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeToLeyumi => 'Welcome to Leyumi';

  @override
  String get onboardingWelcomeDescription =>
      'A calm, private place to follow your baby\'s everyday care and growth.';

  @override
  String get onboardingTrackTitle => 'Everything in one place';

  @override
  String get onboardingTrackDescription =>
      'Record feeding, diaper changes, growth and expressed milk without losing the little details.';

  @override
  String get onboardingFreePremiumTitle =>
      'Start free, unlock more when you need it';

  @override
  String get freePlan => 'Free';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get freePlanFeatures =>
      'Feeding, diaper and growth records\nComplete history\nDark mode and 3 languages';

  @override
  String get premiumPlanFeatures =>
      'Advanced charts\nMilk inventory\nPDF doctor reports\nMultiple child profiles';

  @override
  String get onboardingPrivacyTitle => 'Your family data stays yours';

  @override
  String get onboardingPrivacyDescription =>
      'Your records are stored locally on this device. You decide when to create or share a report.';

  @override
  String get createFirstChildProfile => 'Create your child\'s profile';

  @override
  String get onboardingChildDescription =>
      'These details personalize records and reports. You can update them later.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get childProfiles => 'Child Profiles';

  @override
  String get addChildProfile => 'Add Child';

  @override
  String get editChildProfile => 'Edit Child';

  @override
  String get switchChild => 'Switch child';

  @override
  String get activeChild => 'Active child';

  @override
  String get multipleChildrenPremiumHint =>
      'Additional child profiles are included with Premium.';

  @override
  String get deleteChildProfileTitle => 'Delete child profile?';

  @override
  String get deleteChildProfileContent =>
      'This child profile and all feeding, diaper, growth and milk records linked to it will be permanently deleted.';

  @override
  String get nameLengthError =>
      'Name must contain between 2 and 30 characters.';

  @override
  String get weightRangeError => 'Weight must be between 500 and 30,000 g.';

  @override
  String get heightRangeError => 'Height must be between 20 and 100 cm.';

  @override
  String get headCircumferenceRangeError =>
      'Head circumference must be between 20 and 70 cm.';

  @override
  String get waistCircumferenceRangeError =>
      'Waist circumference must be between 20 and 100 cm.';

  @override
  String get milkLabelLengthError =>
      'The label can contain up to 30 characters.';

  @override
  String get milkAmountRangeError =>
      'Milk amount must be between 1 and 500 ml.';

  @override
  String get futureDateTimeError => 'Date and time cannot be in the future.';

  @override
  String get selectFeedingTimesError => 'Select both the start and end time.';

  @override
  String get feedingTimeOrderError => 'End time must be later than start time.';

  @override
  String get feedingDurationRangeError =>
      'A manual feeding session cannot exceed 12 hours.';

  @override
  String get feedingBeforeBirthError =>
      'Feeding date cannot be before the child\'s birth date.';

  @override
  String get feedingDate => 'Feeding date';

  @override
  String get milkInventory => 'Milk Inventory';

  @override
  String get addMilk => 'Add Milk';

  @override
  String get saveMilk => 'Save Milk';

  @override
  String get totalMilkStock => 'Total milk stock';

  @override
  String get refrigerator => 'Refrigerator';

  @override
  String get freezer => 'Freezer';

  @override
  String get bottles => 'Bottles';

  @override
  String get all => 'All';

  @override
  String get noStoredMilk => 'No stored milk yet';

  @override
  String get noStoredMilkHint =>
      'Add your first expressed milk bottle and Leyumi will track its freshness.';

  @override
  String get labelNumber => 'Label number';

  @override
  String get amountMl => 'Amount (ml)';

  @override
  String get storageLocation => 'Storage location';

  @override
  String get expressedAt => 'Expressed date and time';

  @override
  String get pumpedFrom => 'Pumped from';

  @override
  String get mixed => 'Mixed';

  @override
  String get unspecified => 'Not specified';

  @override
  String get freshFor => 'Fresh for';

  @override
  String get useWithin => 'Use within';

  @override
  String get expired => 'Expired';

  @override
  String get bestBefore => 'Best before';

  @override
  String get hoursShort => 'h';

  @override
  String get useMilk => 'Use milk';

  @override
  String get confirm => 'Confirm';

  @override
  String get moveToFreezer => 'Move to freezer';

  @override
  String get moveToRefrigerator => 'Move to refrigerator';

  @override
  String get deleteMilkTitle => 'Delete milk bottle?';

  @override
  String get deleteMilkContent =>
      'Are you sure you want to remove this milk bottle from inventory?';

  @override
  String get milkStorageSafetyNote =>
      'Fresh milk: up to 4 days refrigerated; best used within 6 months frozen. Smaller portions can help reduce waste.';

  @override
  String get invalidMilkEntry =>
      'Enter a label and a milk amount between 1 and 500 ml.';

  @override
  String get duplicateMilkLabel => 'This label number is already in use.';

  @override
  String get discardMilk => 'Discard milk';

  @override
  String get editMilkRecord => 'Edit record';

  @override
  String get deleteIncorrectRecord => 'Delete incorrect record';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get milkHistory => 'Milk History';

  @override
  String get usedAndRemainingMilk => 'Used and remaining milk';

  @override
  String get remainingMilk => 'Remaining';

  @override
  String get usedMilk => 'Used milk';

  @override
  String get discardedMilk => 'Discarded';

  @override
  String get activity => 'Activity';

  @override
  String get insights => 'Insights';

  @override
  String get noMilkHistory => 'No milk activity yet';

  @override
  String get dailyMilkMovement => 'Added and used milk';

  @override
  String get last14Days => 'Last 14 days';

  @override
  String get stockOverTime => 'Milk stock over time';

  @override
  String get addedMilk => 'Added milk';

  @override
  String get milkAdded => 'Milk added';

  @override
  String get remaining => 'Remaining';

  @override
  String get movedToFreezer => 'Moved to freezer';

  @override
  String get recordCorrected => 'Record corrected';

  @override
  String get premiumTitle => 'Leyumi Premium';

  @override
  String get unlockPremium => 'Unlock more with Premium';

  @override
  String get premiumDescription =>
      'Turn your baby care records into clear insights and keep everything safely connected.';

  @override
  String get premiumIncludes => 'Premium features';

  @override
  String get premiumAnalytics =>
      'Advanced feeding, diaper and growth analytics';

  @override
  String get premiumPdfReports => 'PDF doctor reports';

  @override
  String get doctorReport => 'Doctor Report';

  @override
  String get doctorReportDescription =>
      'Create a clear summary of feeding, diaper and growth records for your doctor.';

  @override
  String get createShareableReport => 'Create and share a health summary';

  @override
  String get selectReportPeriod => 'Select report period';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last90Days => 'Last 90 days';

  @override
  String get reportPeriod => 'Report period';

  @override
  String get reportSummary => 'Summary';

  @override
  String get minutesShort => 'min';

  @override
  String get secondsShort => 'sec';

  @override
  String get diaperSummary => 'Diaper summary';

  @override
  String get growthSummary => 'Growth summary';

  @override
  String get dailyActivitySummary => 'Daily activity summary';

  @override
  String get growthMeasurements => 'Growth measurements';

  @override
  String generatedOn(String date) {
    return 'Generated on $date';
  }

  @override
  String get generatedByLeyumi => 'Generated by Leyumi';

  @override
  String get noBabyProfile => 'Baby profile information is not available.';

  @override
  String get birthDate => 'Birth date';

  @override
  String get latestMeasurement => 'Latest measurement';

  @override
  String get weightChange => 'Weight change';

  @override
  String get heightChange => 'Height change';

  @override
  String get noDataForPeriod => 'No records were found for this period.';

  @override
  String get duration => 'Duration';

  @override
  String get reportMedicalDisclaimer =>
      'This report summarizes records entered by the caregiver. It is not medical advice or a diagnosis. Please review the information with a qualified healthcare professional.';

  @override
  String get createAndSharePdf => 'Create and Share PDF';

  @override
  String get preparingReport => 'Preparing report...';

  @override
  String get reportGenerationFailed =>
      'The PDF report could not be created. Please try again.';

  @override
  String get reportPrivacyNote =>
      'The report is created on this device. You choose where and with whom it is shared.';

  @override
  String get reportIncludes => 'The report includes';

  @override
  String get babyInformation => 'Baby information';

  @override
  String get premiumMultipleChildren => 'Multiple child profiles';

  @override
  String get premiumCloudBackup => 'Cloud backup and device sync';

  @override
  String get premiumSmartReminders => 'Smart reminders';

  @override
  String get premiumMilkInventory => 'Milk inventory management';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumPurchaseComingSoon =>
      'Premium purchasing will be available soon.';

  @override
  String get confirmDeleteTitle => 'Delete record?';

  @override
  String get confirmDeleteContent =>
      'Are you sure you want to delete this record? This action can be undone for a short time.';

  @override
  String get confirmSaveTitle => 'Save feeding record?';

  @override
  String get confirmSaveContent =>
      'Are you sure you want to save this feeding record?';

  @override
  String get dontSave => 'Don\'t save';

  @override
  String get appTitle => 'Leyumi';

  @override
  String get appSubtitle => 'Growing with your little light. 🌙✨';

  @override
  String get homeTitle => 'Home';

  @override
  String get feeding => 'Feeding';

  @override
  String get history => 'History';

  @override
  String get diaper => 'Diaper';

  @override
  String get growth => 'Growth';

  @override
  String get startSession => 'Start feeding session';

  @override
  String get pastFeedings => 'Past feedings';

  @override
  String get trackChanges => 'Track changes';

  @override
  String get updateWeight => 'Update weight';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get resetApp => 'Reset App (Clear All Data)';

  @override
  String get confirmResetTitle => 'Reset App';

  @override
  String get confirmResetContent =>
      'Are you sure you want to clear all app data?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get today => 'Today';

  @override
  String get older => 'Older';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get swipeToDelete => 'Swipe left to delete';

  @override
  String get swipeHintInfo => 'This hint shows during the first 3 opens.';

  @override
  String get noDiaperRecordsYet => 'No diaper records yet';

  @override
  String get addDiaperChangesHint =>
      'Add diaper changes from the home screen to track history.';

  @override
  String get pee => 'Pee';

  @override
  String get poop => 'Poop';

  @override
  String get peeAndPoop => 'Pee & Poop';

  @override
  String get amount => 'Amount';

  @override
  String get color => 'Color';

  @override
  String get note => 'Note';

  @override
  String get diaperScreenTitle => 'Add Diaper Entry';

  @override
  String get diaperType => 'Diaper Type';

  @override
  String get peeAmountTitle => 'Pee Amount';

  @override
  String get poopAmountTitle => 'Poop Amount';

  @override
  String get poopColor => 'Poop Color';

  @override
  String get optionalNote => 'Optional note';

  @override
  String get saveDiaperRecord => 'Save Diaper Record';

  @override
  String get diaperRecordSaved => 'Diaper record saved';

  @override
  String get small => 'Small';

  @override
  String get medium => 'Medium';

  @override
  String get large => 'Large';

  @override
  String get yellow => 'Yellow';

  @override
  String get brown => 'Brown';

  @override
  String get green => 'Green';

  @override
  String get black => 'Black';

  @override
  String get mustardYellow => 'Mustard Yellow';

  @override
  String get yellowGreen => 'Yellow Green';

  @override
  String get darkGreen => 'Dark Green';

  @override
  String get whiteGray => 'Gray White';

  @override
  String get noFeedingSessionsYet => 'No feeding sessions yet';

  @override
  String get startFeedingSessionHint =>
      'Start a feeding session to track your baby\'s feeding history in a clean timeline.';

  @override
  String get totalFeedingDuration => 'Total feeding duration';

  @override
  String get milk => 'Milk';

  @override
  String get average => 'Average';

  @override
  String get sessions => 'Sessions';

  @override
  String get totalFeedingTime => 'Total feeding time';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get sleepTitle => 'Sleep';

  @override
  String get babyInfoTitle => 'Baby Information';

  @override
  String get babyNameLabel => 'Baby Name';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get birthDateNotSelected => 'Birth date not selected';

  @override
  String get selectDate => 'Select date';

  @override
  String get saveContinue => 'Save and Continue';

  @override
  String get requiredField => 'This field is required';

  @override
  String get weightGr => 'Weight (g)';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get headCircumferenceOptional => 'Head Circumference (optional)';

  @override
  String get waistCircumferenceOptional => 'Waist Circumference (optional)';

  @override
  String get feedingSessionTitle => 'Feeding Session';

  @override
  String get babyWeightGr => 'Baby Weight (g)';

  @override
  String get exampleWeight => 'e.g. 2500';

  @override
  String get liveSession => 'Live Session';

  @override
  String get backLiveSession =>
      'Ongoing breastfeeding was recorded in the background.';

  @override
  String get ready => 'Ready';

  @override
  String get tapLeftOrRightToStart => 'Tap left or right to start';

  @override
  String get leftSide => 'Left Side';

  @override
  String get rightSide => 'Right Side';

  @override
  String get live => 'Live';

  @override
  String get stop => 'Stop';

  @override
  String get feedingSummary => 'Feeding Summary';

  @override
  String get leftLabel => 'Left';

  @override
  String get rightLabel => 'Right';

  @override
  String get totalLabel => 'Total';

  @override
  String get feedingAfterWeight => 'Feeding After Weight';

  @override
  String get save => 'Save';

  @override
  String get currentLabel => 'Current';

  @override
  String get enterNewValueHint => 'Enter new value';

  @override
  String get currentGrowthSnapshot => 'Current Growth Snapshot';

  @override
  String get saveGrowthRecord => 'Save Growth Record';

  @override
  String get growthUpdateTitle => 'Growth Update';

  @override
  String get historyHubTitle => 'History Hub';

  @override
  String get historyHubSubtitle => 'Track everything about your baby';

  @override
  String get milkTracking => 'Milk tracking';

  @override
  String get weightAndHeight => 'Weight & height';

  @override
  String get diaperChanges => 'Diaper changes';

  @override
  String get sessionDeleted => 'Session deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get swipeHistoryTip =>
      'Tip: Swipe left on a feeding session to delete it.';

  @override
  String get noGrowthDataYet => 'No growth data yet';

  @override
  String get leftBreast => 'Left breast';

  @override
  String get rightBreast => 'Right breast';

  @override
  String get initialWeight => 'Initial weight';

  @override
  String get finalWeight => 'Final weight';

  @override
  String get milkIntake => 'Milk intake';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get headCircumference => 'Head Circumference';

  @override
  String get waistCircumference => 'Waist Circumference';

  @override
  String get unitGr => 'g';

  @override
  String get unitCm => 'cm';

  @override
  String get weightHeightRequired => 'Weight and Height are required';

  @override
  String get growthRecordSaved => 'Growth record saved';

  @override
  String get growthHistoryTitle => 'Growth History';

  @override
  String get yearsShort => 'y';

  @override
  String get monthsShort => 'm';

  @override
  String get daysShort => 'd';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get feedingGraph => 'Feeding Graph';

  @override
  String get growthGraph => 'Growth Graph';

  @override
  String get diaperGraph => 'Diaper Graph';

  @override
  String get viewCharts => 'View charts';

  @override
  String get growthCharts => 'Growth Charts';

  @override
  String get manualFeedingEntry => 'Manual Feeding Entry';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get select => 'Select';

  @override
  String get leftRightRatio => 'Left/Right Ratio';

  @override
  String get noData => 'No data';

  @override
  String get noGrowthData => 'No growth data';

  @override
  String get filter7d => '7d';

  @override
  String get filter30d => '30d';

  @override
  String get filter90d => '90d';

  @override
  String get filterAll => 'All';

  @override
  String dateFormat(int day, int month) {
    return '$day.$month';
  }

  @override
  String get quickActions => 'Actions';

  @override
  String get todayActivities => 'Today\'s Activity';

  @override
  String get last => 'Last';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get liveFeedingContinues => 'Live feeding is in progress';

  @override
  String get unsavedFeedingDraft => 'An unsaved feeding draft is ready';

  @override
  String feedingSideProgress(String side, String duration) {
    return '$side side - $duration';
  }

  @override
  String get open => 'Open';
}
