import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/database_helper.dart';
import 'flashcard_provider.dart';

// Fetch all mastery stats at once (grouped by subject)
final masteryStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getSubjectMasteryStats();
});

// Helper provider to get mastery for a specific subject
final subjectMasteryProvider = Provider.family<double, String>((ref, subject) {
  final stats = ref.watch(masteryStatsProvider).value ?? {};
  return stats[subject] ?? 0.0;
});

// Keep old name as alias for backward compatibility
final categoryMasteryProvider = subjectMasteryProvider;
