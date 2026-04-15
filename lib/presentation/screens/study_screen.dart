import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/flashcard.dart';
import '../../data/providers/flashcard_provider.dart';
import '../controllers/study_controller.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cards = ref.read(filteredFlashcardsProvider).value ?? [];
      ref.read(studyControllerProvider.notifier).startSession(cards);
    });
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
        title: Text('Card ${state.currentIndex + 1} / ${state.cards.length}'),
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
              value: (state.currentIndex + 1) / state.cards.length,
              backgroundColor: Colors.grey[200],
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
      key: ValueKey('card_${state.currentIndex}'),
      tween: Tween<double>(begin: 0, end: state.isFlipped ? 1.0 : 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutBack,

      builder: (context, value, child) {
        // Rotation logic: 0 to pi
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
                  transform: Matrix4.identity()..rotateY(pi), // Flip back to readable
                  child: _buildCardContent(card, state, true),
                )
              : _buildCardContent(card, state, false),
        );
      },
    );
  }

  Widget _buildCardContent(Flashcard card, StudyState state, bool isBack) {
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
                ? [Colors.blue[50]!, Colors.white]
                : (card.isMcq && state.isMcqCorrect != null)
                    ? (state.isMcqCorrect! 
                        ? [Colors.green[200]!, Colors.green[50]!]
                        : [Colors.red[200]!, Colors.red[50]!])
                    : [Colors.blue[100]!, Colors.white],
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
    if (card.isMcq) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Html(
              data: card.frontHtml,
              style: {"body": Style(fontSize: FontSize(22.0), textAlign: TextAlign.center, fontWeight: FontWeight.bold)},
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
            style: {"body": Style(fontSize: FontSize(26.0), textAlign: TextAlign.center)},
          ),
        ),
      );
    }
  }

  Widget _buildBackContent(Flashcard card, StudyState state) {
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
            style: {"body": Style(fontSize: FontSize(28.0), textAlign: TextAlign.center, fontWeight: FontWeight.bold)},
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
    final isSelected = state.mcqSelectedOption == option;
    final isLocked = state.mcqSelectedOption != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: isSelected ? Colors.blue[100] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 0 : 2,
        child: InkWell(
          onTap: isLocked ? null : () => ref.read(studyControllerProvider.notifier).selectMcqOption(option),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected) const Icon(Icons.touch_app, color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(StudyState state) {
    if (state.isFlipped) return const SizedBox.shrink();
    if (state.currentCard?.isMcq == true) return const Text('Choose the correct answer', style: TextStyle(color: Colors.grey));
    return const Text('Tap the card to reveal the answer', style: TextStyle(color: Colors.grey));
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
