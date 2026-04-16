import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/database_helper.dart';
import '../models/flashcard.dart';
import '../../flavor_config.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Current Filter state
class FlashcardFilter {
  final String? category;
  final String? unit;
  final int? ageGroup;

  FlashcardFilter({this.category, this.unit, this.ageGroup});

  FlashcardFilter copyWith({String? category, String? unit, int? ageGroup}) {
    return FlashcardFilter(
      category: category ?? this.category,
      unit: unit ?? this.unit,
      ageGroup: ageGroup ?? this.ageGroup,
    );
  }
}

// Current selection state
final selectedAgeGroupProvider = StateProvider<int?>((ref) => null);
final selectedUnitProvider = StateProvider<String?>((ref) => null);
final selectedSubjectProvider = StateProvider<String?>((ref) => null);

// Flavor Guard state
final isCurrentSubjectLockedProvider = Provider<bool>((ref) {
  // Paid flavor gets everything unlocked
  if (FlavorConfig.instance.flavor != AppFlavor.free) return false;
  
  final subject = ref.watch(selectedSubjectProvider);
  if (subject == null) return false;

  final categoriesList = ref.watch(categoriesProvider).value;
  if (categoriesList == null) return false;

  final index = categoriesList.indexOf(subject);
  // Subjects from index 2 onwards are locked in the free flavor
  return index >= 2;
});

// Dynamic categories provider
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  return await db.getDistinctCategories();
});

// Dynamic age groups provider based on selected subject
final availableAgeGroupsProvider = FutureProvider<List<int>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final subject = ref.watch(selectedSubjectProvider);
  if (subject == null) return [];
  return await db.getDistinctAgeGroups(subject);
});

// Dynamic units provider based on selected subject and age group
final availableUnitsProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final subject = ref.watch(selectedSubjectProvider);
  final ageGroup = ref.watch(selectedAgeGroupProvider);
  if (subject == null || ageGroup == null) return [];
  return await db.getDistinctUnits(subject, ageGroup);
});

// Flashcards provider based on selection
final filteredFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final ageGroup = ref.watch(selectedAgeGroupProvider);
  final unit = ref.watch(selectedUnitProvider);
  final subject = ref.watch(selectedSubjectProvider);
  
  if (subject == null || ageGroup == null || unit == null) return [];

  return await db.getFilteredFlashcards(
    category: subject,
    unit: unit,
    ageGroup: ageGroup,
  );
});


// Total count provider
final totalFlashcardsCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final cards = await db.getAllFlashcards();
  return cards.length;
});
