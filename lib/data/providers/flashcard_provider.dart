import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/database_helper.dart';
import '../models/flashcard.dart';

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
final selectedAgeGroupProvider = StateProvider<int>((ref) => 5);
final selectedUnitProvider = StateProvider<String>((ref) => 'first_half');
final selectedSubjectProvider = StateProvider<String?>((ref) => null);

// Flashcards provider based on selection
final filteredFlashcardsProvider = FutureProvider<List<Flashcard>>((ref) async {
  final db = ref.watch(databaseHelperProvider);
  final ageGroup = ref.watch(selectedAgeGroupProvider);
  final unit = ref.watch(selectedUnitProvider);
  final subject = ref.watch(selectedSubjectProvider);
  
  if (subject == null) return [];

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
