import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../l10n/app_localizations.dart';
import 'dart:math' as math;
import '../../data/providers/progress_provider.dart';
import '../../flavor_config.dart';

class SubjectScreen extends ConsumerWidget {
  final String mode;
  const SubjectScreen({super.key, this.mode = 'study'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final l10n = AppLocalizations.of(context)!;

    // Refresh mastery stats when entering the screen
    ref.listen(masteryStatsProvider, (_, __) {});

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseSubject),
        centerTitle: true,
      ),
      body: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects found. Please import data.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Scrollbar(
              thumbVisibility: true,
              child: GridView.builder(
                primary: true,
                physics: const ClampingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final name = subjects[index];
                  final mastery = ref.watch(subjectMasteryProvider(name));
                  final masteryPercentage = (mastery * 100).toInt();

                  // Predefined icons and colors exactly like before
                  final fallbackStyles = [
                    {'icon': Icons.translate, 'color': Colors.blue},
                    {'icon': Icons.calculate, 'color': Colors.orange},
                    {'icon': Icons.language, 'color': Colors.green},
                    {'icon': Icons.menu_book, 'color': Colors.purple},
                    {'icon': Icons.public, 'color': Colors.red},
                  ];

                  // Map known subjects exactly like before, else hash over the array
                  final knownMap = {
                    'Kanji': fallbackStyles[0],
                    'Arithmetic': fallbackStyles[1],
                    'English': fallbackStyles[2],
                    'Vocabulary': fallbackStyles[3],
                    'General Knowledge': fallbackStyles[4],
                  };

                  final style = knownMap[name] ?? fallbackStyles[math.Random(name.hashCode).nextInt(5)];
                  final icon = style['icon'] as IconData;
                  final color = style['color'] as Color;

                  // Color threshold logic
                  Color progressColor;
                  if (mastery < 0.4) progressColor = Colors.redAccent;
                  else if (mastery < 0.7) progressColor = Colors.orangeAccent;
                  else progressColor = Colors.greenAccent;

                  final isLocked = FlavorConfig.instance.flavor == AppFlavor.free && index >= 2;

                  return InkWell(
                    onTap: () {
                      if (isLocked) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                const Icon(Icons.workspace_premium, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(child: Text(l10n.premiumFeature)),
                              ],
                            ),
                            content: Text(l10n.premiumRequiredMsg),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      
                      ref.read(selectedSubjectProvider.notifier).state = name;
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      ref.read(selectedUnitProvider.notifier).state = null;
                      context.push('/selection?mode=$mode');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Opacity(
                      opacity: isLocked ? 0.6 : 1.0,
                      child: Card(
                        elevation: isLocked ? 1 : 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isLocked
                                  ? [Colors.grey.withAlpha(200), Colors.blueGrey]
                                  : [color.withAlpha(200), color],
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
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
                              if (isLocked)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white24,
                                    ),
                                    child: const Icon(Icons.lock, color: Colors.white, size: 20),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },

              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error loading subjects')),
      ),
    );
  }
}

