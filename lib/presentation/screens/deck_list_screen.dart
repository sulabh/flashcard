import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../l10n/app_localizations.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(filteredFlashcardsProvider);
    final subject = ref.watch(selectedSubjectProvider);
    final age = ref.watch(selectedAgeGroupProvider);
    final unit = ref.watch(selectedUnitProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('$subject (Age $age, ${unit == 'first_half' ? 'Unit 1' : 'Unit 2'})'),
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('No cards found for this selection.'));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.library_books, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                Text('${cards.length} Flashcards Available', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(l10n.randomSetMessage, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => context.push('/study'),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.startPractice, style: const TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}


