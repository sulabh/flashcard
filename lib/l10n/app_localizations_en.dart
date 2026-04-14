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
}
