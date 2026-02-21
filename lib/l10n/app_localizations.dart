import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Muscle Clock'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @newSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get newSession;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @addSets.
  ///
  /// In en, this message translates to:
  /// **'Add Sets'**
  String get addSets;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @bodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body Part'**
  String get bodyPart;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @restDays.
  ///
  /// In en, this message translates to:
  /// **'Rest Days'**
  String get restDays;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @totalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total Sessions'**
  String get totalSessions;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @avgPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Avg per Week'**
  String get avgPerWeek;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlan;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planName;

  /// No description provided for @cycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get cycleLength;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @selectBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Select Body Part'**
  String get selectBodyPart;

  /// No description provided for @selectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get selectExercise;

  /// No description provided for @addBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Add Body Part'**
  String get addBodyPart;

  /// No description provided for @addExerciseName.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise Name'**
  String get addExerciseName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @trainingHistory.
  ///
  /// In en, this message translates to:
  /// **'Training History'**
  String get trainingHistory;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @heatmap.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get heatmap;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @avgInterval.
  ///
  /// In en, this message translates to:
  /// **'Avg Interval'**
  String get avgInterval;

  /// No description provided for @currentRest.
  ///
  /// In en, this message translates to:
  /// **'Current Rest'**
  String get currentRest;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @noSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessions;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get dataExported;

  /// No description provided for @dataBackup.
  ///
  /// In en, this message translates to:
  /// **'Data backed up successfully'**
  String get dataBackup;

  /// No description provided for @dataRestored.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get dataRestored;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// No description provided for @shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// No description provided for @arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// No description provided for @ppl.
  ///
  /// In en, this message translates to:
  /// **'PPL'**
  String get ppl;

  /// No description provided for @upperLower.
  ///
  /// In en, this message translates to:
  /// **'Upper/Lower'**
  String get upperLower;

  /// No description provided for @broSplit.
  ///
  /// In en, this message translates to:
  /// **'Bro Split'**
  String get broSplit;

  /// No description provided for @currentSession.
  ///
  /// In en, this message translates to:
  /// **'Current Session'**
  String get currentSession;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @workoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Workout Details'**
  String get workoutDetails;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @selectTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Training Plan'**
  String get selectTrainingPlan;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlan;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get deletePlan;

  /// No description provided for @deletePlanConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{planName}\"?'**
  String deletePlanConfirmation(String planName);

  /// No description provided for @addTrainingDay.
  ///
  /// In en, this message translates to:
  /// **'Add Training Day'**
  String get addTrainingDay;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDay;

  /// No description provided for @selectBodyParts.
  ///
  /// In en, this message translates to:
  /// **'Select Body Parts'**
  String get selectBodyParts;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @exportAsJson.
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get exportAsJson;

  /// No description provided for @createBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Create backup file'**
  String get createBackupFile;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last Synced'**
  String get lastSynced;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync completed successfully'**
  String get syncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registerFailed;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get loggedInAs;

  /// No description provided for @glutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get glutes;

  /// No description provided for @abs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get abs;

  /// No description provided for @tapToSetTraining.
  ///
  /// In en, this message translates to:
  /// **'Tap to set training'**
  String get tapToSetTraining;

  /// No description provided for @squat.
  ///
  /// In en, this message translates to:
  /// **'Squat'**
  String get squat;

  /// No description provided for @benchPress.
  ///
  /// In en, this message translates to:
  /// **'Bench Press'**
  String get benchPress;

  /// No description provided for @deadlift.
  ///
  /// In en, this message translates to:
  /// **'Deadlift'**
  String get deadlift;

  /// No description provided for @pullUps.
  ///
  /// In en, this message translates to:
  /// **'Pull-ups'**
  String get pullUps;

  /// No description provided for @overheadPress.
  ///
  /// In en, this message translates to:
  /// **'Overhead Press'**
  String get overheadPress;

  /// No description provided for @barbellRow.
  ///
  /// In en, this message translates to:
  /// **'Barbell Row'**
  String get barbellRow;

  /// No description provided for @legPress.
  ///
  /// In en, this message translates to:
  /// **'Leg Press'**
  String get legPress;

  /// No description provided for @inclineBenchPress.
  ///
  /// In en, this message translates to:
  /// **'Incline Bench Press'**
  String get inclineBenchPress;

  /// No description provided for @latPulldown.
  ///
  /// In en, this message translates to:
  /// **'Lat Pulldown'**
  String get latPulldown;

  /// No description provided for @dumbbellCurl.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell Curl'**
  String get dumbbellCurl;

  /// No description provided for @lateralRaise.
  ///
  /// In en, this message translates to:
  /// **'Lateral Raise'**
  String get lateralRaise;

  /// No description provided for @legExtension.
  ///
  /// In en, this message translates to:
  /// **'Leg Extension'**
  String get legExtension;

  /// No description provided for @legCurl.
  ///
  /// In en, this message translates to:
  /// **'Leg Curl'**
  String get legCurl;

  /// No description provided for @calfRaise.
  ///
  /// In en, this message translates to:
  /// **'Calf Raise'**
  String get calfRaise;

  /// No description provided for @romanianDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Romanian Deadlift'**
  String get romanianDeadlift;

  /// No description provided for @hipThrust.
  ///
  /// In en, this message translates to:
  /// **'Hip Thrust'**
  String get hipThrust;

  /// No description provided for @lunges.
  ///
  /// In en, this message translates to:
  /// **'Lunges'**
  String get lunges;

  /// No description provided for @dips.
  ///
  /// In en, this message translates to:
  /// **'Dips'**
  String get dips;

  /// No description provided for @pushUps.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get pushUps;

  /// No description provided for @dumbbellFly.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell Fly'**
  String get dumbbellFly;

  /// No description provided for @cableCrossover.
  ///
  /// In en, this message translates to:
  /// **'Cable Crossover'**
  String get cableCrossover;

  /// No description provided for @declineBenchPress.
  ///
  /// In en, this message translates to:
  /// **'Decline Bench Press'**
  String get declineBenchPress;

  /// No description provided for @dumbbellRow.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell Row'**
  String get dumbbellRow;

  /// No description provided for @seatedCableRow.
  ///
  /// In en, this message translates to:
  /// **'Seated Cable Row'**
  String get seatedCableRow;

  /// No description provided for @tBarRow.
  ///
  /// In en, this message translates to:
  /// **'T-Bar Row'**
  String get tBarRow;

  /// No description provided for @dumbbellShoulderPress.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell Shoulder Press'**
  String get dumbbellShoulderPress;

  /// No description provided for @frontRaise.
  ///
  /// In en, this message translates to:
  /// **'Front Raise'**
  String get frontRaise;

  /// No description provided for @rearDeltFly.
  ///
  /// In en, this message translates to:
  /// **'Rear Delt Fly'**
  String get rearDeltFly;

  /// No description provided for @facePull.
  ///
  /// In en, this message translates to:
  /// **'Face Pull'**
  String get facePull;

  /// No description provided for @shrugs.
  ///
  /// In en, this message translates to:
  /// **'Shrugs'**
  String get shrugs;

  /// No description provided for @barbellCurl.
  ///
  /// In en, this message translates to:
  /// **'Barbell Curl'**
  String get barbellCurl;

  /// No description provided for @hammerCurl.
  ///
  /// In en, this message translates to:
  /// **'Hammer Curl'**
  String get hammerCurl;

  /// No description provided for @tricepPushdown.
  ///
  /// In en, this message translates to:
  /// **'Tricep Pushdown'**
  String get tricepPushdown;

  /// No description provided for @tricepDips.
  ///
  /// In en, this message translates to:
  /// **'Tricep Dips'**
  String get tricepDips;

  /// No description provided for @skullCrusher.
  ///
  /// In en, this message translates to:
  /// **'Skull Crusher'**
  String get skullCrusher;

  /// No description provided for @preacherCurl.
  ///
  /// In en, this message translates to:
  /// **'Preacher Curl'**
  String get preacherCurl;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
