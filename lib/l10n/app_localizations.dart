import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
    Locale('ja'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Flashcard App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get loginError;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @deck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get deck;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @ageGroup.
  ///
  /// In en, this message translates to:
  /// **'Age Group'**
  String get ageGroup;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @repetition.
  ///
  /// In en, this message translates to:
  /// **'Repetition'**
  String get repetition;

  /// No description provided for @correctCount.
  ///
  /// In en, this message translates to:
  /// **'Correct Count'**
  String get correctCount;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Kon\'nichiwa!'**
  String get greeting;

  /// No description provided for @yourLearning.
  ///
  /// In en, this message translates to:
  /// **'Your Learning'**
  String get yourLearning;

  /// No description provided for @overallMastery.
  ///
  /// In en, this message translates to:
  /// **'Overall Mastery'**
  String get overallMastery;

  /// No description provided for @cardsMastered.
  ///
  /// In en, this message translates to:
  /// **'{mastered} / {total} cards mastered'**
  String cardsMastered(int mastered, int total);

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  /// No description provided for @startPracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dive back into your personalized card pool.'**
  String get startPracticeSubtitle;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @subjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse cards by category and unit.'**
  String get subjectsSubtitle;

  /// No description provided for @cardMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Card Maintenance'**
  String get cardMaintenance;

  /// No description provided for @cardMaintenanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage flashcards, import, and export CSV data.'**
  String get cardMaintenanceSubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customization, appearance, and data.'**
  String get settingsSubtitle;

  /// No description provided for @studySession.
  ///
  /// In en, this message translates to:
  /// **'Study Session'**
  String get studySession;

  /// No description provided for @retryPhase.
  ///
  /// In en, this message translates to:
  /// **'Retry Phase'**
  String get retryPhase;

  /// No description provided for @retrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying'**
  String get retrying;

  /// No description provided for @endQuiz.
  ///
  /// In en, this message translates to:
  /// **'End Quiz'**
  String get endQuiz;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to reveal the answer'**
  String get tapToReveal;

  /// No description provided for @chooseCorrect.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct answer'**
  String get chooseCorrect;

  /// No description provided for @howWasIt.
  ///
  /// In en, this message translates to:
  /// **'How was it?'**
  String get howWasIt;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'ANSWER'**
  String get answer;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get sessionComplete;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job! Here is how you did.'**
  String get greatJob;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @sessionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Session Accuracy'**
  String get sessionAccuracy;

  /// No description provided for @cardsStudied.
  ///
  /// In en, this message translates to:
  /// **'Cards Studied'**
  String get cardsStudied;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get correctAnswers;

  /// No description provided for @globalMasteryGained.
  ///
  /// In en, this message translates to:
  /// **'Global Mastery Gained'**
  String get globalMasteryGained;

  /// No description provided for @cardsPerSet.
  ///
  /// In en, this message translates to:
  /// **'Cards per Set'**
  String get cardsPerSet;

  /// No description provided for @cardsPerSession.
  ///
  /// In en, this message translates to:
  /// **'{count} cards per practice session'**
  String cardsPerSession(int count);

  /// No description provided for @sessionTimer.
  ///
  /// In en, this message translates to:
  /// **'Session Timer'**
  String get sessionTimer;

  /// No description provided for @autoFinish.
  ///
  /// In en, this message translates to:
  /// **'Auto-finish session when time runs out'**
  String get autoFinish;

  /// No description provided for @noTimer.
  ///
  /// In en, this message translates to:
  /// **'No Timer'**
  String get noTimer;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(int count);

  /// No description provided for @minutesFull.
  ///
  /// In en, this message translates to:
  /// **'{count} Minutes'**
  String minutesFull(int count);

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @globalStats.
  ///
  /// In en, this message translates to:
  /// **'Global Stats'**
  String get globalStats;

  /// No description provided for @totalCards.
  ///
  /// In en, this message translates to:
  /// **'Total Cards'**
  String get totalCards;

  /// No description provided for @mastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get mastered;

  /// No description provided for @accuracy_label.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy_label;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @setupSession.
  ///
  /// In en, this message translates to:
  /// **'Setup Your Session'**
  String get setupSession;

  /// No description provided for @nextChooseSubject.
  ///
  /// In en, this message translates to:
  /// **'Next: Choose Subject'**
  String get nextChooseSubject;

  /// No description provided for @chooseSubject.
  ///
  /// In en, this message translates to:
  /// **'Choose Subject'**
  String get chooseSubject;

  /// No description provided for @noSubjectData.
  ///
  /// In en, this message translates to:
  /// **'No subject data available yet. Start practicing!'**
  String get noSubjectData;

  /// No description provided for @randomSetMessage.
  ///
  /// In en, this message translates to:
  /// **'A random set of 20 questions will be prepared.'**
  String get randomSetMessage;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version 1.0.0'**
  String get appVersion;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @clearDatabase.
  ///
  /// In en, this message translates to:
  /// **'Clear Database'**
  String get clearDatabase;

  /// No description provided for @dbClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Database cleared successfully'**
  String get dbClearedSuccess;

  /// No description provided for @importedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} cards successfully'**
  String importedSuccess(int count);

  /// No description provided for @exportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully'**
  String get exportedSuccess;

  /// No description provided for @clearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all data?'**
  String get clearConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @downloadSample.
  ///
  /// In en, this message translates to:
  /// **'Download Sample CSV'**
  String get downloadSample;

  /// No description provided for @exportFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Export Flashcards (CSV)'**
  String get exportFlashcards;

  /// No description provided for @viewAllCards.
  ///
  /// In en, this message translates to:
  /// **'View All Cards'**
  String get viewAllCards;

  /// No description provided for @viewCards.
  ///
  /// In en, this message translates to:
  /// **'View Cards'**
  String get viewCards;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @nextCard.
  ///
  /// In en, this message translates to:
  /// **'Next Card'**
  String get nextCard;

  /// No description provided for @selfEvalNote.
  ///
  /// In en, this message translates to:
  /// **'Self-evaluation: Check your answer and mark it accordingly. (Speech-to-text coming soon!)'**
  String get selfEvalNote;

  /// No description provided for @classicStudyNote.
  ///
  /// In en, this message translates to:
  /// **'Recall the answer mentally, then tap the card to reveal.'**
  String get classicStudyNote;

  /// No description provided for @noCardsFound.
  ///
  /// In en, this message translates to:
  /// **'No cards found for this selection.'**
  String get noCardsFound;

  /// No description provided for @flashcardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} Flashcards Available'**
  String flashcardsAvailable(int count);

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLoading(String error);

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics: {error}'**
  String errorLoadingStats(String error);

  /// No description provided for @newCards.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCards;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit {number}'**
  String unitLabel(int number);

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age {age}'**
  String ageLabel(int age);

  /// No description provided for @firstHalf.
  ///
  /// In en, this message translates to:
  /// **'First Half'**
  String get firstHalf;

  /// No description provided for @secondHalf.
  ///
  /// In en, this message translates to:
  /// **'Second Half'**
  String get secondHalf;

  /// No description provided for @cardProgress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} / {total}'**
  String cardProgress(int current, int total);

  /// No description provided for @audioSettings.
  ///
  /// In en, this message translates to:
  /// **'Audio Settings'**
  String get audioSettings;

  /// No description provided for @autoPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Auto-play Audio'**
  String get autoPlayAudio;

  /// No description provided for @autoPlayAudioSub.
  ///
  /// In en, this message translates to:
  /// **'Automatically read cards aloud'**
  String get autoPlayAudioSub;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'Unlock all subjects and features by upgrading to the Premium version!'**
  String get premiumRequiredMsg;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
