import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../core/providers/core_providers.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/ad_banner_widget.dart';

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
          primary: true,
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
  
            // Fixed Theme Selection
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
            _SectionHeader(title: l10n.audioSettings),
            SwitchListTile(
              title: Text(l10n.autoPlayAudio),
              subtitle: Text(l10n.autoPlayAudioSub),
              secondary: Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary),
              value: ref.watch(autoPlayAudioProvider),
              onChanged: (value) => ref.read(autoPlayAudioProvider.notifier).setAutoPlay(value),
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
      bottomNavigationBar: const AdBannerWidget(),
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
