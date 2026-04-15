import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flashcard_app/data/database/data_seeder.dart';
import 'package:flashcard_app/data/models/flashcard.dart';
import 'package:path/path.dart';

void main() async {
  // Initialize FFI for CLI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const dbName = 'flashcards.db';
  print('--- CLI Seeding Started ---');
  
  final dbPath = join(Directory.current.path, 'assets', dbName);
  print('Target DB path: $dbPath');


  final file = File(dbPath);
  if (await file.exists()) {
    print('Deleting existing database file...');
    await file.delete();
  }

  final db = await openDatabase(
    dbPath,
    version: 1,
    onCreate: (db, version) async {
      print('Creating schema...');
      await db.execute('''
        CREATE TABLE flashcards (
          id TEXT PRIMARY KEY,
          frontHtml TEXT NOT NULL,
          backHtml TEXT NOT NULL,
          category TEXT NOT NULL,
          unit TEXT NOT NULL,
          ageGroup INTEGER NOT NULL,
          repetitions INTEGER NOT NULL,
          correctCount INTEGER NOT NULL,
          isMcq INTEGER NOT NULL,
          choices TEXT
        )
      ''');
    },
  );

  print('Generating 5000+ cards...');
  final stopwatch = Stopwatch()..start();
  await DataSeeder.seedDatabase(db);
  stopwatch.stop();
  print('Seeding completed in ${stopwatch.elapsedMilliseconds}ms');

  final result = await db.rawQuery('SELECT COUNT(*) FROM flashcards');
  final count = result.first.values.first;
  print('Verification: Total flashcards in database: $count');

  await db.close();
  print('--- CLI Seeding Test Finished ---');
}
