import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/stats_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(globalStatsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Language Switcher
              _buildHeader(context, ref, l10n),
              const SizedBox(height: 32),

              // Global Progress Bar (Top)
              _buildGlobalProgress(context, statsAsync, l10n),
              const SizedBox(height: 40),

              // Main Actions
              _buildMenuCard(
                context,
                title: l10n.startPractice,
                subtitle: l10n.startPracticeSubtitle,
                icon: Icons.play_arrow_rounded,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => context.push('/selection'),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: l10n.subjects,
                subtitle: l10n.subjectsSubtitle,
                icon: Icons.grid_view_rounded,
                color: Colors.orange,
                onTap: () => context.push('/subjects'),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                title: l10n.settings,
                subtitle: l10n.settingsSubtitle,
                icon: Icons.settings_rounded,
                color: Colors.blueGrey,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final currentLocale = ref.watch(persistedLocaleProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.greeting,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            Text(
              l10n.yourLearning,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Language Switcher
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            initialValue: currentLocale,
            onSelected: (code) {
              ref.read(persistedLocaleProvider.notifier).setLocale(code);
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    currentLocale == 'ja' ? 'JA' : 'EN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Icon(
                      currentLocale == 'en' ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: currentLocale == 'en' ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    const Text('English'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ja',
                child: Row(
                  children: [
                    Icon(
                      currentLocale == 'ja' ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: currentLocale == 'ja' ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    const Text('日本語'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalProgress(BuildContext context, AsyncValue<Map<String, dynamic>> statsAsync, AppLocalizations l10n) {
    return statsAsync.when(
      data: (stats) {
        final mastery = stats['accuracy'] as double? ?? 0.0;
        final mastered = stats['mastered'] as int? ?? 0;
        final total = stats['total'] as int? ?? 0;
        
        return InkWell(
          onTap: () => context.push('/stats'),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.overallMastery,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(mastery * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: mastery,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.cardsMastered(mastered, total),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Text('Error loading stats: $e'),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
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
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
