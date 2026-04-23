import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../l10n/app_localizations.dart';

class SelectionScreen extends ConsumerWidget {
  final String mode;
  const SelectionScreen({super.key, this.mode = 'study'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedUnit = ref.watch(selectedUnitProvider);
    final categoriesAsync = ref.watch(availableCategoriesProvider);
    final unitsAsync = ref.watch(availableUnitsProvider);

    final l10n = AppLocalizations.of(context)!;
    
    // Attempt localizing common units and categories
    String localizeOption(String value) {
      if (value == ALL_VALUE) return l10n.all;
      if (value == 'first_half') return l10n.firstHalf;
      if (value == 'second_half') return l10n.secondHalf;
      return value;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupSession),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(l10n.categoryLabel),
                    const SizedBox(height: 12),
                    categoriesAsync.when(
                      data: (categories) {
                        if (categories.isEmpty) return const Text('No categories available');
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: categories.map((cat) {
                            return _buildOptionCard(
                              context: context,
                              label: localizeOption(cat),
                              isSelected: selectedCategory == cat,
                              onTap: () {
                                ref.read(selectedCategoryProvider.notifier).state = cat;
                                // If "All" categories, also default to "All" units
                                ref.read(selectedUnitProvider.notifier).state = (cat == ALL_VALUE) ? ALL_VALUE : null;
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(l10n.unit),
                    const SizedBox(height: 12),
                    if (selectedCategory == null)
                      Text(l10n.selectCategoryFirst, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                    else
                      unitsAsync.when(
                        data: (units) {
                          if (units.isEmpty) return const Text('No units available');
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: units.map((unit) {
                              return _buildOptionCard(
                                context: context,
                                label: localizeOption(unit),
                                isSelected: selectedUnit == unit,
                                onTap: () => ref.read(selectedUnitProvider.notifier).state = unit,
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ElevatedButton(
                onPressed: (selectedCategory != null && selectedUnit != null) 
                    ? () => context.push(mode == 'maintenance' ? '/deck' : '/study')
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  mode == 'maintenance' ? l10n.viewCards : l10n.startPractice,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140, // Fixed width to replace Expanded in Wrap
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: theme.colorScheme.primary.withAlpha(80), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}
