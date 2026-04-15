import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/providers/settings_provider.dart';
import '../../core/providers/core_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionSize = ref.watch(sessionSizeProvider);
    final sessionTimer = ref.watch(sessionTimerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Study Session'),
          
          // Slider for Session Size
          ListTile(
            title: const Text('Cards per Set'),
            subtitle: Text('$sessionSize cards per practice session'),
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
            title: const Text('Session Timer'),
            subtitle: const Text('Auto-finish session when time runs out'),
            trailing: DropdownButton<int>(
              value: sessionTimer,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 0, child: Text('No Timer')),
                DropdownMenuItem(value: 5, child: Text('5 Minutes')),
                DropdownMenuItem(value: 10, child: Text('10 Minutes')),
                DropdownMenuItem(value: 30, child: Text('30 Minutes')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(sessionTimerProvider.notifier).setSessionTimer(value);
                }
              },
            ),
          ),

          const SizedBox(height: 24),
          const _SectionHeader(title: 'Appearance'),

          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(themeMode.toString().split('.').last.toUpperCase()),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings)),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) => ref.read(themeModeProvider.notifier).state = value.first,
            ),
          ),

          const SizedBox(height: 48),
          Center(
            child: Text(
              'App Version 1.0.0',
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
