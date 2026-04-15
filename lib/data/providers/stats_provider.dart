import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/database_helper.dart';
import '../../core/providers/core_providers.dart';
import 'flashcard_provider.dart';

final globalStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return await db.getGlobalStats();
});
