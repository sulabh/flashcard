import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../../data/models/flashcard.dart';

class CsvHelper {
  static const List<String> header = [
    'id',
    'type',
    'subject',
    'category',
    'unit',
    'title',
    'problem',
    'answer',
    'correct_answer',
    'incorrect_answer_1',
    'incorrect_answer_2',
    'incorrect_answer_3',
    'incorrect_answer_4',
    'supplement_problem',
    'supplement_answer',
    'no_of_times_shown',
    'no_of_times_attempted',
    'completion_flag',
    'need_for_review',
    'note_1',
    'note_2',
  ];

  static String exportToCsv(List<Flashcard> cards) {
    List<List<dynamic>> rows = [header];

    for (var card in cards) {
      rows.add([
        card.id,
        card.type,
        card.subject,
        card.category,
        card.unit,
        card.title,
        card.problem,
        card.answer,
        card.correctAnswer,
        card.incorrectAnswer1,
        card.incorrectAnswer2,
        card.incorrectAnswer3,
        card.incorrectAnswer4,
        card.supplementProblem,
        card.supplementAnswer,
        card.noOfTimesShown,
        card.noOfTimesAttempted,
        card.completionFlag,
        card.needForReview,
        card.note1,
        card.note2,
      ]);
    }

    return const CsvEncoder().convert(rows);
  }

  static List<Flashcard> importFromCsv(String csvString) {
    List<List<dynamic>> rows = const CsvDecoder().convert(csvString);
    if (rows.isEmpty) return [];

    // Detect header row
    int startIndex = 0;
    if (rows.isNotEmpty && (rows.first.contains('id') || rows.first.contains('subject') || rows.first.contains('type'))) {
      startIndex = 1;
    }

    List<Flashcard> cards = [];
    for (int i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue; // Minimum: id, type, subject, category, unit

      try {
        String getString(int index) => (index < row.length) ? row[index].toString() : '';
        int getInt(int index) => (index < row.length) ? (int.tryParse(row[index].toString()) ?? 0) : 0;

        cards.add(Flashcard(
          id: getString(0).isNotEmpty ? getString(0) : null,
          type: getInt(1) == 0 ? 1 : getInt(1), // Default to 1 (normal) if 0 or missing
          subject: getString(2),
          category: getString(3),
          unit: getString(4),
          title: getString(5),
          problem: getString(6),
          answer: getString(7),
          correctAnswer: getString(8),
          incorrectAnswer1: getString(9),
          incorrectAnswer2: getString(10),
          incorrectAnswer3: getString(11),
          incorrectAnswer4: getString(12),
          supplementProblem: getString(13),
          supplementAnswer: getString(14),
          noOfTimesShown: getInt(15),
          noOfTimesAttempted: getInt(16),
          completionFlag: getString(17),
          needForReview: getString(18),
          note1: getString(19),
          note2: getString(20),
        ));
      } catch (e) {
        continue;
      }
    }

    return cards;
  }

  static Future<String> getSampleCsvFromAssets() async {
    try {
      return await rootBundle.loadString('assets/initial_data.csv');
    } catch (e) {
      // Fallback to minimal sample if asset fails
      return generateSampleCsv();
    }
  }

  static String generateSampleCsv() {
    List<List<dynamic>> rows = [header];
    
    // Normal flashcard sample
    rows.add([
      '', // id (auto-generated)
      1,  // type (normal)
      'Kanji', // subject
      'Grade 1', // category
      'Unit 1', // unit
      '_{漢字}_(_かんじ_)', // title
      'How do you read this?', // problem
      'Kanji', // answer
      '', // correct_answer (not MCQ)
      '', '', '', '', // incorrect_answers
      'This is a basic kanji character', // supplement_problem
      'Chinese characters used in Japanese', // supplement_answer
      0, 0, '', '', '', '', // tracking fields and 2 notes
    ]);
    
    // MCQ sample
    rows.add([
      '', // id
      2,  // type (MCQ)
      'Arithmetic', // subject
      'Grade 2', // category
      'Unit 1', // unit
      'Addition', // title
      'What is |1/2| + |1/4|?', // problem
      '|3/4|', // answer
      '|3/4|', // correct_answer
      '|1/2|', '|1/4|', '|1/8|', '|2/3|', // incorrect_answers
      '', '', // supplements
      0, 0, '', '', '', '',
    ]);

    return const CsvEncoder().convert(rows);
  }
}
