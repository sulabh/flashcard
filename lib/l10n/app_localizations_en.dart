// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flashcard App';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginError => 'Invalid username or password';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get deck => 'Deck';

  @override
  String get study => 'Study';

  @override
  String get startSession => 'Start Session';

  @override
  String get ageGroup => 'Age Group';

  @override
  String get unit => 'Unit';

  @override
  String get timer => 'Timer';

  @override
  String get repetition => 'Repetition';

  @override
  String get correctCount => 'Correct Count';

  @override
  String get greeting => 'Kon\'nichiwa!';

  @override
  String get yourLearning => 'Your Learning';

  @override
  String get overallMastery => 'Overall Mastery';

  @override
  String cardsMastered(int mastered, int total) {
    return '$mastered / $total cards mastered';
  }

  @override
  String get startPractice => 'Start Practice';

  @override
  String get startPracticeSubtitle =>
      'Dive back into your personalized card pool.';

  @override
  String get subjects => 'Subjects';

  @override
  String get subjectsSubtitle => 'Browse cards by subject and category.';

  @override
  String get cardMaintenance => 'Card Maintenance';

  @override
  String get cardMaintenanceSubtitle =>
      'Manage flashcards, import, and export CSV data.';

  @override
  String get settingsSubtitle => 'Customization, appearance, and data.';

  @override
  String get studySession => 'Study Session';

  @override
  String get retryPhase => 'Retry Phase';

  @override
  String get retrying => 'Retrying';

  @override
  String get endQuiz => 'End Quiz';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get skip => 'Skip';

  @override
  String get tapToReveal => 'Tap the card to reveal the answer';

  @override
  String get chooseCorrect => 'Choose the correct answer';

  @override
  String get howWasIt => 'How was it?';

  @override
  String get hard => 'Hard';

  @override
  String get normal => 'Normal';

  @override
  String get easy => 'Easy';

  @override
  String get answer => 'ANSWER';

  @override
  String get sessionComplete => 'Session Complete!';

  @override
  String get greatJob => 'Great job! Here is how you did.';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get sessionAccuracy => 'Session Accuracy';

  @override
  String get cardsStudied => 'Cards Studied';

  @override
  String get correctAnswers => 'Correct Answers';

  @override
  String get globalMasteryGained => 'Global Mastery Gained';

  @override
  String get cardsPerSet => 'Cards per Set';

  @override
  String cardsPerSession(int count) {
    return '$count cards per practice session';
  }

  @override
  String get sessionTimer => 'Session Timer';

  @override
  String get autoFinish => 'Auto-finish session when time runs out';

  @override
  String get noTimer => 'No Timer';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String minutesFull(int count) {
    return '$count Minutes';
  }

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get stats => 'Statistics';

  @override
  String get globalStats => 'Global Stats';

  @override
  String get totalCards => 'Total Cards';

  @override
  String get mastered => 'Mastered';

  @override
  String get accuracy_label => 'Accuracy';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get setupSession => 'Setup Your Session';

  @override
  String get nextChooseSubject => 'Next: Choose Subject';

  @override
  String get chooseSubject => 'Choose Subject';

  @override
  String get noSubjectData =>
      'No subject data available yet. Start practicing!';

  @override
  String get randomSetMessage =>
      'A random set of 20 questions will be prepared.';

  @override
  String get appVersion => 'App Version 1.0.0';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get clearDatabase => 'Clear Database';

  @override
  String get dbClearedSuccess => 'Database cleared successfully';

  @override
  String importedSuccess(int count) {
    return 'Imported $count cards successfully';
  }

  @override
  String get exportedSuccess => 'Exported successfully';

  @override
  String get clearConfirm => 'Are you sure you want to clear all data?';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get downloadSample => 'Download Sample CSV';

  @override
  String get exportFlashcards => 'Export Flashcards (CSV)';

  @override
  String get viewAllCards => 'View All Cards';

  @override
  String get viewCards => 'View Cards';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get nextCard => 'Next Card';

  @override
  String get selfEvalNote =>
      'Self-evaluation: Check your answer and mark it accordingly. (Speech-to-text coming soon!)';

  @override
  String get classicStudyNote =>
      'Recall the answer mentally, then tap the card to reveal.';

  @override
  String get noCardsFound => 'No cards found for this selection.';

  @override
  String flashcardsAvailable(int count) {
    return '$count Flashcards Available';
  }

  @override
  String errorLoading(String error) {
    return 'Error: $error';
  }

  @override
  String errorLoadingStats(String error) {
    return 'Error loading statistics: $error';
  }

  @override
  String get newCards => 'New';

  @override
  String unitLabel(int number) {
    return 'Unit $number';
  }

  @override
  String ageLabel(int age) {
    return 'Age $age';
  }

  @override
  String get firstHalf => 'First Half';

  @override
  String get secondHalf => 'Second Half';

  @override
  String cardProgress(int current, int total) {
    return 'Card $current / $total';
  }

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get autoPlayAudio => 'Auto-play Audio';

  @override
  String get autoPlayAudioSub => 'Automatically read cards aloud';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get premiumRequiredMsg =>
      'Unlock all subjects and features by upgrading to the Premium version!';

  @override
  String get categoryLabel => 'Category';

  @override
  String get selectCategoryFirst => 'Please select a category first';

  @override
  String get loadingAudioEngine => 'Loading audio engine...';

  @override
  String get goBack => 'Go Back';

  @override
  String get iDontKnow => 'I don\'t know';

  @override
  String get yourSelection => 'Your Selection';

  @override
  String get correctAnswerLabel => 'Correct Answer';

  @override
  String get mcqCorrect => 'CORRECT';

  @override
  String get mcqIncorrect => 'INCORRECT';

  @override
  String get all => 'All';
}
