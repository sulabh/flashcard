import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/providers/progress_provider.dart';

class SubjectScreen extends ConsumerWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = [
      {'name': 'Kanji', 'icon': Icons.translate, 'color': Colors.blue},
      {'name': 'Arithmetic', 'icon': Icons.calculate, 'color': Colors.orange},
      {'name': 'English', 'icon': Icons.language, 'color': Colors.green},
      {'name': 'Vocabulary', 'icon': Icons.menu_book, 'color': Colors.purple},
      {'name': 'General Knowledge', 'icon': Icons.public, 'color': Colors.red},
    ];

    // Refresh mastery stats when entering the screen
    ref.listen(masteryStatsProvider, (_, __) {});

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseSubject),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          thumbVisibility: true,
          child: GridView.builder(
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Adjusted for progress bar
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
            final subject = subjects[index];
            final name = subject['name'] as String;
            final icon = subject['icon'] as IconData;
            final color = subject['color'] as Color;
            
            final mastery = ref.watch(categoryMasteryProvider(name));
            final masteryPercentage = (mastery * 100).toInt();

            // Color threshold logic
            Color progressColor;
            if (mastery < 0.4) progressColor = Colors.redAccent;
            else if (mastery < 0.7) progressColor = Colors.orangeAccent;
            else progressColor = Colors.greenAccent;

            return InkWell(
              onTap: () {
                ref.read(selectedSubjectProvider.notifier).state = name;
                context.push('/selection');
              },
              borderRadius: BorderRadius.circular(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withAlpha(200),
                        color,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 40, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: mastery,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$masteryPercentage% Mastered',
                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }
}

