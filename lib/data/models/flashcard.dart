import 'package:uuid/uuid.dart';

class Flashcard {
  final String id;
  final int type; // 1 = normal flashcard, 2 = MCQ
  final String subject; // previously "category"
  final String category; // previously "ageGroup" (now a string)
  final String unit;
  final String title; // Question's main title
  final String problem; // Question's actual problem
  final String answer; // Flashcard answer
  final String correctAnswer; // MCQ correct answer
  final String incorrectAnswer1;
  final String incorrectAnswer2;
  final String incorrectAnswer3;
  final String incorrectAnswer4;
  final String supplementProblem; // Subtext to problem
  final String supplementAnswer; // Subtext to answer
  final int noOfTimesShown;
  final int noOfTimesAttempted;
  final String completionFlag;
  final String needForReview;
  final String note1;
  final String note2;

  Flashcard({
    String? id,
    this.type = 1,
    required this.subject,
    required this.category,
    required this.unit,
    this.title = '',
    this.problem = '',
    this.answer = '',
    this.correctAnswer = '',
    this.incorrectAnswer1 = '',
    this.incorrectAnswer2 = '',
    this.incorrectAnswer3 = '',
    this.incorrectAnswer4 = '',
    this.supplementProblem = '',
    this.supplementAnswer = '',
    this.noOfTimesShown = 0,
    this.noOfTimesAttempted = 0,
    this.completionFlag = '',
    this.needForReview = '',
    this.note1 = '',
    this.note2 = '',
  }) : id = id ?? const Uuid().v4();

  // Convenience getters
  bool get isMcq => type == 2;

  /// Builds the shuffled list of MCQ choices from correct + incorrect answers.
  List<String> get mcqChoices {
    final choices = <String>[];
    if (correctAnswer.isNotEmpty) choices.add(correctAnswer);
    if (incorrectAnswer1.isNotEmpty) choices.add(incorrectAnswer1);
    if (incorrectAnswer2.isNotEmpty) choices.add(incorrectAnswer2);
    if (incorrectAnswer3.isNotEmpty) choices.add(incorrectAnswer3);
    if (incorrectAnswer4.isNotEmpty) choices.add(incorrectAnswer4);
    return choices;
  }

  /// Combines title + problem + supplement for the card front display.
  String get displayFront {
    final parts = <String>[];
    if (title.isNotEmpty) parts.add(title);
    if (problem.isNotEmpty) parts.add(problem);
    if (supplementProblem.isNotEmpty) parts.add('<span class="supplement">$supplementProblem</span>');
    return parts.join('<br/>');
  }

  /// Combines answer + supplement for the card back display.
  String get displayBack {
    final parts = <String>[];
    if (answer.isNotEmpty) parts.add(answer);
    if (supplementAnswer.isNotEmpty) parts.add('<span class="supplement">$supplementAnswer</span>');
    return parts.join('<br/>');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'subject': subject,
      'category': category,
      'unit': unit,
      'title': title,
      'problem': problem,
      'answer': answer,
      'correct_answer': correctAnswer,
      'incorrect_answer_1': incorrectAnswer1,
      'incorrect_answer_2': incorrectAnswer2,
      'incorrect_answer_3': incorrectAnswer3,
      'incorrect_answer_4': incorrectAnswer4,
      'supplement_problem': supplementProblem,
      'supplement_answer': supplementAnswer,
      'no_of_times_shown': noOfTimesShown,
      'no_of_times_attempted': noOfTimesAttempted,
      'completion_flag': completionFlag,
      'need_for_review': needForReview,
      'note_1': note1,
      'note_2': note2,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String?,
      type: (map['type'] as int?) ?? 1,
      subject: (map['subject'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      unit: (map['unit'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      problem: (map['problem'] as String?) ?? '',
      answer: (map['answer'] as String?) ?? '',
      correctAnswer: (map['correct_answer'] as String?) ?? '',
      incorrectAnswer1: (map['incorrect_answer_1'] as String?) ?? '',
      incorrectAnswer2: (map['incorrect_answer_2'] as String?) ?? '',
      incorrectAnswer3: (map['incorrect_answer_3'] as String?) ?? '',
      incorrectAnswer4: (map['incorrect_answer_4'] as String?) ?? '',
      supplementProblem: (map['supplement_problem'] as String?) ?? '',
      supplementAnswer: (map['supplement_answer'] as String?) ?? '',
      noOfTimesShown: (map['no_of_times_shown'] as int?) ?? 0,
      noOfTimesAttempted: (map['no_of_times_attempted'] as int?) ?? 0,
      completionFlag: (map['completion_flag'] as String?) ?? '',
      needForReview: (map['need_for_review'] as String?) ?? '',
      note1: (map['note_1'] as String?) ?? '',
      note2: (map['note_2'] as String?) ?? '',
    );
  }
}
