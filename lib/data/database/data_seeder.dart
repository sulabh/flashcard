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
        final ageGroup = i % 2 == 0 ? 5 : 6;

        final card = Flashcard(
          frontHtml: 'Question $i for $subject in $unit for Age $ageGroup',
          backHtml: 'Answer $i for $subject',
          category: subject,
          unit: unit,
          ageGroup: ageGroup,
          isMcq: isMcq,
          choices: isMcq
              ? [
                  'Answer $i for $subject',
                  'Wrong option ${i + 1}',
                  'Wrong option ${i + 2}',
                  'Wrong option ${i + 3}',
                  'Wrong option ${i + 4}',
                ]
              : const [],
        );

        batch.insert('flashcards', card.toMap());
      }
    }

    // Unicode/Japanese Compatibility Test Entry
    batch.insert('flashcards', Flashcard(
      frontHtml: '<ruby>日本語<rt>にほんご</rt></ruby> Test',
      backHtml: 'Japanese Language',
      category: 'Vocabulary',
      unit: 'first_half',
      ageGroup: 5,
    ).toMap());

    await batch.commit(noResult: true);

  }
}
