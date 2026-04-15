import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/flashcard.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../controllers/study_controller.dart';


class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cards = ref.read(filteredFlashcardsProvider).value ?? [];
      ref.read(studyControllerProvider.notifier).startSession(cards);

      // Initialize Timer
      final timerMinutes = ref.read(sessionTimerProvider);
      if (timerMinutes > 0) {
        setState(() {
          _secondsRemaining = timerMinutes * 60;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        ref.read(studyControllerProvider.notifier).forceFinishSession();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyControllerProvider);
    final card = state.currentCard;

    if (state.isCompleted) {
      Future.delayed(Duration.zero, () {
        if (mounted) context.go('/summary');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Session')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isRetryPhase ? 'Retry Phase' : 'Study Session',
              style: TextStyle(
                fontSize: 14, 
                color: state.isRetryPhase ? Colors.orange : Colors.grey,
                fontWeight: state.isRetryPhase ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              state.isRetryPhase
                ? 'Card ${state.currentIndex + 1} / ${state.cards.length} (Retrying)'
                : 'Card ${state.currentIndex + 1} / ${state.originalCardsCount}',
            ),
          ],
        ),
        actions: [
          if (_secondsRemaining > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _secondsRemaining < 30 ? Colors.red.withAlpha(40) : Colors.blue.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined, 
                        size: 18, 
                        color: _secondsRemaining < 30 ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_secondsRemaining),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _secondsRemaining < 30 ? Colors.red : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(studyControllerProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: state.originalCardsCount > 0 
                  ? (state.totalAnsweredCount) / state.originalCardsCount 
                  : 0,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _buildFlipCard(card, state),
            ),
            const SizedBox(height: 20),
            _buildControls(state),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipCard(Flashcard card, StudyState state) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('card_${state.isRetryPhase ? "retry_" : ""}${state.currentIndex}'),
      tween: Tween<double>(begin: 0, end: state.isFlipped ? 1.0 : 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutBack,

      builder: (context, value, child) {
        final rotation = value * pi;
        final isBack = rotation > pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(rotation),
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildCardContent(card, state, true),
                )
              : _buildCardContent(card, state, false),
        );
      },
    );
  }

  Widget _buildCardContent(Flashcard card, StudyState state, bool isBack) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.cardColor;
    final primaryAlpha = theme.brightness == Brightness.light ? 50 : 30;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: !isBack 
                ? [theme.colorScheme.primary.withAlpha(primaryAlpha), cardColor]
                : (card.isMcq && state.isMcqCorrect != null)
                    ? (state.isMcqCorrect! 
                        ? [Colors.green.withAlpha(primaryAlpha), cardColor]
                        : [Colors.red.withAlpha(primaryAlpha), cardColor])
                    : [theme.colorScheme.secondary.withAlpha(primaryAlpha), cardColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: isBack 
                  ? _buildBackContent(card, state)
                  : _buildFrontContent(card, state),
            ),
            if (state.isFlipped)
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    state.currentIndex == state.cards.length - 1 ? Icons.check_circle : Icons.arrow_forward_rounded,
                    size: 40,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () => ref.read(studyControllerProvider.notifier).proceedToNext(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontContent(Flashcard card, StudyState state) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    if (card.isMcq) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Html(
              data: card.frontHtml,
              style: {
                "body": Style(
                  fontSize: FontSize(22.0), 
                  textAlign: TextAlign.center, 
                  fontWeight: FontWeight.bold,
                  color: textColor,
                )
              },
            ),
            const SizedBox(height: 32),
            ...state.currentChoices.map((option) => _buildMcqOption(option, state)),
          ],
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => ref.read(studyControllerProvider.notifier).flipCard(),
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Html(
            data: card.frontHtml,
            style: {
              "body": Style(
                fontSize: FontSize(26.0), 
                textAlign: TextAlign.center,
                color: textColor,
              )
            },
          ),
        ),
      );
    }
  }

  Widget _buildBackContent(Flashcard card, StudyState state) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.currentCard?.isMcq == true) ...[
            const Text('ANSWER', style: TextStyle(color: Colors.grey, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
  
          Html(
            data: card.backHtml,
            style: {
              "body": Style(
                fontSize: FontSize(28.0), 
                textAlign: TextAlign.center, 
                fontWeight: FontWeight.bold,
                color: textColor,
              )
            },
          ),
          const SizedBox(height: 32),
          if (!card.isMcq) ...[
            const Text('How was it?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnkiButton(label: 'Hard', color: Colors.red, weight: 1),
                _buildAnkiButton(label: 'Normal', color: Colors.orange, weight: 2),
                _buildAnkiButton(label: 'Easy', color: Colors.green, weight: 3),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMcqOption(String option, StudyState state) {
    final theme = Theme.of(context);
    final isSelected = state.mcqSelectedOption == option;
    final isLocked = state.mcqSelectedOption != null;

    final baseColor = isSelected 
        ? theme.colorScheme.primaryContainer 
        : theme.cardTheme.color ?? theme.cardColor;
    
    final borderColor = isSelected 
        ? theme.colorScheme.primary 
        : theme.dividerColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 0 : 2,
        child: InkWell(
          onTap: isLocked ? null : () => ref.read(studyControllerProvider.notifier).selectMcqOption(option),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (isSelected) Icon(Icons.touch_app, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(StudyState state) {
    if (state.isFlipped) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle Button
            Column(
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.shuffle_rounded),
                  onPressed: state.currentIndex < state.cards.length - 1 
                      ? () => ref.read(studyControllerProvider.notifier).shuffleCurrentCard()
                      : null,
                ),
                const Text('Shuffle', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            
            // Skip Button (Hidden in Retry Phase)
            if (!state.isRetryPhase)
              Column(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.skip_next_rounded),
                    color: Colors.orange,
                    onPressed: () => ref.read(studyControllerProvider.notifier).skipCurrentCard(),
                  ),
                  const Text('Skip', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          state.currentCard?.isMcq == true 
              ? 'Choose the correct answer' 
              : 'Tap the card to reveal the answer',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildAnkiButton({required String label, required Color color, required int weight}) {
    return ElevatedButton(
      onPressed: () => ref.read(studyControllerProvider.notifier).submittedClassicResult(weight),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}
