import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/database_helper.dart';
import '../models/flashcard.dart';
import '../../flavor_config.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Current Filter state
class FlashcardFilter {
  final String? subject;
  final String? category;
  final String? unit;

  FlashcardFilter({this.subject, this.category, this.unit});

  FlashcardFilter copyWith({String? subject, String? category, String? unit}) {
    return FlashcardFilter(
      subject: subject ?? this.subject,
      category: category ?? this.category,
      unit: unit ?? this.unit,
    );
  }
}

// Current selection state
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final selectedUnitProvider = StateProvider<String?>((ref) => null);
final selectedSubjectProvider = StateProvider<String?>((ref) => null);

// Flavor Guard state
final isCurrentSubjectLockedProvider = Provider<bool>((ref) {
  // Paid flavor gets everything unlocked
  if (FlavorConfig.instance.flavor != AppFlavor.free) return false;
  
  final subject = ref.watch(selectedSubjectProvider);
  if (subject == null) return false;

  final subjectsList = ref.watch(subjectsProvider).value;
  if (subjectsList == null) return false;

  final index = subjectsList.indexOf(subject);
  // Subjects from index 2 onwards are locked in the free flavor
  return index >= 2;
});

// Dynamic subjects provider (top-level navigation)
final subjectsProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  return await db.getDistinctSubjects();
});

// Keep old name as alias for backward compatibility in subject_screen.dart
final categoriesProvider = subjectsProvider;

// Dynamic categories provider based on selected subject (second filter level)
final availableCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final subject = ref.watch(selectedSubjectProvider);
  if (subject == null) return [];
  return await db.getDistinctCategories(subject);
});

// Dynamic units provider based on selected subject and category
final availableUnitsProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final subject = ref.watch(selectedSubjectProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (subject == null || category == null) return [];
  return await db.getDistinctUnits(subject, category);
});

// Flashcards provider based on selection
final filteredFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final category = ref.watch(selectedCategoryProvider);
  final unit = ref.watch(selectedUnitProvider);
  final subject = ref.watch(selectedSubjectProvider);
  
  if (subject == null) return [];

  return await db.getFilteredFlashcards(
    subject: subject,
    category: category,
    unit: unit,
  );
});


// Total count provider
final totalFlashcardsCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final cards = await db.getAllFlashcards();
  return cards.length;
});
