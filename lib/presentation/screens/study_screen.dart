import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/flashcard.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/app_flashcard_html.dart';
import '../../core/services/tts_service.dart';
import '../controllers/study_controller.dart';


class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  late TtsService _ttsService;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _ttsService = ref.read(ttsServiceProvider);
    // Initialize Timer if already set in settings, but we wait for cards to trigger session start
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // Stop any ongoing speech when leaving the study screen
    _ttsService.stop();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _speakCurrentSide(Flashcard? card, bool isFlipped) {
    if (card == null) return;
    
    final localeCode = ref.read(persistedLocaleProvider);
    final textToSpeak = isFlipped ? card.displayBack : card.displayFront;
    
    ref.read(ttsServiceProvider).speak(textToSpeak, localeCode);
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(filteredFlashcardsProvider);
    final state = ref.watch(studyControllerProvider);
    final card = state.currentCard;

    // Handle session completion
    ref.listen(studyControllerProvider, (previous, next) {
      if (next.isCompleted && (previous == null || !previous.isCompleted)) {
        if (mounted) context.go('/summary');
      }
    });

    // Handle initialization when data is ready
    ref.listen<AsyncValue<List<Flashcard>>>(filteredFlashcardsProvider, (previous, next) {
      next.whenData((cards) {
        if (cards.isNotEmpty && state.cards.isEmpty) {
          ref.read(studyControllerProvider.notifier).startSession(cards);
        }
      });
    });

    // Listen for state changes to trigger auto-play
    ref.listen(studyControllerProvider, (previous, next) {
      if (!ref.read(autoPlayAudioProvider)) return;

      final cardChanged = previous?.currentCard != next.currentCard;
      final flipChanged = previous?.isFlipped != next.isFlipped;

      if (cardChanged || flipChanged) {
        _speakCurrentSide(next.currentCard, next.isFlipped);
      }
    });

    if (state.isCompleted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return cardsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.studySession)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.studySession)),
        body: Center(child: Text('Error: $err')),
      ),
      data: (cards) {
        if (cards.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.studySession)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noCardsFound, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.goBack),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if session actually started
        if (card == null) {
          // If we have data but state is empty, it means initialization hasn't happened or was bypassed
          // We trigger it here just in case ref.listen was missed during first build
          Future.delayed(Duration.zero, () {
            if (mounted && state.cards.isEmpty) {
              ref.read(studyControllerProvider.notifier).startSession(cards);
            }
          });
          return Scaffold(
            appBar: AppBar(title: Text(l10n.studySession)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isRetryPhase ? l10n.retryPhase : l10n.studySession,
              style: TextStyle(
                fontSize: 14, 
                color: state.isRetryPhase ? Colors.orange : Colors.grey,
                fontWeight: state.isRetryPhase ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              state.isRetryPhase
                ? '${l10n.cardProgress(state.currentIndex + 1, state.cards.length)} (${l10n.retrying})'
                : l10n.cardProgress(state.currentIndex + 1, state.originalCardsCount),
            ),
          ],
        ),
        actions: [
          if (state.isRetryPhase)
            TextButton.icon(
              onPressed: () {
                _timer?.cancel();
                ref.read(studyControllerProvider.notifier).forceFinishSession();
              },
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.red, size: 20),
              label: Text(l10n.endQuiz, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          if (_secondsRemaining > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
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
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              ref.read(ttsServiceProvider).stop(); // Kill audio on exit
              ref.read(studyControllerProvider.notifier).reset();
              context.go('/');
            },
          ),
        ],
        automaticallyImplyLeading: false, // Removed leading close button
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
            const SizedBox(height: 8),
            // Subject / Category / Unit shown below progress bar
            Text(
              '${card.subject}  /  ${card.category}  /  ${card.unit}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFlipCard(card, state),
            ),
            _buildControls(state),
            ],
          ),
        ),
        bottomNavigationBar: const AdBannerWidget(),
      );
    },
  );
}

  Widget _buildFlipCard(Flashcard card, StudyState state) {
    return _buildCardContent(card, state, state.isFlipped);
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            // UUID at top right (next to volume button)
            Positioned(
              top: 0,
              right: 48,
              child: SelectableText(
                card.id?.toString() ?? '-',
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: isBack 
                    ? _buildBackContent(card, state)
                    : _buildFrontContent(card, state),
              ),
            ),
            
            // Manual Speak Button
            Positioned(
              top: -12,
              right: -12,
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blueGrey, size: 28),
                onPressed: () => _speakCurrentSide(card, isBack),
              ),
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
          physics: const ClampingScrollPhysics(),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (card.title.isNotEmpty) ...[
              AppFlashcardHtml(
                data: card.title,
                style: {
                  "body": Style(
                    fontSize: FontSize(14.0), 
                    textAlign: TextAlign.center, 
                    fontWeight: FontWeight.normal,
                    color: textColor.withOpacity(0.6),
                  )
                },
              ),
              const SizedBox(height: 8),
            ],
            if (card.problem.isNotEmpty) ...[
              AppFlashcardHtml(
                data: card.problem,
                style: {
                  "body": Style(
                    fontSize: FontSize(18.0), 
                    textAlign: TextAlign.center, 
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  )
                },
              ),
              const SizedBox(height: 8),
            ],
            if (card.supplementProblem.isNotEmpty) ...[
              AppFlashcardHtml(
                data: card.supplementProblem,
                style: {
                  "body": Style(
                    fontSize: FontSize(14.0), 
                    textAlign: TextAlign.center, 
                    fontWeight: FontWeight.normal,
                    color: textColor.withOpacity(0.6),
                  )
                },
              ),
              const SizedBox(height: 16),
            ],
            ...state.currentChoices.asMap().entries.map((entry) => _buildMcqOption(entry.value, state, entry.key)),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (card.title.isNotEmpty) ...[
                AppFlashcardHtml(
                  data: card.title,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0), 
                      textAlign: TextAlign.center,
                      color: textColor.withOpacity(0.6),
                      margin: Margins.zero,
                    )
                  },
                ),
                const SizedBox(height: 12),
              ],
              if (card.problem.isNotEmpty) ...[
                AppFlashcardHtml(
                  data: card.problem,
                  style: {
                    "body": Style(
                      fontSize: FontSize(26.0), 
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.normal,
                      color: textColor,
                      margin: Margins.zero,
                    )
                  },
                ),
                const SizedBox(height: 12),
              ],
              if (card.supplementProblem.isNotEmpty) ...[
                AppFlashcardHtml(
                  data: card.supplementProblem,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0), 
                      textAlign: TextAlign.center,
                      color: textColor.withOpacity(0.6),
                      margin: Margins.zero,
                    )
                  },
                ),
              ],
              const SizedBox(height: 64),
              Text(
                l10n.classicStudyNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildBackContent(Flashcard card, StudyState state) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (card.isMcq) ...[
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: state.isMcqCorrect == true ? Colors.green.withAlpha(40) : Colors.red.withAlpha(40),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: state.isMcqCorrect == true ? Colors.green : Colors.red, width: 2),
              ),
              child: Text(
                state.isMcqCorrect == true ? l10n.mcqCorrect : l10n.mcqIncorrect,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: state.isMcqCorrect == true ? Colors.green : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Selection Details
            _buildResultDetail(
              label: l10n.yourSelection,
              content: state.mcqSelectedOption ?? '',
              choices: state.currentChoices,
              isCorrect: state.isMcqCorrect == true,
            ),
            
            if (state.isMcqCorrect == false) ...[
              const SizedBox(height: 16),
              _buildResultDetail(
                label: l10n.correctAnswerLabel,
                content: card.correctAnswer,
                choices: state.currentChoices,
                isCorrect: true,
                isHeader: true,
              ),
            ],
            const SizedBox(height: 48),
          ],
  
          if (!card.isMcq)
            AppFlashcardHtml(
              data: card.displayBack,
              style: {
                "body": Style(
                  fontSize: FontSize(28.0), 
                  textAlign: TextAlign.center, 
                  fontWeight: FontWeight.bold,
                  color: textColor,
                )
              },
            ),
          
          if (card.isMcq) ...[
             // Next button for MCQ after reveal
             ElevatedButton.icon(
                onPressed: () => ref.read(studyControllerProvider.notifier).proceedToNext(),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(l10n.nextCard, style: const TextStyle(fontSize: 18)),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
             ),
          ] else ...[
            const SizedBox(height: 48),
            // Self-evaluation note
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                l10n.selfEvalNote,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnkiButton(label: l10n.incorrect, color: Colors.red, weight: 1),
                _buildAnkiButton(label: l10n.correct, color: Colors.green, weight: 2),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultDetail({
    required String label, 
    required String content, 
    required List<String> choices,
    required bool isCorrect,
    bool isHeader = false,
  }) {
    final index = choices.indexOf(content);
    final letter = index != -1 ? _getLetter(index) : '?';
    final theme = Theme.of(context);
    final displayContent = content == '[[IDK]]' ? l10n.iDontKnow : content;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: isHeader ? Border.all(color: theme.colorScheme.primary.withAlpha(100)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("($letter) ", style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
              Expanded(
                child: AppFlashcardHtml(
                  data: displayContent,
                  style: {"body": Style(fontSize: FontSize(16.0), margin: Margins.zero)},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLetter(int index) {
    if (index < 0 || index > 25) return '?';
    return String.fromCharCode(65 + index); // 65 is 'A'
  }

  Widget _buildMcqOption(String option, StudyState state, int index) {
    final theme = Theme.of(context);
    final isSelected = state.mcqSelectedOption == option;
    final isLocked = state.mcqSelectedOption != null;
    final letter = _getLetter(index);
    final displayContent = option == '[[IDK]]' ? l10n.iDontKnow : option;

    final baseColor = isSelected 
        ? theme.colorScheme.primaryContainer 
        : theme.cardTheme.color ?? theme.cardColor;
    
    final borderColor = isSelected 
        ? theme.colorScheme.primary 
        : theme.dividerColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 0 : 2,
        child: InkWell(
          onTap: isLocked ? null : () => ref.read(studyControllerProvider.notifier).selectMcqOption(option),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("($letter) ", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? theme.colorScheme.primary : null)),
                      Expanded(
                        child: AppFlashcardHtml(
                          data: displayContent,
                          textAlign: TextAlign.start,
                          style: {
                            "body": Style(
                              fontSize: FontSize(15.0),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: theme.textTheme.bodyLarge?.color,
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                            )
                          },
                        ),
                      ),
                    ],
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
                Text(l10n.shuffle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                  Text(l10n.skip, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          state.currentCard?.isMcq == true 
              ? l10n.chooseCorrect 
              : l10n.tapToReveal,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildAnkiButton({required String label, required Color color, required int weight}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ElevatedButton(
          onPressed: () => ref.read(studyControllerProvider.notifier).submittedClassicResult(weight),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
