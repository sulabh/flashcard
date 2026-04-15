import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/providers/settings_provider.dart';
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
      body: ListView(
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
          ListTile(
            title: Text(l10n.sessionTimer),
            subtitle: Text(l10n.autoFinish),
            trailing: DropdownButton<int>(
              value: sessionTimer,
              underline: const SizedBox(),
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
          ),

          const SizedBox(height: 24),
          _SectionHeader(title: l10n.themeMode),

          ListTile(
            title: Text(l10n.themeMode),
            subtitle: Text(themeMode.toString().split('.').last.toUpperCase()),
            trailing: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode), label: Text(l10n.light)),
                ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode), label: Text(l10n.dark)),
                ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.settings), label: Text(l10n.system)),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) => ref.read(themeModeProvider.notifier).state = value.first,
            ),
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
    );
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
