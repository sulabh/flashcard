import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:path/path.dart';
import '../models/flashcard.dart';
import 'db_platform_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final helper = DbPlatformHelper.instance;
    await helper.initialize();

    final dbPath = await helper.factory.getDatabasesPath();
    final path = join(dbPath, filePath);

    // Initial load from assets if database doesn't exist
    final exists = await helper.factory.databaseExists(path);
    if (!exists) {
      debugPrint('Database not found in local storage. Copying from assets...');
      await helper.copyFromAssets(path, join('assets', filePath));
    }

    return await helper.factory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1),
    );
  }


  Future<int> insertFlashcard(Flashcard card) async {
    final db = await instance.database;
    return await db.insert('flashcards', card.toMap());
  }

  Future<List<Flashcard>> getAllFlashcards() async {
    final db = await instance.database;
    final result = await db.query('flashcards');
    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<List<Flashcard>> getFilteredFlashcards({
    String? category,
    String? unit,
    int? ageGroup,
  }) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null) {
      whereClause += 'category = ?';
      whereArgs.add(category);
    }
    if (unit != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'unit = ?';
      whereArgs.add(unit);
    }
    if (ageGroup != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'ageGroup = ?';
      whereArgs.add(ageGroup);
    }

    final result = await db.query(
      'flashcards',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<int> updateFlashcardStats(String id, int repetitions, int correctCount) async {
    final db = await instance.database;
    return await db.update(
      'flashcards',
      {
        'repetitions': repetitions,
        'correctCount': correctCount,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getCategoryMasteryStats() async {
    final db = await instance.database;
    // Query to get sum of correctCount and repetitions per category
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT category, SUM(correctCount) as totalCorrect, SUM(repetitions) as totalReps
      FROM flashcards
      GROUP BY category
    ''');

    Map<String, double> stats = {};
    for (var row in result) {
      final category = row['category'] as String;
      final totalCorrect = row['totalCorrect'] as int? ?? 0;
      final totalReps = row['totalReps'] as int? ?? 0;
      
      // Calculate percentage, default to 0 if no reps yet
      final mastery = totalReps == 0 ? 0.0 : (totalCorrect / totalReps);
      stats[category] = mastery;
    }
    return stats;
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final db = await instance.database;
    final stats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN repetitions > 0 THEN 1 ELSE 0 END) as studied,
        SUM(CASE WHEN (repetitions > 0 AND (correctCount * 1.0 / repetitions) >= 0.7) THEN 1 ELSE 0 END) as mastered,
        SUM(correctCount) as totalCorrect,
        SUM(repetitions) as totalReps
      FROM flashcards
    ''');

    if (stats.isEmpty) return {'total': 0, 'studied': 0, 'mastered': 0, 'accuracy': 0.0};

    final row = stats.first;
    final totalReps = row['totalReps'] as int? ?? 0;
    final totalCorrect = row['totalCorrect'] as int? ?? 0;
    final accuracy = totalReps == 0 ? 0.0 : (totalCorrect / totalReps);

    return {
      'total': row['total'] as int? ?? 0,
      'studied': row['studied'] as int? ?? 0,
      'mastered': row['mastered'] as int? ?? 0,
      'accuracy': accuracy,
    };
  }

  Future close() async {

    final db = await instance.database;
    db.close();
  }
}
