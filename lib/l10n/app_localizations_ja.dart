// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'フラッシュカード・アプリ';

  @override
  String get login => 'ログイン';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get loginError => 'ユーザー名またはパスワードが無効です';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get deck => 'デッキ';

  @override
  String get study => '学習';

  @override
  String get startSession => 'セッション開始';

  @override
  String get ageGroup => '年齢グループ';

  @override
  String get unit => 'ユニット';

  @override
  String get timer => 'タイマー';

  @override
  String get repetition => '繰り返し';

  @override
  String get correctCount => '正解数';
}
