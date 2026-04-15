import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/study_controller.dart';

class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider);
    final total = state.cards.length;
    final correct = state.correctCount;
    final accuracy = total == 0 ? 0 : (correct / total) * 100;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Session Complete!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              _buildStatRow('Cards Studied', '$total'),
              const Divider(height: 32),
              _buildStatRow('Correct Answers', '$correct'),
              const Divider(height: 32),
              _buildStatRow('Accuracy', '${accuracy.toStringAsFixed(1)}%'),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () {
                  ref.read(studyControllerProvider.notifier).reset();
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Back to Home', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
