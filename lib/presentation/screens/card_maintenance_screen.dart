import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../core/utils/csv_helper.dart';
import '../../core/utils/file_saver.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../data/providers/stats_provider.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/database/database_helper.dart';
import '../../l10n/app_localizations.dart';

class CardMaintenanceScreen extends ConsumerWidget {
  const CardMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cardMaintenance),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.dataManagement),
            _buildMaintenanceCard(
              context,
              title: l10n.importCsv,
              icon: Icons.file_download_rounded,
              color: Colors.green,
              onTap: () => _handleImport(context, ref, l10n),
            ),
            const SizedBox(height: 16),
            _buildMaintenanceCard(
              context,
              title: l10n.downloadSample,
              icon: Icons.description_outlined,
              color: Colors.blue,
              onTap: () => _handleDownloadSample(context, ref, l10n),
            ),
            const SizedBox(height: 16),
            _buildMaintenanceCard(
              context,
              title: l10n.exportFlashcards,
              icon: Icons.file_upload_rounded,
              color: Colors.orange,
              onTap: () => _handleExport(context, ref, l10n),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            _buildMaintenanceCard(
              context,
              title: l10n.viewAllCards,
              icon: Icons.filter_list_rounded,
              color: theme.colorScheme.primary,
              onTap: () => context.push('/subjects?mode=maintenance'),
            ),
            const SizedBox(height: 16),
             _buildMaintenanceCard(
              context,
              title: l10n.clearDatabase,
              icon: Icons.delete_forever_rounded,
              color: Colors.red,
              onTap: () => _handleClear(context, ref, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
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
      withData: true,
    );

    if (result != null) {
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      
      final content = const Utf8Decoder().convert(bytes);
      final cards = CsvHelper.importFromCsv(content);

      if (cards.isNotEmpty) {
        final db = ref.read(databaseHelperProvider);
        await db.insertMultipleFlashcards(cards);
        
        ref.invalidate(totalFlashcardsCountProvider);
        ref.invalidate(globalStatsProvider);
        ref.invalidate(masteryStatsProvider);
        ref.invalidate(filteredFlashcardsProvider);
        ref.invalidate(categoriesProvider);
        ref.invalidate(selectedSubjectProvider);

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
      
      ref.invalidate(totalFlashcardsCountProvider);
      ref.invalidate(globalStatsProvider);
      ref.invalidate(masteryStatsProvider);
      ref.invalidate(filteredFlashcardsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(selectedSubjectProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clearDatabase)),
        );
      }
    }
  }
}
