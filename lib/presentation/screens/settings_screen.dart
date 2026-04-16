import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/file_saver.dart';
import '../../data/providers/settings_provider.dart';
import '../../core/utils/csv_helper.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../data/providers/stats_provider.dart';
import '../../data/providers/progress_provider.dart';
import '../../core/providers/core_providers.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionSize = ref.watch(sessionSizeProvider);
    final sessionTimer = ref.watch(sessionTimerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            _SectionHeader(title: l10n.studySession),
            
            // Slider for Session Size
            ListTile(
              title: Text(l10n.cardsPerSet),
              subtitle: Text(l10n.cardsPerSession(sessionSize)),
              trailing: Text('$sessionSize', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Slider(
                value: sessionSize.toDouble(),
                min: 10,
                max: 40,
                divisions: 6, // 10, 15, 20, 25, 30, 35, 40
                label: sessionSize.toString(),
                onChanged: (value) => ref.read(sessionSizeProvider.notifier).setSessionSize(value.toInt()),
              ),
            ),
            
            const Divider(),
  
            // Timer Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.sessionTimer, style: Theme.of(context).textTheme.titleMedium),
                  Text(l10n.autoFinish, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: sessionTimer,
                    isExpanded: true,
                    underline: Container(height: 1, color: Theme.of(context).dividerColor),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(l10n.noTimer)),
                      DropdownMenuItem(value: 5, child: Text(l10n.minutesFull(5))),
                      DropdownMenuItem(value: 10, child: Text(l10n.minutesFull(10))),
                      DropdownMenuItem(value: 30, child: Text(l10n.minutesFull(30))),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(sessionTimerProvider.notifier).setSessionTimer(value);
                      }
                    },
                  ),
                ],
              ),
            ),
  
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.themeMode),
  
            // Fixed Theme Selection: Using vertical layout for better mobile responsiveness
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        themeMode == ThemeMode.light ? Icons.light_mode : 
                        themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.settings_brightness,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.themeMode, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<ThemeMode>(
                    value: themeMode,
                    isExpanded: true,
                    underline: Container(height: 1, color: Theme.of(context).dividerColor),
                    items: [
                      DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.light)),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
                      DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.system)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).state = value;
                      }
                    },
                  ),
                ],
              ),
            ),
  
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.dataManagement),
  
            // Export CSV
            ListTile(
              leading: const Icon(Icons.file_upload_rounded, color: Colors.blue),
              title: Text(l10n.exportCsv),
              onTap: () => _handleExport(context, ref, l10n),
            ),
  
            // Download Sample CSV
            ListTile(
              leading: const Icon(Icons.help_outline_rounded, color: Colors.orange),
              title: Text(l10n.downloadSample),
              onTap: () => _handleDownloadSample(context, ref, l10n),
            ),
  
            // Import CSV
            ListTile(
              leading: const Icon(Icons.file_download_rounded, color: Colors.green),
              title: Text(l10n.importCsv),
              onTap: () => _handleImport(context, ref, l10n),
            ),
  
            // Clear Database
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: Text(l10n.clearDatabase),
              onTap: () => _handleClear(context, ref, l10n),
            ),
  
            const SizedBox(height: 48),
            Center(
              child: Text(
                l10n.appVersion,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final db = ref.read(databaseHelperProvider);
    final cards = await db.getAllFlashcards();
    
    final csvString = CsvHelper.exportToCsv(cards);
    
    await FileSaver.saveAndShare(
      fileName: 'flashcards_export.csv',
      content: csvString,
    );
  }

  Future<void> _handleDownloadSample(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final csvString = await CsvHelper.getSampleCsvFromAssets();
    await FileSaver.saveAndShare(
      fileName: 'ruby_study_sample.csv',
      content: csvString,
    );
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true, // Required for Web to get bytes
    );

    if (result != null) {
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      
      final content = const Utf8Decoder().convert(bytes);
      final cards = CsvHelper.importFromCsv(content);

      if (cards.isNotEmpty) {
        final db = ref.read(databaseHelperProvider);
        await db.insertMultipleFlashcards(cards);
        
        // Invalidate all related providers to force UI refresh
        ref.invalidate(totalFlashcardsCountProvider);
        ref.invalidate(globalStatsProvider);
        ref.invalidate(masteryStatsProvider);
        ref.invalidate(filteredFlashcardsProvider);
        ref.invalidate(categoriesProvider); // Force Subject Screen to reload dynamic subjects
        ref.invalidate(selectedSubjectProvider); // Clear selection if any

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.importedSuccess(cards.length))),
          );
        }
      }
    }
  }

  Future<void> _handleClear(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearDatabase),
        content: Text(l10n.clearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseHelperProvider);
      await db.clearAllData();
      
      // Invalidate all related providers to force UI refresh
      ref.invalidate(totalFlashcardsCountProvider);
      ref.invalidate(globalStatsProvider);
      ref.invalidate(masteryStatsProvider);
      ref.invalidate(filteredFlashcardsProvider);
      ref.invalidate(categoriesProvider); // Force Subject Screen to reload dynamic subjects
      ref.invalidate(selectedSubjectProvider); // Clear selection on wipe

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dbClearedSuccess)),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
