import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:path/path.dart';
import '../models/flashcard.dart';
import '../../core/utils/csv_helper.dart';
import 'db_platform_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database>? _initFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Ensure initialization only happens once
    _initFuture ??= _initDB('flashcards.db');
    _database = await _initFuture;
    
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final helper = DbPlatformHelper.instance;
    await helper.initialize();

    final dbPath = await helper.factory.getDatabasesPath();
    final path = join(dbPath, filePath);

    // Initial load from assets if database doesn't exist
    final exists = await helper.factory.databaseExists(path);
    bool isNew = !exists;

    final db = await helper.factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await _createDB(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            // Drop old table and recreate with new schema
            await db.execute('DROP TABLE IF EXISTS flashcards');
            await _createDB(db);
            // Repopulate with fresh 22-column data
            await _populateInitialData(db);
          }
        },
      ),
    );

    if (isNew) {
      debugPrint('Fresh database created. Populating from assets/initial_data.csv...');
      await _populateInitialData(db);
    }

    return db;
  }

  Future<void> _createDB(Database db) async {
    await db.execute('''
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL DEFAULT 1,
        subject TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT '',
        unit TEXT NOT NULL DEFAULT '',
        title TEXT NOT NULL DEFAULT '',
        problem TEXT NOT NULL DEFAULT '',
        answer TEXT NOT NULL DEFAULT '',
        correct_answer TEXT NOT NULL DEFAULT '',
        incorrect_answer_1 TEXT NOT NULL DEFAULT '',
        incorrect_answer_2 TEXT NOT NULL DEFAULT '',
        incorrect_answer_3 TEXT NOT NULL DEFAULT '',
        incorrect_answer_4 TEXT NOT NULL DEFAULT '',
        supplement_problem TEXT NOT NULL DEFAULT '',
        supplement_answer TEXT NOT NULL DEFAULT '',
        no_of_times_shown INTEGER DEFAULT 0,
        no_of_times_attempted INTEGER DEFAULT 0,
        completion_flag TEXT NOT NULL DEFAULT '',
        need_for_review TEXT NOT NULL DEFAULT '',
        note_1 TEXT NOT NULL DEFAULT '',
        note_2 TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _populateInitialData(Database db) async {
    try {
      final csvString = await rootBundle.loadString('assets/initial_data.csv');
      final cards = CsvHelper.importFromCsv(csvString);
      
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (var card in cards) {
          batch.insert('flashcards', card.toMap());
        }
        await batch.commit(noResult: true);
      });
      debugPrint('Successfully populated ${cards.length} cards.');
    } catch (e) {
      debugPrint('Error populating initial data: $e');
    }
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

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('flashcards');
  }

  Future<void> insertMultipleFlashcards(List<Flashcard> cards) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var card in cards) {
        batch.insert('flashcards', card.toMap());
      }
      await batch.commit(noResult: true);
    });
  }

  /// Returns distinct subjects (top-level navigation).
  Future<List<String>> getDistinctSubjects() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT DISTINCT subject FROM flashcards ORDER BY subject ASC');
    return result.map((json) => json['subject'] as String).toList();
  }

  /// Returns distinct categories for a given subject (second filter level, previously "ageGroup").
  Future<List<String>> getDistinctCategories(String subject) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM flashcards WHERE subject = ? ORDER BY category ASC',
      [subject]
    );
    return result.map((json) => json['category'] as String).toList();
  }

  /// Returns distinct units for a given subject + category.
  Future<List<String>> getDistinctUnits(String subject, String category) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT unit FROM flashcards WHERE subject = ? AND category = ? ORDER BY unit ASC',
      [subject, category]
    );
    return result.map((json) => json['unit'] as String).toList();
  }

  Future<List<Flashcard>> getFilteredFlashcards({
    String? subject,
    String? category,
    String? unit,
  }) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (subject != null) {
      whereClause += 'subject = ?';
      whereArgs.add(subject);
    }
    if (category != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category = ?';
      whereArgs.add(category);
    }
    if (unit != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'unit = ?';
      whereArgs.add(unit);
    }

    final result = await db.query(
      'flashcards',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    return result.map((json) => Flashcard.fromMap(json)).toList();
  }

  Future<int> updateFlashcardStats(String id, int noOfTimesShown, int noOfTimesAttempted) async {
    final db = await instance.database;
    return await db.update(
      'flashcards',
      {
        'no_of_times_shown': noOfTimesShown,
        'no_of_times_attempted': noOfTimesAttempted,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mastery stats grouped by subject (top-level).
  Future<Map<String, double>> getSubjectMasteryStats() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT subject, SUM(no_of_times_attempted) as totalCorrect, SUM(no_of_times_shown) as totalReps
      FROM flashcards
      GROUP BY subject
    ''');

    Map<String, double> stats = {};
    for (var row in result) {
      final subject = row['subject'] as String;
      final totalCorrect = row['totalCorrect'] as int? ?? 0;
      final totalReps = row['totalReps'] as int? ?? 0;
      
      // Calculate percentage, default to 0 if no reps yet
      final mastery = totalReps == 0 ? 0.0 : (totalCorrect / totalReps);
      stats[subject] = mastery;
    }
    return stats;
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final db = await instance.database;
    final stats = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN no_of_times_shown > 0 THEN 1 ELSE 0 END) as studied,
        SUM(CASE WHEN (no_of_times_shown > 0 AND (no_of_times_attempted * 1.0 / no_of_times_shown) >= 0.7) THEN 1 ELSE 0 END) as mastered,
        SUM(no_of_times_attempted) as totalCorrect,
        SUM(no_of_times_shown) as totalReps
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
