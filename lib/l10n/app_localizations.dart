import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PulseFit Pro'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PulseFit Pro'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal AI fitness trainer'**
  String get onboardingSubtitle;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @weightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get weightLoss;

  /// No description provided for @muscleGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get muscleGain;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @createProgram.
  ///
  /// In en, this message translates to:
  /// **'Create Program'**
  String get createProgram;

  /// No description provided for @todayWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todayWorkout;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @completeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Complete Workout'**
  String get completeWorkout;

  /// No description provided for @chatWithTrainer.
  ///
  /// In en, this message translates to:
  /// **'Chat with Trainer'**
  String get chatWithTrainer;

  /// No description provided for @uploadFridgePhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Fridge Photo'**
  String get uploadFridgePhoto;

  /// No description provided for @mealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get mealPlan;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @bodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Body Composition'**
  String get bodyComposition;

  /// No description provided for @physicalParams.
  ///
  /// In en, this message translates to:
  /// **'Physical Parameters'**
  String get physicalParams;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get privacy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get about;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

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

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

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

  /// No description provided for @startExercise.
  ///
  /// In en, this message translates to:
  /// **'Start Exercise'**
  String get startExercise;

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get addToMeal;

  /// No description provided for @allAdded.
  ///
  /// In en, this message translates to:
  /// **'All Added ✔'**
  String get allAdded;

  /// No description provided for @suggestedProducts.
  ///
  /// In en, this message translates to:
  /// **'Suggested Products'**
  String get suggestedProducts;

  /// No description provided for @excellentAllAccounted.
  ///
  /// In en, this message translates to:
  /// **'Excellent! Everything accounted for.'**
  String get excellentAllAccounted;

  /// No description provided for @partnerStoreSoon.
  ///
  /// In en, this message translates to:
  /// **'Partner Store — Coming Soon ✨'**
  String get partnerStoreSoon;

  /// No description provided for @buyAllSelected.
  ///
  /// In en, this message translates to:
  /// **'Buy All Selected'**
  String get buyAllSelected;

  /// No description provided for @nutritionByPhoto.
  ///
  /// In en, this message translates to:
  /// **'Nutrition by Photo, Diet Control, Questions'**
  String get nutritionByPhoto;

  /// No description provided for @todayMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meal Plan'**
  String get todayMealPlan;

  /// No description provided for @fullMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Full Meal Plan'**
  String get fullMealPlan;

  /// No description provided for @uploadFridgePhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo of your fridge — we\'ll suggest what to buy and what to cook.'**
  String get uploadFridgePhotoDesc;

  /// No description provided for @uploadFridgePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Fridge Photo'**
  String get uploadFridgePhotoLabel;

  /// No description provided for @suggestRecipes.
  ///
  /// In en, this message translates to:
  /// **'Suggest Recipes'**
  String get suggestRecipes;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @selectDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDay;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// No description provided for @triceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get triceps;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @biceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get biceps;

  /// No description provided for @abs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get abs;

  /// No description provided for @legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// No description provided for @glutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get glutes;

  /// No description provided for @calves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get calves;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @technique.
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get technique;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @muscleGroups.
  ///
  /// In en, this message translates to:
  /// **'Muscle Groups'**
  String get muscleGroups;

  /// No description provided for @workoutProgram.
  ///
  /// In en, this message translates to:
  /// **'Workout Program'**
  String get workoutProgram;

  /// No description provided for @physicalParameters.
  ///
  /// In en, this message translates to:
  /// **'Physical Parameters'**
  String get physicalParameters;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @bodyScan.
  ///
  /// In en, this message translates to:
  /// **'Body Scan'**
  String get bodyScan;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @endurance.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get endurance;

  /// No description provided for @generalFitness.
  ///
  /// In en, this message translates to:
  /// **'General Fitness'**
  String get generalFitness;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @exerciseDetails.
  ///
  /// In en, this message translates to:
  /// **'Exercise Details'**
  String get exerciseDetails;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @createPersonalProgram.
  ///
  /// In en, this message translates to:
  /// **'Create a personal 28-day program'**
  String get createPersonalProgram;

  /// No description provided for @weConsiderGoal.
  ///
  /// In en, this message translates to:
  /// **'We consider your goal, body parameters and activity.'**
  String get weConsiderGoal;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @planForDay.
  ///
  /// In en, this message translates to:
  /// **'Plan for day'**
  String get planForDay;

  /// No description provided for @startWillBeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Start will be available on workout day'**
  String get startWillBeAvailable;

  /// No description provided for @omeletWithVegetables.
  ///
  /// In en, this message translates to:
  /// **'Omelet with vegetables'**
  String get omeletWithVegetables;

  /// No description provided for @chickenWithRice.
  ///
  /// In en, this message translates to:
  /// **'Chicken with rice'**
  String get chickenWithRice;

  /// No description provided for @cottageCheeseWithBerries.
  ///
  /// In en, this message translates to:
  /// **'Cottage cheese with berries'**
  String get cottageCheeseWithBerries;

  /// No description provided for @oliveOil.
  ///
  /// In en, this message translates to:
  /// **'Olive oil'**
  String get oliveOil;

  /// No description provided for @oatmeal.
  ///
  /// In en, this message translates to:
  /// **'Oatmeal'**
  String get oatmeal;

  /// No description provided for @greekYogurt.
  ///
  /// In en, this message translates to:
  /// **'Greek yogurt'**
  String get greekYogurt;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @addedTo.
  ///
  /// In en, this message translates to:
  /// **'Added to'**
  String get addedTo;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @workoutAndNutritionReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout and nutrition reminders'**
  String get workoutAndNutritionReminders;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// No description provided for @setTimeAndTypes.
  ///
  /// In en, this message translates to:
  /// **'Set time and types of notifications'**
  String get setTimeAndTypes;

  /// No description provided for @privacyAndData.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Data'**
  String get privacyAndData;

  /// No description provided for @usageAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get usageAnalytics;

  /// No description provided for @helpImproveApp.
  ///
  /// In en, this message translates to:
  /// **'Help improve the app'**
  String get helpImproveApp;

  /// No description provided for @dataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get dataSharing;

  /// No description provided for @anonymousStatsForResearch.
  ///
  /// In en, this message translates to:
  /// **'Anonymous statistics for research'**
  String get anonymousStatsForResearch;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @downloadAllYourData.
  ///
  /// In en, this message translates to:
  /// **'Download all your data'**
  String get downloadAllYourData;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// No description provided for @clearAllAppData.
  ///
  /// In en, this message translates to:
  /// **'Clear all app data'**
  String get clearAllAppData;

  /// No description provided for @languageAndRegion.
  ///
  /// In en, this message translates to:
  /// **'Language and Region'**
  String get languageAndRegion;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission'**
  String get cameraPermission;

  /// No description provided for @neededForPhotoUpload.
  ///
  /// In en, this message translates to:
  /// **'Needed for photo upload'**
  String get neededForPhotoUpload;

  /// No description provided for @storagePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission'**
  String get storagePermission;

  /// No description provided for @neededForDataStorage.
  ///
  /// In en, this message translates to:
  /// **'Needed for data storage'**
  String get neededForDataStorage;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @frontDelts.
  ///
  /// In en, this message translates to:
  /// **'Front Delts'**
  String get frontDelts;

  /// No description provided for @sideDelts.
  ///
  /// In en, this message translates to:
  /// **'Side Delts'**
  String get sideDelts;

  /// No description provided for @rearDelts.
  ///
  /// In en, this message translates to:
  /// **'Rear Delts'**
  String get rearDelts;

  /// No description provided for @arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// No description provided for @restDay.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get restDay;

  /// No description provided for @restAndRecovery.
  ///
  /// In en, this message translates to:
  /// **'Rest and Recovery'**
  String get restAndRecovery;

  /// No description provided for @growing.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get growing;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @progressOverview.
  ///
  /// In en, this message translates to:
  /// **'Progress Overview'**
  String get progressOverview;

  /// No description provided for @weekWarrior.
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get weekWarrior;

  /// No description provided for @workedOutFor7Days.
  ///
  /// In en, this message translates to:
  /// **'Worked out for 7 days straight'**
  String get workedOutFor7Days;

  /// No description provided for @nutritionMaster.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Master'**
  String get nutritionMaster;

  /// No description provided for @trackedMealsFor30Days.
  ///
  /// In en, this message translates to:
  /// **'Tracked meals for 30 days'**
  String get trackedMealsFor30Days;

  /// No description provided for @fitnessEnthusiast.
  ///
  /// In en, this message translates to:
  /// **'Fitness Enthusiast'**
  String get fitnessEnthusiast;

  /// No description provided for @barbellBenchPressTechnique.
  ///
  /// In en, this message translates to:
  /// **'Lie on the bench, grab the barbell with a grip wider than your shoulders. Lower the barbell to your chest, then press up, fully extending your arms. Keep your shoulder blades retracted, feet stable on the floor.'**
  String get barbellBenchPressTechnique;

  /// No description provided for @barbellMilitaryPressTechnique.
  ///
  /// In en, this message translates to:
  /// **'Stand straight, feet shoulder-width apart. Take the barbell at shoulder level. Press the barbell up overhead, fully extending your arms. Lower it back down in a controlled manner.'**
  String get barbellMilitaryPressTechnique;

  /// No description provided for @dumbbellInclinePressTechnique.
  ///
  /// In en, this message translates to:
  /// **'Set the bench at a 30-45 degree angle. Lie down, grab the dumbbells. Lower the dumbbells to your chest, then press up in an arc, bringing your hands together at the top.'**
  String get dumbbellInclinePressTechnique;

  /// No description provided for @dumbbellLateralRaisesTechnique.
  ///
  /// In en, this message translates to:
  /// **'Stand straight, hold dumbbells at your sides. Raise the dumbbells to the sides to shoulder level, slightly bending your elbows. Lower them back down in a controlled manner.'**
  String get dumbbellLateralRaisesTechnique;

  /// No description provided for @dumbbellTricepExtensionsTechnique.
  ///
  /// In en, this message translates to:
  /// **'Sit or stand, hold a dumbbell with both hands behind your head. Extend your arms at the elbows, raising the dumbbell up. Lower it back down behind your head in a controlled manner.'**
  String get dumbbellTricepExtensionsTechnique;

  /// No description provided for @defaultTechnique.
  ///
  /// In en, this message translates to:
  /// **'Proper exercise technique. Watch your breathing and control your movements.'**
  String get defaultTechnique;

  /// No description provided for @barbellBenchPressTips.
  ///
  /// In en, this message translates to:
  /// **'Keep your core tight, maintain a slight arch in your back, and control the weight throughout the movement.'**
  String get barbellBenchPressTips;

  /// No description provided for @barbellMilitaryPressTips.
  ///
  /// In en, this message translates to:
  /// **'Keep your core engaged, don\'t lean back excessively, and press straight up overhead.'**
  String get barbellMilitaryPressTips;

  /// No description provided for @dumbbellInclinePressTips.
  ///
  /// In en, this message translates to:
  /// **'Control the weight, don\'t let it bounce off your chest, and focus on the squeeze at the top.'**
  String get dumbbellInclinePressTips;

  /// No description provided for @dumbbellLateralRaisesTips.
  ///
  /// In en, this message translates to:
  /// **'Use a controlled motion, don\'t swing the weights, and focus on the deltoid contraction.'**
  String get dumbbellLateralRaisesTips;

  /// No description provided for @dumbbellTricepExtensionsTips.
  ///
  /// In en, this message translates to:
  /// **'Keep your elbows close to your head, don\'t let them flare out, and control the stretch.'**
  String get dumbbellTricepExtensionsTips;

  /// No description provided for @defaultTips.
  ///
  /// In en, this message translates to:
  /// **'Focus on proper form, control the weight, and listen to your body.'**
  String get defaultTips;

  /// No description provided for @progressGallery.
  ///
  /// In en, this message translates to:
  /// **'Progress Gallery'**
  String get progressGallery;

  /// No description provided for @noProgressPhotos.
  ///
  /// In en, this message translates to:
  /// **'No Progress Photos'**
  String get noProgressPhotos;

  /// No description provided for @addFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take your first progress photo to start tracking your fitness journey'**
  String get addFirstPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added successfully'**
  String get photoAdded;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted successfully'**
  String get photoDeleted;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
