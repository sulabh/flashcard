import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../l10n/app_localizations.dart';

class SelectionScreen extends ConsumerWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAge = ref.watch(selectedAgeGroupProvider);
    final selectedUnit = ref.watch(selectedUnitProvider);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupSession),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(l10n.ageGroup),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildOptionCard(
                    context: context,
                    label: 'Age 5',
                    isSelected: selectedAge == 5,
                    onTap: () => ref.read(selectedAgeGroupProvider.notifier).state = 5,
                  ),
                  const SizedBox(width: 16),
                  _buildOptionCard(
                    context: context,
                    label: 'Age 6',
                    isSelected: selectedAge == 6,
                    onTap: () => ref.read(selectedAgeGroupProvider.notifier).state = 6,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(l10n.unit),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildOptionCard(
                    context: context,
                    label: 'First Half',
                    isSelected: selectedUnit == 'first_half',
                    onTap: () => ref.read(selectedUnitProvider.notifier).state = 'first_half',
                  ),
                  const SizedBox(width: 16),
                  _buildOptionCard(
                    context: context,
                    label: 'Second Half',
                    isSelected: selectedUnit == 'second_half',
                    onTap: () => ref.read(selectedUnitProvider.notifier).state = 'second_half',
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/subjects'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.nextChooseSubject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 32),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
