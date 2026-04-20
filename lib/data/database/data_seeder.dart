import 'package:sqflite_common/sqlite_api.dart';

import '../models/flashcard.dart';

class DataSeeder {
  static const List<String> subjects = [
    'Kanji',
    'Arithmetic',
    'English',
    'Vocabulary',
    'General Knowledge'
  ];

  static Future<void> seedDatabase(Database db) async {
    final batch = db.batch();

    for (var subject in subjects) {
      for (int i = 1; i <= 1000; i++) {
        final isMcq = i % 2 == 0; // Alternating Classic and MCQ for variety
        final unit = i <= 500 ? 'first_half' : 'second_half';
        final categoryStr = i % 2 == 0 ? 'Grade 1' : 'Grade 2';

        final card = Flashcard(
          type: isMcq ? 2 : 1,
          subject: subject,
          category: categoryStr,
          unit: unit,
          title: 'Question $i for $subject',
          problem: 'Problem details for $subject in $unit',
          answer: 'Answer $i for $subject',
          correctAnswer: isMcq ? 'Answer $i for $subject' : '',
          incorrectAnswer1: isMcq ? 'Wrong option ${i + 1}' : '',
          incorrectAnswer2: isMcq ? 'Wrong option ${i + 2}' : '',
          incorrectAnswer3: isMcq ? 'Wrong option ${i + 3}' : '',
          incorrectAnswer4: isMcq ? 'Wrong option ${i + 4}' : '',
        );

        batch.insert('flashcards', card.toMap());
      }
    }

    // Unicode/Japanese Compatibility Test Entry
    batch.insert('flashcards', Flashcard(
      type: 1,
      subject: 'Vocabulary',
      category: 'Grade 1',
      unit: 'first_half',
      title: '<ruby>日本語<rt>にほんご</rt></ruby> Test',
      problem: 'What does this mean?',
      answer: 'Japanese Language',
    ).toMap());

    await batch.commit(noResult: true);

  }
}
