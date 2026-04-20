import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_flashcard_html.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(filteredFlashcardsProvider);
    final subject = ref.watch(selectedSubjectProvider);
    final category = ref.watch(selectedCategoryProvider);
    final unit = ref.watch(selectedUnitProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    String localizeUnit(String? u) {
      if (u == 'first_half') return l10n.firstHalf;
      if (u == 'second_half') return l10n.secondHalf;
      return u ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${subject ?? ''}'),
            if (category != null || unit != null)
              Text(
                '${category ?? ''}${category != null && unit != null ? ', ' : ''}${localizeUnit(unit)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(160),
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return Center(child: Text(l10n.noCardsFound));
          }
          return Column(
            children: [
              // Summary Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.library_books_rounded, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.flashcardsAvailable(cards.length),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/study'),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: Text(l10n.startPractice),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Card List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: theme.colorScheme.primary.withAlpha(50),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        title: AppFlashcardHtml(
                          data: card.displayFront,
                        ),
                        children: [
                          const Divider(height: 1),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: theme.colorScheme.surfaceVariant.withAlpha(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.answer,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AppFlashcardHtml(
                                  data: card.displayBack,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.errorLoading(err.toString()))),
      ),
    );
  }
}
