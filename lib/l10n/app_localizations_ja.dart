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

  @override
  String get greeting => 'こんにちは！';

  @override
  String get yourLearning => 'あなたの学習';

  @override
  String get overallMastery => '総合マスタリー';

  @override
  String cardsMastered(int mastered, int total) {
    return '$mastered / $total カードマスター済み';
  }

  @override
  String get startPractice => '練習を始める';

  @override
  String get startPracticeSubtitle => 'パーソナライズされたカードプールに戻りましょう。';

  @override
  String get subjects => '科目';

  @override
  String get subjectsSubtitle => 'カテゴリとユニットでカードを閲覧。';

  @override
  String get settingsSubtitle => 'カスタマイズ、外観、データ。';

  @override
  String get studySession => '学習セッション';

  @override
  String get retryPhase => 'リトライフェーズ';

  @override
  String get retrying => 'リトライ中';

  @override
  String get endQuiz => 'クイズ終了';

  @override
  String get shuffle => 'シャッフル';

  @override
  String get skip => 'スキップ';

  @override
  String get tapToReveal => 'カードをタップして答えを表示';

  @override
  String get chooseCorrect => '正しい答えを選んでください';

  @override
  String get howWasIt => 'どうでしたか？';

  @override
  String get hard => '難しい';

  @override
  String get normal => '普通';

  @override
  String get easy => '簡単';

  @override
  String get answer => '解答';

  @override
  String get sessionComplete => 'セッション完了！';

  @override
  String get greatJob => 'よくできました！結果を見てみましょう。';

  @override
  String get accuracy => '正確さ';

  @override
  String get sessionAccuracy => 'セッション正確さ';

  @override
  String get cardsStudied => '学習カード数';

  @override
  String get correctAnswers => '正解数';

  @override
  String get globalMasteryGained => 'グローバルマスタリー変化';

  @override
  String get cardsPerSet => '1セットのカード数';

  @override
  String cardsPerSession(int count) {
    return '1回の練習に$count枚のカード';
  }

  @override
  String get sessionTimer => 'セッションタイマー';

  @override
  String get autoFinish => 'タイマー終了でセッション自動終了';

  @override
  String get noTimer => 'タイマーなし';

  @override
  String minutes(int count) {
    return '$count分';
  }

  @override
  String minutesFull(int count) {
    return '$count分';
  }

  @override
  String get themeMode => 'テーマモード';

  @override
  String get system => 'システム';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get stats => '統計';

  @override
  String get globalStats => 'グローバル統計';

  @override
  String get totalCards => '合計カード数';

  @override
  String get mastered => 'マスター済み';

  @override
  String get accuracy_label => '正確さ';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get setupSession => 'セッション設定';

  @override
  String get nextChooseSubject => '次へ：科目を選択';

  @override
  String get chooseSubject => '科目を選択';

  @override
  String get noSubjectData => 'まだ科目データがありません。練習を始めましょう！';

  @override
  String get randomSetMessage => 'ランダムな20問が用意されます。';

  @override
  String get appVersion => 'アプリバージョン 1.0.0';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get importCsv => 'CSVインポート';

  @override
  String get exportCsv => 'CSVエクスポート';

  @override
  String get clearDatabase => 'データベースをクリア';

  @override
  String get dbClearedSuccess => 'データベースがクリアされました';

  @override
  String importedSuccess(int count) {
    return '$count枚のカードをインポートしました';
  }

  @override
  String get exportedSuccess => 'エクスポートに成功しました';

  @override
  String get clearConfirm => 'すべてのデータを削除してもよろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get clear => '削除';

  @override
  String get downloadSample => 'サンプルCSVをダウンロード';
}
