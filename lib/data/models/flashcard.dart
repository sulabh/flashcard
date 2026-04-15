import 'dart:convert';
import 'package:uuid/uuid.dart';

enum FlashcardUnit { firstHalf, secondHalf }

class Flashcard {
  final String id;
  final String frontHtml;
  final String backHtml;
  final String category;
  final String unit; // 'first_half' or 'second_half'
  final int ageGroup; // 5 or 6
  final int repetitions;
  final int correctCount;
  final bool isMcq;
  final List<String> choices;

  Flashcard({
    String? id,
    required this.frontHtml,
    required this.backHtml,
    required this.category,
    required this.unit,
    required this.ageGroup,
    this.repetitions = 0,
    this.correctCount = 0,
    this.isMcq = false,
    this.choices = const [],
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'frontHtml': frontHtml,
      'backHtml': backHtml,
      'category': category,
      'unit': unit,
      'ageGroup': ageGroup,
      'repetitions': repetitions,
      'correctCount': correctCount,
      'isMcq': isMcq ? 1 : 0,
      'choices': jsonEncode(choices),
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      frontHtml: map['frontHtml'],
      backHtml: map['backHtml'],
      category: map['category'],
      unit: map['unit'],
      ageGroup: map['ageGroup'],
      repetitions: map['repetitions'],
      correctCount: map['correctCount'],
      isMcq: (map['isMcq'] ?? 0) == 1,
      choices: List<String>.from(jsonDecode(map['choices'] ?? '[]')),
    );
  }
}
