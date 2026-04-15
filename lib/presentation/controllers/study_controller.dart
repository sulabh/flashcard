import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/flashcard.dart';
import '../../data/providers/flashcard_provider.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/providers/stats_provider.dart';
import '../../data/providers/settings_provider.dart';

class StudyState {
  final List<Flashcard> cards;
  final List<List<String>> sessionChoices;
  final int currentIndex;
  final int correctCount;
  final int totalAnsweredCount; // Count of uniquely answered cards (including those eventually correct in retry)
  final int originalCardsCount; // The fixed denominator (e.g. 20)
  final bool isCompleted;
  final bool isFlipped;
  final String? mcqSelectedOption;
  final bool? isMcqCorrect;
  final double initialAccuracy;
  final List<Flashcard> skippedCards;
  final bool isRetryPhase;

  StudyState({
    this.cards = const [],
    this.sessionChoices = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.totalAnsweredCount = 0,
    this.originalCardsCount = 0,
    this.isCompleted = false,
    this.isFlipped = false,
    this.mcqSelectedOption,
    this.isMcqCorrect,
    this.initialAccuracy = 0.0,
    this.skippedCards = const [],
    this.isRetryPhase = false,
  });

  Flashcard? get currentCard => cards.isNotEmpty && currentIndex < cards.length 
      ? cards[currentIndex] 
      : null;

  List<String> get currentChoices => sessionChoices.isNotEmpty && currentIndex < sessionChoices.length
      ? sessionChoices[currentIndex]
      : const [];

  StudyState copyWith({
    List<Flashcard>? cards,
    List<List<String>>? sessionChoices,
    int? currentIndex,
    int? correctCount,
    int? totalAnsweredCount,
    int? originalCardsCount,
    bool? isCompleted,
    bool? isFlipped,
    String? mcqSelectedOption,
    bool? isMcqCorrect,
    double? initialAccuracy,
    List<Flashcard>? skippedCards,
    bool? isRetryPhase,
  }) {
    return StudyState(
      cards: cards ?? this.cards,
      sessionChoices: sessionChoices ?? this.sessionChoices,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      totalAnsweredCount: totalAnsweredCount ?? this.totalAnsweredCount,
      originalCardsCount: originalCardsCount ?? this.originalCardsCount,
      isCompleted: isCompleted ?? this.isCompleted,
      isFlipped: isFlipped ?? this.isFlipped,
      mcqSelectedOption: mcqSelectedOption ?? this.mcqSelectedOption,
      isMcqCorrect: isMcqCorrect ?? this.isMcqCorrect,
      initialAccuracy: initialAccuracy ?? this.initialAccuracy,
      skippedCards: skippedCards ?? this.skippedCards,
      isRetryPhase: isRetryPhase ?? this.isRetryPhase,
    );
  }
}




class StudyController extends StateNotifier<StudyState> {
  final Ref ref;

  StudyController(this.ref) : super(StudyState());

  void startSession(List<Flashcard> originalCards) async {
    final sessionSize = ref.read(sessionSizeProvider);
    
    final pool = List<Flashcard>.from(originalCards)..shuffle();
    final sessionCards = pool.take(sessionSize).toList();

    final sessionChoices = sessionCards.map((card) {
      if (card.isMcq) {
        return List<String>.from(card.choices)..shuffle();
      }
      return <String>[];
    }).toList();

    double initialAcc = 0.0;
    try {
      final db = ref.read(databaseHelperProvider);
      final stats = await db.getGlobalStats();
      initialAcc = stats['accuracy'] as double? ?? 0.0;
    } catch (_) {}

    state = StudyState(
      cards: sessionCards,
      sessionChoices: sessionChoices,
      initialAccuracy: initialAcc,
      originalCardsCount: sessionCards.length,
      totalAnsweredCount: 0,
      isRetryPhase: false,
    );
  }

  void flipCard() {
    state = state.copyWith(isFlipped: true);
  }

