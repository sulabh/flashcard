import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../../data/models/flashcard.dart';

class CsvHelper {
  static const List<String> header = [
    'id',
    'frontHtml',
    'backHtml',
    'category',
    'unit',
    'ageGroup',
    'isMcq',
    'choices'
  ];

  static String exportToCsv(List<Flashcard> cards) {
    List<List<dynamic>> rows = [header];

    for (var card in cards) {
      rows.add([
        card.id,
        card.frontHtml,
        card.backHtml,
        card.category,
        card.unit,
        card.ageGroup,
        card.isMcq ? 1 : 0,
        jsonEncode(card.choices),
      ]);
    }

    // In csv 8.0.0+, use CsvEncoder
    return const CsvEncoder().convert(rows);
  }

  static List<Flashcard> importFromCsv(String csvString) {
    // In csv 8.0.0+, use CsvDecoder
    List<List<dynamic>> rows = const CsvDecoder().convert(csvString);
    if (rows.isEmpty) return [];

    // Identify header and data rows
    int startIndex = 0;
    if (rows.isNotEmpty && (rows.first.contains('frontHtml') || rows.first.contains('category'))) {
      startIndex = 1;
    }

    List<Flashcard> cards = [];
    for (int i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      try {
        final id = row[0].toString();
        final frontHtml = row[1].toString();
        final backHtml = row[2].toString();
        final category = row[3].toString();
        final unit = row[4].toString();
        final ageGroup = int.tryParse(row[5].toString()) ?? 5;
        final isMcq = (row.length > 6 && row[6].toString() == '1');
        final choicesStr = (row.length > 7) ? row[7].toString() : '[]';
        final List<String> choices = List<String>.from(jsonDecode(choicesStr));

        cards.add(Flashcard(
          id: id.isNotEmpty ? id : null,
          frontHtml: frontHtml,
          backHtml: backHtml,
          category: category,
          unit: unit,
          ageGroup: ageGroup,
          isMcq: isMcq,
          choices: choices,
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
    
    // Add some sample cards
    rows.add([
      '', 
      'How do you read _{漢字}_(_かんじ_)?', 
      'Kanji', 
      'Kanji', 
      'Unit 1', 
      '7', 
      0, 
      '[]'
    ]);
    
    rows.add([
      '', 
      'What is |1/2| + |1/4|?', 
      '|3/4|', 
      'Arithmetic', 
      'Unit 1', 
      '7', 
      1, 
      '["|3/4|", "|1/2|", "|1/4|", "|1/8|"]'
    ]);

    rows.add([
      '', 
      'Translate: _{猫}_(_ねこ_)', 
      'Cat', 
      'Vocabulary', 
      'Unit 2', 
      '5', 
      0, 
      '[]'
    ]);

    return const CsvEncoder().convert(rows);
  }
}
