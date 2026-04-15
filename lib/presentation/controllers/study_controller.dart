import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/flashcard.dart';
import '../../data/providers/flashcard_provider.dart';

class StudyState {
  final List<Flashcard> cards;
  final List<List<String>> sessionChoices; // Shuffled choices for each card in the session
  final int currentIndex;
  final int correctCount;
  final bool isCompleted;
  final bool isFlipped;
  final String? mcqSelectedOption;
  final bool? isMcqCorrect;

  StudyState({
    this.cards = const [],
    this.sessionChoices = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.isCompleted = false,
    this.isFlipped = false,
    this.mcqSelectedOption,
    this.isMcqCorrect,
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
    bool? isCompleted,
    bool? isFlipped,
    String? mcqSelectedOption,
    bool? isMcqCorrect,
  }) {
    return StudyState(
      cards: cards ?? this.cards,
      sessionChoices: sessionChoices ?? this.sessionChoices,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      isCompleted: isCompleted ?? this.isCompleted,
      isFlipped: isFlipped ?? this.isFlipped,
      mcqSelectedOption: mcqSelectedOption ?? this.mcqSelectedOption,
      isMcqCorrect: isMcqCorrect ?? this.isMcqCorrect,
    );
  }
}

class StudyController extends StateNotifier<StudyState> {
  final Ref ref;

  StudyController(this.ref) : super(StudyState());

  void startSession(List<Flashcard> originalCards) {
    // 1. Randomize and take only 20
    final pool = List<Flashcard>.from(originalCards)..shuffle();
    final sessionCards = pool.take(20).toList();

    // 2. Pre-shuffle choices for all cards to keep consistency during session
    final sessionChoices = sessionCards.map((card) {
      if (card.isMcq) {
        return List<String>.from(card.choices)..shuffle();
      }
      return <String>[];
    }).toList();

    state = StudyState(
      cards: sessionCards,
      sessionChoices: sessionChoices,
    );
  }

  void flipCard() {
    state = state.copyWith(isFlipped: true);
  }

  Future<void> submittedClassicResult(int weight) async {
    final card = state.currentCard;
    if (card == null) return;

    final isCorrect = weight > 1; 
    
    // Update DB
    final db = ref.read(databaseHelperProvider);
    await db.updateFlashcardStats(
      card.id, 
      card.repetitions + 1, 
      card.correctCount + (isCorrect ? 1 : 0)
    );

    // Update state but DON'T advance yet (user must click Proceed)
    state = state.copyWith(
      isFlipped: true,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
    );
  }

  Future<void> selectMcqOption(String option) async {
    final card = state.currentCard;
    if (card == null || state.mcqSelectedOption != null) return;

    final isCorrect = card.backHtml == option;
    
    // Update DB
    final db = ref.read(databaseHelperProvider);
    await db.updateFlashcardStats(
      card.id, 
      card.repetitions + 1, 
      card.correctCount + (isCorrect ? 1 : 0)
    );

    state = state.copyWith(
      mcqSelectedOption: option,
      isMcqCorrect: isCorrect,
      correctCount: state.correctCount + (isCorrect ? 1 : 0),
    );

    // Wait 1 second then flip automatically
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
        isCompleted: state.isCompleted,
        isFlipped: false,
        mcqSelectedOption: null,
        isMcqCorrect: null,
      );
    } else {
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