  void shuffleCurrentCard() {
    if (state.isFlipped || state.mcqSelectedOption != null) return;
    if (state.isRetryPhase && state.cards.length <= 1) return; // Cannot shuffle if only 1 card left

    
    final cards = List<Flashcard>.from(state.cards);
    final choices = List<List<String>>.from(state.sessionChoices);
    
    if (state.currentIndex < cards.length - 1) {
      final nextIndex = state.currentIndex + 1 + (DateTime.now().millisecondsSinceEpoch % (cards.length - 1 - state.currentIndex));
      
      final currentCard = cards[state.currentIndex];
      final currentChoices = choices[state.currentIndex];
      
      cards[state.currentIndex] = cards[nextIndex];
      choices[state.currentIndex] = choices[nextIndex];
      
      cards[nextIndex] = currentCard;
      choices[nextIndex] = currentChoices;
      
      state = state.copyWith(cards: cards, sessionChoices: choices);
    }
  }

  void skipCurrentCard() {
    if (state.isRetryPhase) return;
    
    final currentCard = state.currentCard;
    if (currentCard == null) return;
    
    state = state.copyWith(
      skippedCards: [...state.skippedCards, currentCard],
    );
    
    proceedToNext();
  }

  Future<void> forceFinishSession() async {
    final unstudiedCards = state.cards.sublist(state.currentIndex);
    final db = ref.read(databaseHelperProvider);
    
    for (final card in unstudiedCards) {
      await db.updateFlashcardStats(card.id, card.repetitions + 1, card.correctCount);
    }
    
    ref.invalidate(masteryStatsProvider);
    ref.invalidate(globalStatsProvider);
    
    state = state.copyWith(isCompleted: true);
  }

  Future<void> submittedClassicResult(int weight) async {
    final card = state.currentCard;
    if (card == null) return;

    final isCorrect = weight > 1; 
    
    final db = ref.read(databaseHelperProvider);
    await db.updateFlashcardStats(card.id, card.repetitions + 1, card.correctCount + (isCorrect ? 1 : 0));

    ref.invalidate(masteryStatsProvider);

    state = state.copyWith(
      isFlipped: true,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
      totalAnsweredCount: state.totalAnsweredCount + 1,
    );
  }

  Future<void> selectMcqOption(String option) async {
    final card = state.currentCard;
    if (card == null || state.mcqSelectedOption != null) return;

    final isCorrect = card.backHtml == option;
    
    final db = ref.read(databaseHelperProvider);
    await db.updateFlashcardStats(card.id, card.repetitions + 1, card.correctCount + (isCorrect ? 1 : 0));

    ref.invalidate(masteryStatsProvider);

    state = state.copyWith(
      mcqSelectedOption: option,
      isMcqCorrect: isCorrect,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
      totalAnsweredCount: state.totalAnsweredCount + 1,
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) state = state.copyWith(isFlipped: true);
    });
  }

  void proceedToNext() {
    if (state.currentIndex < state.cards.length - 1) {
      state = StudyState(
        cards: state.cards,
        sessionChoices: state.sessionChoices,
        currentIndex: state.currentIndex + 1,
        correctCount: state.correctCount,
        totalAnsweredCount: state.totalAnsweredCount,
        originalCardsCount: state.originalCardsCount,
        isCompleted: state.isCompleted,
        isFlipped: false,
        mcqSelectedOption: null,
        isMcqCorrect: null,
        initialAccuracy: state.initialAccuracy,
        skippedCards: state.skippedCards,
        isRetryPhase: state.isRetryPhase,
      );
    } else if (state.skippedCards.isNotEmpty) {
      final retryCards = List<Flashcard>.from(state.skippedCards);
      final retryChoices = retryCards.map((card) {
        if (card.isMcq) return List<String>.from(card.choices)..shuffle();
        return <String>[];
      }).toList();

      state = StudyState(
        cards: retryCards,
        sessionChoices: retryChoices,
        currentIndex: 0,
        correctCount: state.correctCount,
        totalAnsweredCount: state.totalAnsweredCount,
        originalCardsCount: state.originalCardsCount,
        isCompleted: false,
        isFlipped: false,
        mcqSelectedOption: null,
        isMcqCorrect: null,
        initialAccuracy: state.initialAccuracy,
        skippedCards: const [], 
        isRetryPhase: true,
      );
    } else {
      ref.invalidate(globalStatsProvider);
      state = state.copyWith(isCompleted: true);
    }
  }


  void reset() {
    state = StudyState();
  }
}



final studyControllerProvider = StateNotifierProvider<StudyController, StudyState>((ref) {
  return StudyController(ref);
});

