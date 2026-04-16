import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../controllers/study_controller.dart';
import '../../data/providers/stats_provider.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/ad_banner_widget.dart';

class SessionSummaryScreen extends ConsumerStatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  ConsumerState<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyControllerProvider);
    final statsAsync = ref.watch(globalStatsProvider);
    final l10n = AppLocalizations.of(context)!;
    
    final total = state.originalCardsCount > 0 ? state.originalCardsCount : state.cards.length;
    final correct = state.correctCount;
    final sessionAccuracy = total == 0 ? 0.0 : (correct / total);

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Applaud Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.sessionComplete,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.greatJob,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 48),

                  // Stats Card
                  Card(
                    elevation: 8,
                    shadowColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          _buildBigStat(l10n.sessionAccuracy, sessionAccuracy),
                          const Divider(height: 48),
                          _buildStatRow(l10n.cardsStudied, '$total'),
                          const SizedBox(height: 16),
                          _buildStatRow(l10n.correctAnswers, '$correct'),
                          const SizedBox(height: 16),
                          
                          // Show progression against initial accuracy
                          statsAsync.when(
                            data: (stats) {
                              final currentGlobal = stats['accuracy'] as double? ?? 0.0;
                              final gained = currentGlobal - state.initialAccuracy;
                              
                              return Column(
                                children: [
                                  const SizedBox(height: 16),
                                  _buildStatRow(
                                    l10n.globalMasteryGained, 
                                    '${gained > 0 ? '+' : ''}${(gained * 100).toStringAsFixed(1)}%',
                                    color: gained > 0 ? Colors.green : (gained < 0 ? Colors.red : Colors.grey),
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Action Button
                  ElevatedButton(
                    onPressed: () {
                      ref.read(studyControllerProvider.notifier).reset();
                      context.go('/');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.backToHome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ),
          ),
          
          // Confetti Layer
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // blast straight down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildBigStat(String label, double accuracy) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: accuracy,
                strokeWidth: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  accuracy >= 0.8 ? Colors.green : (accuracy >= 0.5 ? Colors.orange : Colors.red)
                ),
              ),
            ),
            Text(
              '${(accuracy * 100).toInt()}%',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value, 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}
