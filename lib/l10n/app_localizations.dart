import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu'),
    Locale('tr'),
  ];

  /// No description provided for @welcomeToLeyumi.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Leyumi'**
  String get welcomeToLeyumi;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'A calm, private place to follow your baby\'s everyday care and growth.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything in one place'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTrackDescription.
  ///
  /// In en, this message translates to:
  /// **'Record feeding, diaper changes, growth and expressed milk without losing the little details.'**
  String get onboardingTrackDescription;

  /// No description provided for @onboardingFreePremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Start free, unlock more when you need it'**
  String get onboardingFreePremiumTitle;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlan;

  /// No description provided for @freePlanFeatures.
  ///
  /// In en, this message translates to:
  /// **'Feeding, diaper and growth records\nCare calendar and upcoming events\nComplete history, dark mode and 3 languages'**
  String get freePlanFeatures;

  /// No description provided for @premiumPlanFeatures.
  ///
  /// In en, this message translates to:
  /// **'Advanced charts and care plans\nMilk inventory\nPDF doctor reports\nMultiple child profiles'**
  String get premiumPlanFeatures;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your family data stays yours'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your records are stored locally on this device. You decide when to create or share a report.'**
  String get onboardingPrivacyDescription;

  /// No description provided for @createFirstChildProfile.
  ///
  /// In en, this message translates to:
  /// **'Create your child\'s profile'**
  String get createFirstChildProfile;

  /// No description provided for @onboardingChildDescription.
  ///
  /// In en, this message translates to:
  /// **'These details personalize records and reports. You can update them later.'**
  String get onboardingChildDescription;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @childProfiles.
  ///
  /// In en, this message translates to:
  /// **'Child Profiles'**
  String get childProfiles;

  /// No description provided for @addChildProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChildProfile;

  /// No description provided for @editChildProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Child'**
  String get editChildProfile;

  /// No description provided for @switchChild.
  ///
  /// In en, this message translates to:
  /// **'Switch child'**
  String get switchChild;

  /// No description provided for @activeChild.
  ///
  /// In en, this message translates to:
  /// **'Active child'**
  String get activeChild;

  /// No description provided for @multipleChildrenPremiumHint.
  ///
  /// In en, this message translates to:
  /// **'Additional child profiles are included with Premium.'**
  String get multipleChildrenPremiumHint;

  /// No description provided for @deleteChildProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete child profile?'**
  String get deleteChildProfileTitle;

  /// No description provided for @deleteChildProfileContent.
  ///
  /// In en, this message translates to:
  /// **'This child profile and all feeding, diaper, growth, milk and care calendar records linked to it will be permanently deleted.'**
  String get deleteChildProfileContent;

  /// No description provided for @nameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must contain between 2 and 30 characters.'**
  String get nameLengthError;

  /// No description provided for @weightRangeError.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 500 and 30,000 g.'**
  String get weightRangeError;

  /// No description provided for @heightRangeError.
  ///
  /// In en, this message translates to:
  /// **'Height must be between 20 and 100 cm.'**
  String get heightRangeError;

  /// No description provided for @headCircumferenceRangeError.
  ///
  /// In en, this message translates to:
  /// **'Head circumference must be between 20 and 70 cm.'**
  String get headCircumferenceRangeError;

  /// No description provided for @waistCircumferenceRangeError.
  ///
  /// In en, this message translates to:
  /// **'Waist circumference must be between 20 and 100 cm.'**
  String get waistCircumferenceRangeError;

  /// No description provided for @milkLabelLengthError.
  ///
  /// In en, this message translates to:
  /// **'The label can contain up to 30 characters.'**
  String get milkLabelLengthError;

  /// No description provided for @milkAmountRangeError.
  ///
  /// In en, this message translates to:
  /// **'Milk amount must be between 1 and 500 ml.'**
  String get milkAmountRangeError;

  /// No description provided for @futureDateTimeError.
  ///
  /// In en, this message translates to:
  /// **'Date and time cannot be in the future.'**
  String get futureDateTimeError;

  /// No description provided for @selectFeedingTimesError.
  ///
  /// In en, this message translates to:
  /// **'Select both the start and end time.'**
  String get selectFeedingTimesError;

  /// No description provided for @feedingTimeOrderError.
  ///
  /// In en, this message translates to:
  /// **'End time must be later than start time.'**
  String get feedingTimeOrderError;

  /// No description provided for @feedingDurationRangeError.
  ///
  /// In en, this message translates to:
  /// **'A manual feeding session cannot exceed 12 hours.'**
  String get feedingDurationRangeError;

  /// No description provided for @feedingBeforeBirthError.
  ///
  /// In en, this message translates to:
  /// **'Feeding date cannot be before the child\'s birth date.'**
  String get feedingBeforeBirthError;

  /// No description provided for @feedingDate.
  ///
  /// In en, this message translates to:
  /// **'Feeding date'**
  String get feedingDate;

  /// No description provided for @careCalendar.
  ///
  /// In en, this message translates to:
  /// **'Care Calendar'**
  String get careCalendar;

  /// No description provided for @careCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vaccines, appointments and medicine'**
  String get careCalendarSubtitle;

  /// No description provided for @addCareEvent.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get addCareEvent;

  /// No description provided for @editCareEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get editCareEvent;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event type'**
  String get eventType;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitle;

  /// No description provided for @careTitleError.
  ///
  /// In en, this message translates to:
  /// **'Title must contain at least 2 characters.'**
  String get careTitleError;

  /// No description provided for @careBeforeBirthError.
  ///
  /// In en, this message translates to:
  /// **'Event date cannot be before the child\'s birth date.'**
  String get careBeforeBirthError;

  /// No description provided for @carePastDateTimeError.
  ///
  /// In en, this message translates to:
  /// **'Event date and time must be in the future.'**
  String get carePastDateTimeError;

  /// No description provided for @careTypeVaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get careTypeVaccine;

  /// No description provided for @careTypeDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get careTypeDoctor;

  /// No description provided for @careTypeMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get careTypeMedicine;

  /// No description provided for @careTypeCheckup.
  ///
  /// In en, this message translates to:
  /// **'Checkup'**
  String get careTypeCheckup;

  /// No description provided for @careTypeLaboratory.
  ///
  /// In en, this message translates to:
  /// **'Lab/Test'**
  String get careTypeLaboratory;

  /// No description provided for @careTypeTherapy.
  ///
  /// In en, this message translates to:
  /// **'Therapy'**
  String get careTypeTherapy;

  /// No description provided for @careTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get careTypeCustom;

  /// No description provided for @doctorOrLocation.
  ///
  /// In en, this message translates to:
  /// **'Doctor or location'**
  String get doctorOrLocation;

  /// No description provided for @medicineDosage.
  ///
  /// In en, this message translates to:
  /// **'Medicine dose'**
  String get medicineDosage;

  /// No description provided for @repeatPlan.
  ///
  /// In en, this message translates to:
  /// **'Repeat plan'**
  String get repeatPlan;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @reminderNone.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get reminderNone;

  /// No description provided for @reminderOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminderOneHour;

  /// No description provided for @reminderOneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminderOneDay;

  /// No description provided for @reminderTwoDays.
  ///
  /// In en, this message translates to:
  /// **'2 days before'**
  String get reminderTwoDays;

  /// No description provided for @reminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder scheduled.'**
  String get reminderScheduled;

  /// No description provided for @reminderTimeAlreadyPassed.
  ///
  /// In en, this message translates to:
  /// **'This reminder time has already passed. Choose a later event time or a shorter reminder.'**
  String get reminderTimeAlreadyPassed;

  /// No description provided for @reminderCouldNotBeScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder could not be scheduled. Please check notification permission.'**
  String get reminderCouldNotBeScheduled;

  /// No description provided for @exactAlarmPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow timely reminders?'**
  String get exactAlarmPermissionTitle;

  /// No description provided for @exactAlarmPermissionContent.
  ///
  /// In en, this message translates to:
  /// **'To deliver reminders on time, Leyumi may need the phone\'s alarm permission.'**
  String get exactAlarmPermissionContent;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @advancedCarePremiumHint.
  ///
  /// In en, this message translates to:
  /// **'Repeating plans and medicine doses are included with Premium.'**
  String get advancedCarePremiumHint;

  /// No description provided for @premiumCarePlanning.
  ///
  /// In en, this message translates to:
  /// **'Advanced care plans and medicine schedules'**
  String get premiumCarePlanning;

  /// No description provided for @noCareEventsForDay.
  ///
  /// In en, this message translates to:
  /// **'No events planned for this day.'**
  String get noCareEventsForDay;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark completed'**
  String get markCompleted;

  /// No description provided for @markCancelled.
  ///
  /// In en, this message translates to:
  /// **'Mark cancelled'**
  String get markCancelled;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @upcomingCare.
  ///
  /// In en, this message translates to:
  /// **'Upcoming care'**
  String get upcomingCare;

  /// No description provided for @viewCalendar.
  ///
  /// In en, this message translates to:
  /// **'View calendar'**
  String get viewCalendar;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'In {count} days'**
  String inDays(int count);

  /// No description provided for @milkInventory.
  ///
  /// In en, this message translates to:
  /// **'Milk Inventory'**
  String get milkInventory;

  /// No description provided for @addMilk.
  ///
  /// In en, this message translates to:
  /// **'Add Milk'**
  String get addMilk;

  /// No description provided for @saveMilk.
  ///
  /// In en, this message translates to:
  /// **'Save Milk'**
  String get saveMilk;

  /// No description provided for @totalMilkStock.
  ///
  /// In en, this message translates to:
  /// **'Total milk stock'**
  String get totalMilkStock;

  /// No description provided for @refrigerator.
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get refrigerator;

  /// No description provided for @freezer.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get freezer;

  /// No description provided for @bottles.
  ///
  /// In en, this message translates to:
  /// **'Bottles'**
  String get bottles;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noStoredMilk.
  ///
  /// In en, this message translates to:
  /// **'No stored milk yet'**
  String get noStoredMilk;

  /// No description provided for @noStoredMilkHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first expressed milk bottle and Leyumi will track its freshness.'**
  String get noStoredMilkHint;

  /// No description provided for @labelNumber.
  ///
  /// In en, this message translates to:
  /// **'Label number'**
  String get labelNumber;

  /// No description provided for @amountMl.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml)'**
  String get amountMl;

  /// No description provided for @storageLocation.
  ///
  /// In en, this message translates to:
  /// **'Storage location'**
  String get storageLocation;

  /// No description provided for @expressedAt.
  ///
  /// In en, this message translates to:
  /// **'Expressed date and time'**
  String get expressedAt;

  /// No description provided for @pumpedFrom.
  ///
  /// In en, this message translates to:
  /// **'Pumped from'**
  String get pumpedFrom;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @unspecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get unspecified;

  /// No description provided for @freshFor.
  ///
  /// In en, this message translates to:
  /// **'Fresh for'**
  String get freshFor;

  /// No description provided for @useWithin.
  ///
  /// In en, this message translates to:
  /// **'Use within'**
  String get useWithin;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @bestBefore.
  ///
  /// In en, this message translates to:
  /// **'Best before'**
  String get bestBefore;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @useMilk.
  ///
  /// In en, this message translates to:
  /// **'Use milk'**
  String get useMilk;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @moveToFreezer.
  ///
  /// In en, this message translates to:
  /// **'Move to freezer'**
  String get moveToFreezer;

  /// No description provided for @moveToRefrigerator.
  ///
  /// In en, this message translates to:
  /// **'Move to refrigerator'**
  String get moveToRefrigerator;

  /// No description provided for @deleteMilkTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete milk bottle?'**
  String get deleteMilkTitle;

  /// No description provided for @deleteMilkContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this milk bottle from inventory?'**
  String get deleteMilkContent;

  /// No description provided for @milkStorageSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Fresh milk: up to 4 days refrigerated; best used within 6 months frozen. Smaller portions can help reduce waste.'**
  String get milkStorageSafetyNote;

  /// No description provided for @invalidMilkEntry.
  ///
  /// In en, this message translates to:
  /// **'Enter a label and a milk amount between 1 and 500 ml.'**
  String get invalidMilkEntry;

  /// No description provided for @duplicateMilkLabel.
  ///
  /// In en, this message translates to:
  /// **'This label number is already in use.'**
  String get duplicateMilkLabel;

  /// No description provided for @discardMilk.
  ///
  /// In en, this message translates to:
  /// **'Discard milk'**
  String get discardMilk;

  /// No description provided for @editMilkRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editMilkRecord;

  /// No description provided for @deleteIncorrectRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete incorrect record'**
  String get deleteIncorrectRecord;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @milkHistory.
  ///
  /// In en, this message translates to:
  /// **'Milk History'**
  String get milkHistory;

  /// No description provided for @usedAndRemainingMilk.
  ///
  /// In en, this message translates to:
  /// **'Used and remaining milk'**
  String get usedAndRemainingMilk;

  /// No description provided for @remainingMilk.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingMilk;

  /// No description provided for @usedMilk.
  ///
  /// In en, this message translates to:
  /// **'Used milk'**
  String get usedMilk;

  /// No description provided for @discardedMilk.
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get discardedMilk;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @noMilkHistory.
  ///
  /// In en, this message translates to:
  /// **'No milk activity yet'**
  String get noMilkHistory;

  /// No description provided for @dailyMilkMovement.
  ///
  /// In en, this message translates to:
  /// **'Added and used milk'**
  String get dailyMilkMovement;

  /// No description provided for @last14Days.
  ///
  /// In en, this message translates to:
  /// **'Last 14 days'**
  String get last14Days;

  /// No description provided for @stockOverTime.
  ///
  /// In en, this message translates to:
  /// **'Milk stock over time'**
  String get stockOverTime;

  /// No description provided for @addedMilk.
  ///
  /// In en, this message translates to:
  /// **'Added milk'**
  String get addedMilk;

  /// No description provided for @milkAdded.
  ///
  /// In en, this message translates to:
  /// **'Milk added'**
  String get milkAdded;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @movedToFreezer.
  ///
  /// In en, this message translates to:
  /// **'Moved to freezer'**
  String get movedToFreezer;

  /// No description provided for @recordCorrected.
  ///
  /// In en, this message translates to:
  /// **'Record corrected'**
  String get recordCorrected;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Leyumi Premium'**
  String get premiumTitle;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock more with Premium'**
  String get unlockPremium;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn your baby care records into clear insights and keep everything safely connected.'**
  String get premiumDescription;

  /// No description provided for @premiumIncludes.
  ///
  /// In en, this message translates to:
  /// **'Premium features'**
  String get premiumIncludes;

  /// No description provided for @premiumAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced feeding, diaper and growth analytics'**
  String get premiumAnalytics;

  /// No description provided for @premiumPdfReports.
  ///
  /// In en, this message translates to:
  /// **'PDF doctor reports'**
  String get premiumPdfReports;

  /// No description provided for @doctorReport.
  ///
  /// In en, this message translates to:
  /// **'Doctor Report'**
  String get doctorReport;

  /// No description provided for @doctorReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a clear summary of feeding, diaper and growth records for your doctor.'**
  String get doctorReportDescription;

  /// No description provided for @createShareableReport.
  ///
  /// In en, this message translates to:
  /// **'Create and share a health summary'**
  String get createShareableReport;

  /// No description provided for @selectReportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select report period'**
  String get selectReportPeriod;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90Days;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report period'**
  String get reportPeriod;

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get reportSummary;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get secondsShort;

  /// No description provided for @diaperSummary.
  ///
  /// In en, this message translates to:
  /// **'Diaper summary'**
  String get diaperSummary;

  /// No description provided for @growthSummary.
  ///
  /// In en, this message translates to:
  /// **'Growth summary'**
  String get growthSummary;

  /// No description provided for @dailyActivitySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily activity summary'**
  String get dailyActivitySummary;

  /// No description provided for @growthMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Growth measurements'**
  String get growthMeasurements;

  /// No description provided for @generatedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String generatedOn(String date);

  /// No description provided for @generatedByLeyumi.
  ///
  /// In en, this message translates to:
  /// **'Generated by Leyumi'**
  String get generatedByLeyumi;

  /// No description provided for @noBabyProfile.
  ///
  /// In en, this message translates to:
  /// **'Baby profile information is not available.'**
  String get noBabyProfile;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get birthDate;

  /// No description provided for @latestMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Latest measurement'**
  String get latestMeasurement;

  /// No description provided for @weightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight change'**
  String get weightChange;

  /// No description provided for @heightChange.
  ///
  /// In en, this message translates to:
  /// **'Height change'**
  String get heightChange;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No records were found for this period.'**
  String get noDataForPeriod;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @reportMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This report summarizes records entered by the caregiver. It is not medical advice or a diagnosis. Please review the information with a qualified healthcare professional.'**
  String get reportMedicalDisclaimer;

  /// No description provided for @createAndSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Create and Share PDF'**
  String get createAndSharePdf;

  /// No description provided for @preparingReport.
  ///
  /// In en, this message translates to:
  /// **'Preparing report...'**
  String get preparingReport;

  /// No description provided for @reportGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'The PDF report could not be created. Please try again.'**
  String get reportGenerationFailed;

  /// No description provided for @reportPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'The report is created on this device. You choose where and with whom it is shared.'**
  String get reportPrivacyNote;

  /// No description provided for @reportIncludes.
  ///
  /// In en, this message translates to:
  /// **'The report includes'**
  String get reportIncludes;

  /// No description provided for @babyInformation.
  ///
  /// In en, this message translates to:
  /// **'Baby information'**
  String get babyInformation;

  /// No description provided for @premiumMultipleChildren.
  ///
  /// In en, this message translates to:
  /// **'Multiple child profiles'**
  String get premiumMultipleChildren;

  /// No description provided for @premiumCloudBackup.
  ///
  /// In en, this message translates to:
  /// **'Cloud backup and device sync'**
  String get premiumCloudBackup;

  /// No description provided for @premiumSmartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders'**
  String get premiumSmartReminders;

  /// No description provided for @premiumMilkInventory.
  ///
  /// In en, this message translates to:
  /// **'Milk inventory management'**
  String get premiumMilkInventory;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumPurchaseComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Premium purchasing will be available soon.'**
  String get premiumPurchaseComingSoon;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium is active'**
  String get premiumActive;

  /// No description provided for @premiumInactive.
  ///
  /// In en, this message translates to:
  /// **'Premium is not active'**
  String get premiumInactive;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @notificationsPremiumHint.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders are included with Premium.'**
  String get notificationsPremiumHint;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Tap to request permission again or enable them in system settings.'**
  String get notificationsDenied;

  /// No description provided for @notificationsNotChecked.
  ///
  /// In en, this message translates to:
  /// **'Notification permission has not been checked yet.'**
  String get notificationsNotChecked;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get sendTestNotification;

  /// No description provided for @sendTestNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Show a test reminder now to confirm notifications work.'**
  String get sendTestNotificationDescription;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Leyumi reminder'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are working. Tiny victory, big peace of mind.'**
  String get testNotificationBody;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent.'**
  String get testNotificationSent;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark appearance.'**
  String get darkModeDescription;

  /// No description provided for @resetAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Clear local records and return to onboarding.'**
  String get resetAppDescription;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete record?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record? This action can be undone for a short time.'**
  String get confirmDeleteContent;

  /// No description provided for @confirmSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save feeding record?'**
  String get confirmSaveTitle;

  /// No description provided for @confirmSaveContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save this feeding record?'**
  String get confirmSaveContent;

  /// No description provided for @dontSave.
  ///
  /// In en, this message translates to:
  /// **'Don\'t save'**
  String get dontSave;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Leyumi'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Growing with your little light. 🌙✨'**
  String get appSubtitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @feeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feeding;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start feeding session'**
  String get startSession;

  /// No description provided for @pastFeedings.
  ///
  /// In en, this message translates to:
  /// **'Past feedings'**
  String get pastFeedings;

  /// No description provided for @trackChanges.
  ///
  /// In en, this message translates to:
  /// **'Track changes'**
  String get trackChanges;

  /// No description provided for @updateWeight.
  ///
  /// In en, this message translates to:
  /// **'Update weight'**
  String get updateWeight;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @resetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset App (Clear All Data)'**
  String get resetApp;

  /// No description provided for @confirmResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get confirmResetTitle;

  /// No description provided for @confirmResetContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all app data?'**
  String get confirmResetContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @swipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete'**
  String get swipeToDelete;

  /// No description provided for @swipeHintInfo.
  ///
  /// In en, this message translates to:
  /// **'This hint shows during the first 3 opens.'**
  String get swipeHintInfo;

  /// No description provided for @noDiaperRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No diaper records yet'**
  String get noDiaperRecordsYet;

  /// No description provided for @addDiaperChangesHint.
  ///
  /// In en, this message translates to:
  /// **'Add diaper changes from the home screen to track history.'**
  String get addDiaperChangesHint;

  /// No description provided for @pee.
  ///
  /// In en, this message translates to:
  /// **'Pee'**
  String get pee;

  /// No description provided for @poop.
  ///
  /// In en, this message translates to:
  /// **'Poop'**
  String get poop;

  /// No description provided for @peeAndPoop.
  ///
  /// In en, this message translates to:
  /// **'Pee & Poop'**
  String get peeAndPoop;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @diaperScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Diaper Entry'**
  String get diaperScreenTitle;

  /// No description provided for @diaperType.
  ///
  /// In en, this message translates to:
  /// **'Diaper Type'**
  String get diaperType;

  /// No description provided for @peeAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Pee Amount'**
  String get peeAmountTitle;

  /// No description provided for @poopAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Poop Amount'**
  String get poopAmountTitle;

  /// No description provided for @poopColor.
  ///
  /// In en, this message translates to:
  /// **'Poop Color'**
  String get poopColor;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get optionalNote;

  /// No description provided for @saveDiaperRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Diaper Record'**
  String get saveDiaperRecord;

  /// No description provided for @diaperRecordSaved.
  ///
  /// In en, this message translates to:
  /// **'Diaper record saved'**
  String get diaperRecordSaved;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @mustardYellow.
  ///
  /// In en, this message translates to:
  /// **'Mustard Yellow'**
  String get mustardYellow;

  /// No description provided for @yellowGreen.
  ///
  /// In en, this message translates to:
  /// **'Yellow Green'**
  String get yellowGreen;

  /// No description provided for @darkGreen.
  ///
  /// In en, this message translates to:
  /// **'Dark Green'**
  String get darkGreen;

  /// No description provided for @whiteGray.
  ///
  /// In en, this message translates to:
  /// **'Gray White'**
  String get whiteGray;

  /// No description provided for @noFeedingSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No feeding sessions yet'**
  String get noFeedingSessionsYet;

  /// No description provided for @startFeedingSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Start a feeding session to track your baby\'s feeding history in a clean timeline.'**
  String get startFeedingSessionHint;

  /// No description provided for @totalFeedingDuration.
  ///
  /// In en, this message translates to:
  /// **'Total feeding duration'**
  String get totalFeedingDuration;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @totalFeedingTime.
  ///
  /// In en, this message translates to:
  /// **'Total feeding time'**
  String get totalFeedingTime;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @sleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepTitle;

  /// No description provided for @babyInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Information'**
  String get babyInfoTitle;

  /// No description provided for @babyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Baby Name'**
  String get babyNameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @birthDateNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Birth date not selected'**
  String get birthDateNotSelected;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @saveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and Continue'**
  String get saveContinue;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @weightGr.
  ///
  /// In en, this message translates to:
  /// **'Weight (g)'**
  String get weightGr;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @headCircumferenceOptional.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference (optional)'**
  String get headCircumferenceOptional;

  /// No description provided for @waistCircumferenceOptional.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference (optional)'**
  String get waistCircumferenceOptional;

  /// No description provided for @feedingSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding Session'**
  String get feedingSessionTitle;

  /// No description provided for @babyWeightGr.
  ///
  /// In en, this message translates to:
  /// **'Baby Weight (g)'**
  String get babyWeightGr;

  /// No description provided for @exampleWeight.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2500'**
  String get exampleWeight;

  /// No description provided for @liveSession.
  ///
  /// In en, this message translates to:
  /// **'Live Session'**
  String get liveSession;

  /// No description provided for @backLiveSession.
  ///
  /// In en, this message translates to:
  /// **'Ongoing breastfeeding was recorded in the background.'**
  String get backLiveSession;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @tapLeftOrRightToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap left or right to start'**
  String get tapLeftOrRightToStart;

  /// No description provided for @leftSide.
  ///
  /// In en, this message translates to:
  /// **'Left Side'**
  String get leftSide;

  /// No description provided for @rightSide.
  ///
  /// In en, this message translates to:
  /// **'Right Side'**
  String get rightSide;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @feedingSummary.
  ///
  /// In en, this message translates to:
  /// **'Feeding Summary'**
  String get feedingSummary;

  /// No description provided for @leftLabel.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftLabel;

  /// No description provided for @rightLabel.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get rightLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @feedingAfterWeight.
  ///
  /// In en, this message translates to:
  /// **'Feeding After Weight'**
  String get feedingAfterWeight;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @currentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentLabel;

  /// No description provided for @enterNewValueHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new value'**
  String get enterNewValueHint;

  /// No description provided for @currentGrowthSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Current Growth Snapshot'**
  String get currentGrowthSnapshot;

  /// No description provided for @saveGrowthRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Growth Record'**
  String get saveGrowthRecord;

  /// No description provided for @growthUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth Update'**
  String get growthUpdateTitle;

  /// No description provided for @historyHubTitle.
  ///
  /// In en, this message translates to:
  /// **'History Hub'**
  String get historyHubTitle;

  /// No description provided for @historyHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track everything about your baby'**
  String get historyHubSubtitle;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @recordsOverview.
  ///
  /// In en, this message translates to:
  /// **'Records overview'**
  String get recordsOverview;

  /// No description provided for @recentTimeline.
  ///
  /// In en, this message translates to:
  /// **'Recent timeline'**
  String get recentTimeline;

  /// No description provided for @noTimelineRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet. Start tracking from the home screen.'**
  String get noTimelineRecords;

  /// No description provided for @analyticsHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium analytics'**
  String get analyticsHubTitle;

  /// No description provided for @analyticsHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Charts and trends for feeding, diapers, growth and milk.'**
  String get analyticsHubSubtitle;

  /// No description provided for @reportsHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsHubTitle;

  /// No description provided for @reportsHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create clean summaries for doctor visits and checkups.'**
  String get reportsHubSubtitle;

  /// No description provided for @diaperPatterns.
  ///
  /// In en, this message translates to:
  /// **'Diaper patterns'**
  String get diaperPatterns;

  /// No description provided for @growthTrends.
  ///
  /// In en, this message translates to:
  /// **'Growth trends'**
  String get growthTrends;

  /// No description provided for @milkTracking.
  ///
  /// In en, this message translates to:
  /// **'Milk tracking'**
  String get milkTracking;

  /// No description provided for @weightAndHeight.
  ///
  /// In en, this message translates to:
  /// **'Weight & height'**
  String get weightAndHeight;

  /// No description provided for @diaperChanges.
  ///
  /// In en, this message translates to:
  /// **'Diaper changes'**
  String get diaperChanges;

  /// No description provided for @sessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get sessionDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @swipeHistoryTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Swipe left on a feeding session to delete it.'**
  String get swipeHistoryTip;

  /// No description provided for @noGrowthDataYet.
  ///
  /// In en, this message translates to:
  /// **'No growth data yet'**
  String get noGrowthDataYet;

  /// No description provided for @leftBreast.
  ///
  /// In en, this message translates to:
  /// **'Left breast'**
  String get leftBreast;

  /// No description provided for @rightBreast.
  ///
  /// In en, this message translates to:
  /// **'Right breast'**
  String get rightBreast;

  /// No description provided for @initialWeight.
  ///
  /// In en, this message translates to:
  /// **'Initial weight'**
  String get initialWeight;

  /// No description provided for @finalWeight.
  ///
  /// In en, this message translates to:
  /// **'Final weight'**
  String get finalWeight;

  /// No description provided for @milkIntake.
  ///
  /// In en, this message translates to:
  /// **'Milk intake'**
  String get milkIntake;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @headCircumference.
  ///
  /// In en, this message translates to:
  /// **'Head Circumference'**
  String get headCircumference;

  /// No description provided for @waistCircumference.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference'**
  String get waistCircumference;

  /// No description provided for @unitGr.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitGr;

  /// No description provided for @unitCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @weightHeightRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight and Height are required'**
  String get weightHeightRequired;

  /// No description provided for @growthRecordSaved.
  ///
  /// In en, this message translates to:
  /// **'Growth record saved'**
  String get growthRecordSaved;

  /// No description provided for @growthHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth History'**
  String get growthHistoryTitle;

  /// No description provided for @yearsShort.
  ///
  /// In en, this message translates to:
  /// **'y'**
  String get yearsShort;

  /// No description provided for @monthsShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get monthsShort;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get daysShort;

  /// No description provided for @dateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateAndTime;

  /// No description provided for @feedingGraph.
  ///
  /// In en, this message translates to:
  /// **'Feeding Graph'**
  String get feedingGraph;

  /// No description provided for @growthGraph.
  ///
  /// In en, this message translates to:
  /// **'Growth Graph'**
  String get growthGraph;

  /// No description provided for @diaperGraph.
  ///
  /// In en, this message translates to:
  /// **'Diaper Graph'**
  String get diaperGraph;

  /// No description provided for @viewCharts.
  ///
  /// In en, this message translates to:
  /// **'View charts'**
  String get viewCharts;

  /// No description provided for @growthCharts.
  ///
  /// In en, this message translates to:
  /// **'Growth Charts'**
  String get growthCharts;

  /// No description provided for @manualFeedingEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Feeding Entry'**
  String get manualFeedingEntry;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @leftRightRatio.
  ///
  /// In en, this message translates to:
  /// **'Left/Right Ratio'**
  String get leftRightRatio;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noGrowthData.
  ///
  /// In en, this message translates to:
  /// **'No growth data'**
  String get noGrowthData;

  /// No description provided for @filter7d.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get filter7d;

  /// No description provided for @filter30d.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get filter30d;

  /// No description provided for @filter90d.
  ///
  /// In en, this message translates to:
  /// **'90d'**
  String get filter90d;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'{day}.{month}'**
  String dateFormat(int day, int month);

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get quickActions;

  /// No description provided for @todayActivities.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Activity'**
  String get todayActivities;

  /// No description provided for @last.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String daysAgo(int count);

  /// No description provided for @liveFeedingContinues.
  ///
  /// In en, this message translates to:
  /// **'Live feeding is in progress'**
  String get liveFeedingContinues;

  /// No description provided for @unsavedFeedingDraft.
  ///
  /// In en, this message translates to:
  /// **'An unsaved feeding draft is ready'**
  String get unsavedFeedingDraft;

  /// No description provided for @longFeedingWarning.
  ///
  /// In en, this message translates to:
  /// **'Feeding has been running for a while. If you forgot to save it, save now and adjust the time later from feeding history.'**
  String get longFeedingWarning;

  /// No description provided for @activeFeedingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding in progress'**
  String get activeFeedingNotificationTitle;

  /// No description provided for @activeFeedingNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'The feeding timer is running. Open Leyumi to stop or save it.'**
  String get activeFeedingNotificationBody;

  /// No description provided for @feedingSideProgress.
  ///
  /// In en, this message translates to:
  /// **'{side} side - {duration}'**
  String feedingSideProgress(String side, String duration);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
