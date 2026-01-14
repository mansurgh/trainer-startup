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

  /// No description provided for @athlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get athlete;

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

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself for a personalized program'**
  String get tellUsAboutYourself;

  /// No description provided for @unitSystem.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitSystem;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

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

  /// No description provided for @newDish.
  ///
  /// In en, this message translates to:
  /// **'New Dish'**
  String get newDish;

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

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get outOf;

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
  /// **'Done'**
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

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

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
  /// **'Push Notifications'**
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
  /// **'Русский'**
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
  /// **'No progress photos'**
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
  /// **'Photo added!'**
  String get photoAdded;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeleted;

  /// No description provided for @trialRoulette.
  ///
  /// In en, this message translates to:
  /// **'Trial Roulette'**
  String get trialRoulette;

  /// No description provided for @spinTheWheel.
  ///
  /// In en, this message translates to:
  /// **'SPIN THE WHEEL'**
  String get spinTheWheel;

  /// No description provided for @spin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get spin;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉'**
  String get congratulations;

  /// No description provided for @youWonDays.
  ///
  /// In en, this message translates to:
  /// **'You won {days} days of free trial!'**
  String youWonDays(int days);

  /// No description provided for @buyPremium.
  ///
  /// In en, this message translates to:
  /// **'Buy Premium'**
  String get buyPremium;

  /// No description provided for @premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get premiumSubscription;

  /// No description provided for @unlockFullPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock Your Full Potential'**
  String get unlockFullPotential;

  /// No description provided for @personalizedWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Personalized workouts'**
  String get personalizedWorkouts;

  /// No description provided for @personalizedWorkoutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Custom training plans adapted to your goals'**
  String get personalizedWorkoutsDesc;

  /// No description provided for @nutritionTracking.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Tracking'**
  String get nutritionTracking;

  /// No description provided for @nutritionTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Track macros and get meal recommendations'**
  String get nutritionTrackingDesc;

  /// No description provided for @progressAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Progress Analytics'**
  String get progressAnalytics;

  /// No description provided for @progressAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed statistics and achievements'**
  String get progressAnalyticsDesc;

  /// No description provided for @aiNutritionCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Nutrition Coach'**
  String get aiNutritionCoach;

  /// No description provided for @aiNutritionCoachDesc.
  ///
  /// In en, this message translates to:
  /// **'Get personalized diet advice'**
  String get aiNutritionCoachDesc;

  /// No description provided for @workoutLibrary.
  ///
  /// In en, this message translates to:
  /// **'Workout Library'**
  String get workoutLibrary;

  /// No description provided for @workoutLibraryDesc.
  ///
  /// In en, this message translates to:
  /// **'Access 500+ exercises with video guides'**
  String get workoutLibraryDesc;

  /// No description provided for @bodyScanAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Body Scan Analysis'**
  String get bodyScanAnalysis;

  /// No description provided for @bodyScanAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your body composition changes'**
  String get bodyScanAnalysisDesc;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get prioritySupport;

  /// No description provided for @prioritySupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Get faster responses from our team'**
  String get prioritySupportDesc;

  /// No description provided for @adFreeExperience.
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Experience'**
  String get adFreeExperience;

  /// No description provided for @adFreeExperienceDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the app without interruptions'**
  String get adFreeExperienceDesc;

  /// No description provided for @investInYourself.
  ///
  /// In en, this message translates to:
  /// **'Invest in Yourself'**
  String get investInYourself;

  /// No description provided for @gwagonMessage.
  ///
  /// In en, this message translates to:
  /// **'For the price of 3 coffees, you get a personal trainer. Or save up for a G-Wagon... your choice 😎'**
  String get gwagonMessage;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get choosePlan;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @save40.
  ///
  /// In en, this message translates to:
  /// **'Save 40%'**
  String get save40;

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get startFreeTrial;

  /// No description provided for @aiChatTrainer.
  ///
  /// In en, this message translates to:
  /// **'AI Chat - Trainer'**
  String get aiChatTrainer;

  /// No description provided for @aiChatNutritionist.
  ///
  /// In en, this message translates to:
  /// **'AI Chat - Nutritionist'**
  String get aiChatNutritionist;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @nutritionGoals.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get nutritionGoals;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @basedOnYourData.
  ///
  /// In en, this message translates to:
  /// **'Based on your height, weight, age and activity level'**
  String get basedOnYourData;

  /// No description provided for @useRecommended.
  ///
  /// In en, this message translates to:
  /// **'Use Recommended Value'**
  String get useRecommended;

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated'**
  String get goalUpdated;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @aiNutritionistChat.
  ///
  /// In en, this message translates to:
  /// **'AI Nutritionist Chat'**
  String get aiNutritionistChat;

  /// No description provided for @fridgeBasedMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Fridge-based Meal Plan'**
  String get fridgeBasedMealPlan;

  /// No description provided for @addDish.
  ///
  /// In en, this message translates to:
  /// **'Add Dish'**
  String get addDish;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal?'**
  String get deleteMeal;

  /// No description provided for @deleteMealConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meal?'**
  String get deleteMealConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @mealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal Deleted'**
  String get mealDeleted;

  /// No description provided for @editDish.
  ///
  /// In en, this message translates to:
  /// **'Edit Dish'**
  String get editDish;

  /// No description provided for @dishName.
  ///
  /// In en, this message translates to:
  /// **'Dish Name'**
  String get dishName;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @fatG.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatG;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsG;

  /// No description provided for @deleteDish.
  ///
  /// In en, this message translates to:
  /// **'Delete Dish?'**
  String get deleteDish;

  /// No description provided for @deleteDishConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteDishConfirm(Object name);

  /// No description provided for @dishDeleted.
  ///
  /// In en, this message translates to:
  /// **'Dish Deleted'**
  String get dishDeleted;

  /// No description provided for @dishUpdated.
  ///
  /// In en, this message translates to:
  /// **'Dish Updated'**
  String get dishUpdated;

  /// No description provided for @enterDishName.
  ///
  /// In en, this message translates to:
  /// **'Please enter dish name'**
  String get enterDishName;

  /// No description provided for @replaceWithAnotherDish.
  ///
  /// In en, this message translates to:
  /// **'Replace with another dish'**
  String get replaceWithAnotherDish;

  /// No description provided for @enterValidCalories.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid calories'**
  String get enterValidCalories;

  /// No description provided for @enterValidProtein.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid protein amount'**
  String get enterValidProtein;

  /// No description provided for @enterValidFat.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid fat amount'**
  String get enterValidFat;

  /// No description provided for @enterValidCarbs.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid carbs amount'**
  String get enterValidCarbs;

  /// No description provided for @commandHelp.
  ///
  /// In en, this message translates to:
  /// **'Available Commands'**
  String get commandHelp;

  /// No description provided for @commandFat.
  ///
  /// In en, this message translates to:
  /// **'/fat <number> - Set fat goal'**
  String get commandFat;

  /// No description provided for @commandProtein.
  ///
  /// In en, this message translates to:
  /// **'/protein <number> - Set protein goal'**
  String get commandProtein;

  /// No description provided for @commandCarbs.
  ///
  /// In en, this message translates to:
  /// **'/carbs <number> - Set carbs goal'**
  String get commandCarbs;

  /// No description provided for @commandCalories.
  ///
  /// In en, this message translates to:
  /// **'/calories <number> - Set calories goal'**
  String get commandCalories;

  /// No description provided for @commandSwapMeal.
  ///
  /// In en, this message translates to:
  /// **'/swap_meal <old> -> <new> - Replace meal'**
  String get commandSwapMeal;

  /// No description provided for @commandSwapExercise.
  ///
  /// In en, this message translates to:
  /// **'/swap_exercise <old> -> <new> - Replace exercise'**
  String get commandSwapExercise;

  /// No description provided for @unknownCommand.
  ///
  /// In en, this message translates to:
  /// **'Unknown command. Type /help for available commands.'**
  String get unknownCommand;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfile;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @trackYourIntake.
  ///
  /// In en, this message translates to:
  /// **'Track your daily intake'**
  String get trackYourIntake;

  /// No description provided for @exerciseSwapped.
  ///
  /// In en, this message translates to:
  /// **'Exercise replaced successfully'**
  String get exerciseSwapped;

  /// No description provided for @exerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found in current workout'**
  String get exerciseNotFound;

  /// No description provided for @noActiveWorkout.
  ///
  /// In en, this message translates to:
  /// **'No active workout. Start a workout first.'**
  String get noActiveWorkout;

  /// No description provided for @replaceDish.
  ///
  /// In en, this message translates to:
  /// **'Replace Dish'**
  String get replaceDish;

  /// No description provided for @enterNewDishName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the new dish'**
  String get enterNewDishName;

  /// No description provided for @newDishName.
  ///
  /// In en, this message translates to:
  /// **'New dish name'**
  String get newDishName;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @replacementRequested.
  ///
  /// In en, this message translates to:
  /// **'Replacement requested'**
  String get replacementRequested;

  /// No description provided for @aiWillSuggestReplacement.
  ///
  /// In en, this message translates to:
  /// **'AI will suggest a replacement'**
  String get aiWillSuggestReplacement;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @workoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Workout Reminders'**
  String get workoutReminders;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @clearData.
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// No description provided for @clearDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all application data'**
  String get clearDataSubtitle;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we use your data'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Application usage rules'**
  String get termsOfServiceSubtitle;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get supportSubtitle;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout completed'**
  String get workoutCompleted;

  /// No description provided for @workoutCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'Great work! Workout successfully completed.'**
  String get workoutCompletedDesc;

  /// No description provided for @nutritionGoalMet.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goal Met!'**
  String get nutritionGoalMet;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @deleteDataWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all application data?'**
  String get deleteDataWarning;

  /// No description provided for @deleteDataDescription.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All data about workouts, nutrition, and progress will be deleted.'**
  String get deleteDataDescription;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have questions or suggestions, contact us:'**
  String get supportDescription;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'PulseFit Pro respects your privacy. All data is stored locally on your device and is not shared with third parties without your consent.'**
  String get privacyPolicyContent;

  /// No description provided for @workoutsCount.
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get workoutsCount;

  /// No description provided for @todaysWin.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Win'**
  String get todaysWin;

  /// No description provided for @todaysWinDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete workout or nutrition goal to earn today\'s win'**
  String get todaysWinDescription;

  /// No description provided for @bmiDescription.
  ///
  /// In en, this message translates to:
  /// **'BMI (Body Mass Index) shows the ratio of your weight to height. Formula: Weight (kg) / (Height (m))². Normal: 18.5-24.9. Below 18.5 - underweight, 25-29.9 - overweight, 30+ - obesity.'**
  String get bmiDescription;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @firstWorkout.
  ///
  /// In en, this message translates to:
  /// **'First Workout'**
  String get firstWorkout;

  /// No description provided for @completedFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Completed first workout!'**
  String get completedFirstWorkout;

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfile;

  /// No description provided for @heightUnit.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get heightUnit;

  /// No description provided for @fridgeMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Fridge-based meal plan'**
  String get fridgeMealPlan;

  /// No description provided for @workoutSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Settings'**
  String get workoutSettingsTitle;

  /// No description provided for @workoutSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set time for exercises and rest:'**
  String get workoutSettingsSubtitle;

  /// No description provided for @exerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise:'**
  String get exerciseLabel;

  /// No description provided for @restLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest:'**
  String get restLabel;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get seconds;

  /// No description provided for @generatingProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Creating your personal\nworkout program...'**
  String get generatingProgramTitle;

  /// No description provided for @generatingProgramSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will take just a few seconds'**
  String get generatingProgramSubtitle;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get streakDays;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @streakHelp.
  ///
  /// In en, this message translates to:
  /// **'Number of consecutive days you completed at least one goal (workout or nutrition).'**
  String get streakHelp;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLabel;

  /// No description provided for @activityDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get activityDays;

  /// No description provided for @workoutScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Program'**
  String get workoutScheduleTitle;

  /// No description provided for @startAgain.
  ///
  /// In en, this message translates to:
  /// **'Start Again'**
  String get startAgain;

  /// No description provided for @restDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest Day'**
  String get restDayTitle;

  /// No description provided for @restDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Recovery is just as important as training'**
  String get restDayDesc;

  /// No description provided for @customizeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Customize Workout'**
  String get customizeWorkout;

  /// No description provided for @aiTrainerChat.
  ///
  /// In en, this message translates to:
  /// **'AI Trainer Chat'**
  String get aiTrainerChat;

  /// No description provided for @workoutUpdated.
  ///
  /// In en, this message translates to:
  /// **'Workout updated successfully'**
  String get workoutUpdated;

  /// No description provided for @failedToUpdateWorkout.
  ///
  /// In en, this message translates to:
  /// **'Failed to update workout'**
  String get failedToUpdateWorkout;

  /// No description provided for @workoutAvailableTodayOnly.
  ///
  /// In en, this message translates to:
  /// **'Workout available today only'**
  String get workoutAvailableTodayOnly;

  /// No description provided for @workoutAvailableTodayOnlyDesc.
  ///
  /// In en, this message translates to:
  /// **'You can only perform the workout on the current day. Select today.'**
  String get workoutAvailableTodayOnlyDesc;

  /// No description provided for @mealAdded.
  ///
  /// In en, this message translates to:
  /// **'Meal Added'**
  String get mealAdded;

  /// No description provided for @mealRenamed.
  ///
  /// In en, this message translates to:
  /// **'Meal Renamed'**
  String get mealRenamed;

  /// No description provided for @dishAdded.
  ///
  /// In en, this message translates to:
  /// **'Dish Added'**
  String get dishAdded;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @noActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get noActivity;

  /// No description provided for @workoutCheck.
  ///
  /// In en, this message translates to:
  /// **'Workout ✓'**
  String get workoutCheck;

  /// No description provided for @nutritionCheck.
  ///
  /// In en, this message translates to:
  /// **'Nutrition ✓'**
  String get nutritionCheck;

  /// No description provided for @workoutAndNutritionCheck.
  ///
  /// In en, this message translates to:
  /// **'Workout ✓ Nutrition ✓'**
  String get workoutAndNutritionCheck;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @updateWeight.
  ///
  /// In en, this message translates to:
  /// **'Update Weight'**
  String get updateWeight;

  /// No description provided for @successDay.
  ///
  /// In en, this message translates to:
  /// **'Success Day'**
  String get successDay;

  /// No description provided for @characteristics.
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get characteristics;

  /// No description provided for @setNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {current}/{total}'**
  String setNumber(Object current, Object total);

  /// No description provided for @restPhase.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restPhase;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @backView.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backView;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @aiFormFeedback.
  ///
  /// In en, this message translates to:
  /// **'AI form feedback'**
  String get aiFormFeedback;

  /// No description provided for @progressTracking.
  ///
  /// In en, this message translates to:
  /// **'Progress tracking'**
  String get progressTracking;

  /// No description provided for @unlimitedAiChat.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI chat'**
  String get unlimitedAiChat;

  /// No description provided for @nameChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Name changed to \"{name}\"'**
  String nameChangedTo(Object name);

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// No description provided for @avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get avatarUpdated;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @dataSaved.
  ///
  /// In en, this message translates to:
  /// **'Data saved'**
  String get dataSaved;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @customMeal.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get customMeal;

  /// No description provided for @exerciseSkipped.
  ///
  /// In en, this message translates to:
  /// **'Exercise skipped'**
  String get exerciseSkipped;

  /// No description provided for @setCompleted.
  ///
  /// In en, this message translates to:
  /// **'Set completed'**
  String get setCompleted;

  /// No description provided for @restTime.
  ///
  /// In en, this message translates to:
  /// **'Rest time'**
  String get restTime;

  /// No description provided for @startWorkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkoutButton;

  /// No description provided for @endWorkout.
  ///
  /// In en, this message translates to:
  /// **'End workout'**
  String get endWorkout;

  /// No description provided for @availableOnTrainingDay.
  ///
  /// In en, this message translates to:
  /// **'Available on training day'**
  String get availableOnTrainingDay;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @photoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Photo uploaded'**
  String get photoUploaded;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get totalVolume;

  /// No description provided for @discipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get discipline;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get goalProgress;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight trend'**
  String get weightTrend;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @trainToSeeStats.
  ///
  /// In en, this message translates to:
  /// **'Train to see your stats'**
  String get trainToSeeStats;

  /// No description provided for @progressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotos;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noProgressPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noProgressPhotosYet;

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get tapToAdd;

  /// No description provided for @errorLoadingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Error loading photos'**
  String get errorLoadingPhotos;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @interfaceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get interfaceLanguage;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @howWeUseYourData.
  ///
  /// In en, this message translates to:
  /// **'How we use your data'**
  String get howWeUseYourData;

  /// No description provided for @appUsageRules.
  ///
  /// In en, this message translates to:
  /// **'Application usage rules'**
  String get appUsageRules;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @workoutsLabel.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutsLabel;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @nutritionHistory.
  ///
  /// In en, this message translates to:
  /// **'Nutrition History'**
  String get nutritionHistory;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// No description provided for @profileData.
  ///
  /// In en, this message translates to:
  /// **'Profile Data'**
  String get profileData;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @noNutritionData.
  ///
  /// In en, this message translates to:
  /// **'No nutrition data yet'**
  String get noNutritionData;

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalWorkouts;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @noWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No workouts'**
  String get noWorkouts;

  /// No description provided for @startWorkingOutHint.
  ///
  /// In en, this message translates to:
  /// **'Start working out\nto see your history'**
  String get startWorkingOutHint;

  /// No description provided for @noMealsLogged.
  ///
  /// In en, this message translates to:
  /// **'No meals logged'**
  String get noMealsLogged;

  /// No description provided for @checkForm.
  ///
  /// In en, this message translates to:
  /// **'Check Form'**
  String get checkForm;

  /// No description provided for @formAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Form Analysis'**
  String get formAnalysis;

  /// No description provided for @errorsDetected.
  ///
  /// In en, this message translates to:
  /// **'Errors Detected'**
  String get errorsDetected;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @videoGuide.
  ///
  /// In en, this message translates to:
  /// **'Video Guide'**
  String get videoGuide;

  /// No description provided for @getReady.
  ///
  /// In en, this message translates to:
  /// **'Get Ready'**
  String get getReady;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @aiAnalyzingForm.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing your form'**
  String get aiAnalyzingForm;

  /// No description provided for @countdownTimer.
  ///
  /// In en, this message translates to:
  /// **'Countdown Timer'**
  String get countdownTimer;

  /// No description provided for @tapToStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording'**
  String get tapToStartRecording;

  /// No description provided for @tapToStopOrWait.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop or wait {seconds}s'**
  String tapToStopOrWait(Object seconds);

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @weeklyHistory.
  ///
  /// In en, this message translates to:
  /// **'Weekly History'**
  String get weeklyHistory;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackYourProgress;

  /// No description provided for @checkPermissions.
  ///
  /// In en, this message translates to:
  /// **'Check permissions'**
  String get checkPermissions;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @core.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get core;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordTooShort;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @incompleteForm.
  ///
  /// In en, this message translates to:
  /// **'Incomplete form'**
  String get incompleteForm;

  /// No description provided for @trialEnded.
  ///
  /// In en, this message translates to:
  /// **'Your Free Trial\nHas Ended'**
  String get trialEnded;

  /// No description provided for @trialEndedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'7 days of free access have expired.\nSubscribe to continue using the app.'**
  String get trialEndedSubtitle;

  /// No description provided for @mealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal plans'**
  String get mealPlans;

  /// No description provided for @aiCoach247.
  ///
  /// In en, this message translates to:
  /// **'AI coach 24/7'**
  String get aiCoach247;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @restoringPurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restoringPurchases;

  /// No description provided for @checkingPurchases.
  ///
  /// In en, this message translates to:
  /// **'Checking your purchases...'**
  String get checkingPurchases;

  /// No description provided for @testYourLuck.
  ///
  /// In en, this message translates to:
  /// **'Test Your Luck!'**
  String get testYourLuck;

  /// No description provided for @spinWheelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spin the wheel for a chance to win free trial days'**
  String get spinWheelSubtitle;

  /// No description provided for @daysFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} Days Free Trial!'**
  String daysFreeTrial(int days);

  /// No description provided for @noLuckThisTime.
  ///
  /// In en, this message translates to:
  /// **'No Luck This Time'**
  String get noLuckThisTime;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again!'**
  String get tryAgain;

  /// No description provided for @noLuckButPremium.
  ///
  /// In en, this message translates to:
  /// **'No luck this time, but you can still get premium!'**
  String get noLuckButPremium;

  /// No description provided for @getPremiumNow.
  ///
  /// In en, this message translates to:
  /// **'Get Premium Now'**
  String get getPremiumNow;

  /// No description provided for @buyPremiumNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Premium Now'**
  String get buyPremiumNow;

  /// No description provided for @premiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// No description provided for @premiumFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'• AI Personal Trainer & Nutritionist\n• Custom Workout Plans\n• Meal Planning & Tracking\n• Progress Analytics\n• Unlimited Everything'**
  String get premiumFeaturesList;

  /// No description provided for @targetMuscle.
  ///
  /// In en, this message translates to:
  /// **'Target muscle'**
  String get targetMuscle;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @calorieGoal.
  ///
  /// In en, this message translates to:
  /// **'of daily goal'**
  String get calorieGoal;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// No description provided for @takePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhotoCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @disciplineRating.
  ///
  /// In en, this message translates to:
  /// **'Discipline Rating'**
  String get disciplineRating;

  /// No description provided for @consistencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistencyLabel;

  /// No description provided for @nutritionLabel.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionLabel;

  /// No description provided for @strengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strengthLabel;

  /// No description provided for @enduranceLabel.
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get enduranceLabel;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @howRatingCalculated.
  ///
  /// In en, this message translates to:
  /// **'How is the rating calculated?'**
  String get howRatingCalculated;

  /// No description provided for @ratingExplanation.
  ///
  /// In en, this message translates to:
  /// **'Discipline rating measures your workout consistency and dedication.\n\n• Consistency (400 max) — active day streak\n• Nutrition (150 max) — meal plan adherence\n• Strength (150 max) — exercise progress\n• Endurance (150 max) — workout duration\n• Balance (150 max) — exercise variety'**
  String get ratingExplanation;

  /// No description provided for @successDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day Success — {percentage}%'**
  String successDayTitle(int percentage);

  /// No description provided for @appLogin.
  ///
  /// In en, this message translates to:
  /// **'App login'**
  String get appLogin;

  /// No description provided for @workoutActivity.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutActivity;

  /// No description provided for @completeAllForHundred.
  ///
  /// In en, this message translates to:
  /// **'Complete all activities to reach 100%!'**
  String get completeAllForHundred;

  /// No description provided for @workoutsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Workouts This Month'**
  String get workoutsThisMonth;

  /// No description provided for @monthlyGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {target} workouts per month.'**
  String monthlyGoal(int target);

  /// No description provided for @workoutsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {remaining} workouts.'**
  String workoutsRemaining(int remaining);

  /// No description provided for @activityStreak.
  ///
  /// In en, this message translates to:
  /// **'Activity Streak'**
  String get activityStreak;

  /// No description provided for @daysInRow.
  ///
  /// In en, this message translates to:
  /// **'{days} days in a row'**
  String daysInRow(int days);

  /// No description provided for @streakExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your streak counts for each day when you:\n• Completed a workout\n• Or logged a meal\n\nMaintain your streak to earn bonuses!'**
  String get streakExplanation;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sundayShort;

  /// No description provided for @cmUnit.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cmUnit;

  /// No description provided for @kgUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kgUnit;

  /// No description provided for @yearsUnit.
  ///
  /// In en, this message translates to:
  /// **'y.o.'**
  String get yearsUnit;

  /// No description provided for @disciplineDesc.
  ///
  /// In en, this message translates to:
  /// **'Regularity and plan adherence'**
  String get disciplineDesc;

  /// No description provided for @nutritionDesc.
  ///
  /// In en, this message translates to:
  /// **'Following nutrition schedule'**
  String get nutritionDesc;

  /// No description provided for @strengthDesc.
  ///
  /// In en, this message translates to:
  /// **'Max weight in basic exercises'**
  String get strengthDesc;

  /// No description provided for @enduranceDesc.
  ///
  /// In en, this message translates to:
  /// **'Ability for prolonged loads'**
  String get enduranceDesc;

  /// No description provided for @balanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Coordination and balance'**
  String get balanceDesc;

  /// No description provided for @addMealEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMealEntry;

  /// No description provided for @lowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBody;

  /// No description provided for @upperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBody;

  /// No description provided for @fullBody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get fullBody;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @pull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get pull;

  /// No description provided for @kcalUnit.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcalUnit;

  /// No description provided for @userNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'User not authorized'**
  String get userNotAuthorized;

  /// No description provided for @photoLoadError.
  ///
  /// In en, this message translates to:
  /// **'Photo load error'**
  String get photoLoadError;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note about this photo...'**
  String get noteHint;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @comparePhotos.
  ///
  /// In en, this message translates to:
  /// **'Compare Photos'**
  String get comparePhotos;

  /// No description provided for @addPhotoShort.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addPhotoShort;

  /// No description provided for @repeatAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get repeatAction;

  /// No description provided for @addFirstPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first photo\nto track your changes'**
  String get addFirstPhotoHint;

  /// No description provided for @photoNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Note'**
  String get photoNoteTitle;

  /// No description provided for @describeProgress.
  ///
  /// In en, this message translates to:
  /// **'Describe your progress...'**
  String get describeProgress;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @deletePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete photo?'**
  String get deletePhotoConfirm;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Delete error'**
  String get deleteError;

  /// No description provided for @needMinPhotosForCompare.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 photos to compare'**
  String get needMinPhotosForCompare;

  /// No description provided for @comparison.
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparison;

  /// No description provided for @selectBefore.
  ///
  /// In en, this message translates to:
  /// **'Select \"Before\"'**
  String get selectBefore;

  /// No description provided for @selectAfter.
  ///
  /// In en, this message translates to:
  /// **'Select \"After\"'**
  String get selectAfter;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @lessThanOneDay.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 day'**
  String get lessThanOneDay;

  /// No description provided for @oneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// No description provided for @daysPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysPlural(int count);

  /// No description provided for @weeksPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks'**
  String weeksPlural(int count);

  /// No description provided for @monthsPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsPlural(int count);

  /// No description provided for @yearsPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} year(s)'**
  String yearsPlural(int count);

  /// No description provided for @janShort.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get janShort;

  /// No description provided for @febShort.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get febShort;

  /// No description provided for @marShort.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get marShort;

  /// No description provided for @aprShort.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get aprShort;

  /// No description provided for @mayShort.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get mayShort;

  /// No description provided for @junShort.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get junShort;

  /// No description provided for @julShort.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get julShort;

  /// No description provided for @augShort.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get augShort;

  /// No description provided for @sepShort.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sepShort;

  /// No description provided for @octShort.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get octShort;

  /// No description provided for @novShort.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get novShort;

  /// No description provided for @decShort.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get decShort;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @rankNovice.
  ///
  /// In en, this message translates to:
  /// **'NOVICE'**
  String get rankNovice;

  /// No description provided for @rankApprentice.
  ///
  /// In en, this message translates to:
  /// **'APPRENTICE'**
  String get rankApprentice;

  /// No description provided for @rankWarrior.
  ///
  /// In en, this message translates to:
  /// **'WARRIOR'**
  String get rankWarrior;

  /// No description provided for @rankChampion.
  ///
  /// In en, this message translates to:
  /// **'CHAMPION'**
  String get rankChampion;

  /// No description provided for @rankMachine.
  ///
  /// In en, this message translates to:
  /// **'MACHINE'**
  String get rankMachine;

  /// No description provided for @rankLegend.
  ///
  /// In en, this message translates to:
  /// **'LEGEND'**
  String get rankLegend;

  /// No description provided for @aiTrainer.
  ///
  /// In en, this message translates to:
  /// **'AI Trainer'**
  String get aiTrainer;

  /// No description provided for @aiNutritionist.
  ///
  /// In en, this message translates to:
  /// **'AI Nutritionist'**
  String get aiNutritionist;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @featureNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This feature is not available yet'**
  String get featureNotAvailable;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again'**
  String get uploadFailed;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noWorkoutsYet.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkoutsYet;
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
