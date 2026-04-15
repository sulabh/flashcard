import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/providers/stats_provider.dart';
import '../../data/providers/progress_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(globalStatsProvider);
    final masteryAsync = ref.watch(masteryStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Stats'),
      ),
      body: statsAsync.when(
        data: (stats) {
          final total = stats['total'] as int? ?? 0;
          final studied = stats['studied'] as int? ?? 0;
          final mastered = stats['mastered'] as int? ?? 0;
          final accuracy = stats['accuracy'] as double? ?? 0.0;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(context, total, studied, mastered, accuracy),
                const SizedBox(height: 32),
                const Text(
                  'Subject Mastery',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSubjectBreakdown(masteryAsync),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error loading stats: $e')),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, int total, int studied, int mastered, double accuracy) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatRing('Accuracy', accuracy),
                _buildStatRing('Mastered', total == 0 ? 0.0 : mastered / total, color: Colors.green),
                _buildStatRing('Studied', total == 0 ? 0.0 : studied / total, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatText('Total Cards', '$total'),
                _buildStatText('Mastered', '$mastered'),
                _buildStatText('New', '${total - studied}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRing(String label, double percentage, {Color? color}) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                color: color ?? Colors.blue,
              ),
              Center(
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatText(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSubjectBreakdown(AsyncValue<Map<String, double>> masteryAsync) {
    return masteryAsync.when(
      data: (subjectMastery) {
        if (subjectMastery.isEmpty) {
          return const Text('No subject data available yet. Start practicing!');
        }
        
        return Column(
          children: subjectMastery.entries.map((entry) {
            final subject = entry.key;
            final mastery = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subject, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${(mastery * 100).toInt()}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: mastery,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        mastery > 0.7 ? Colors.green : (mastery > 0.4 ? Colors.orange : Colors.blue)
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, __) => Text('Error loading subjects: $e'),
    );
  }
}
