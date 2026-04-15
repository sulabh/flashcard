import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/flashcard_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Subject'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            final name = subject['name'] as String;
            final icon = subject['icon'] as IconData;
            final color = subject['color'] as Color;

            return InkWell(
              onTap: () {
                ref.read(selectedSubjectProvider.notifier).state = name;
                context.push('/deck');
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
                      Icon(icon, size: 48, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }
}
