import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/database_helper.dart';
import 'flashcard_provider.dart';

// Fetch all mastery stats at once
final masteryStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getCategoryMasteryStats();
});

// Helper provider to get mastery for a specific category
final categoryMasteryProvider = Provider.family<double, String>((ref, category) {
  final stats = ref.watch(masteryStatsProvider).value ?? {};
  return stats[category] ?? 0.0;
});
