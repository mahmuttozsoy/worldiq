import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocab_word.dart';
import '../data/vocabulary.dart';
import '../providers/shared_prefs_provider.dart';
import '../providers/user_vocabulary_provider.dart';
import '../models/word_progress.dart';
import '../utils/srs_calculator.dart';
import 'user_progress_provider.dart';
import 'daily_missions_provider.dart';
import 'achievements_provider.dart';

enum VocabQuizStatus { initial, playing, answered, finished }

class VocabQuizState {
  final VocabQuizStatus status;
  final VocabWord? currentWord;
  final List<VocabWord> options;
  final int currentQuestionIndex;
  final int score;
  final int lives;
  final bool? isLastAnswerCorrect;
  final VocabWord? selectedAnswer;
  final List<VocabWord> questions;
  final String level;
  final bool isUnlockTest;
  final String? unlockTargetLevel;
  final String? countryId;
  final int timeLeft;
  final int maxTime;

  const VocabQuizState({
    this.status = VocabQuizStatus.initial,
    this.currentWord,
    this.options = const [],
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.lives = 3,
    this.isLastAnswerCorrect,
    this.selectedAnswer,
    this.questions = const [],
    this.level = 'A1',
    this.isUnlockTest = false,
    this.unlockTargetLevel,
    this.countryId,
    this.timeLeft = 10,
    this.maxTime = 10,
  });

  VocabQuizState copyWith({
    VocabQuizStatus? status,
    VocabWord? currentWord,
    List<VocabWord>? options,
    int? currentQuestionIndex,
    int? score,
    int? lives,
    bool? isLastAnswerCorrect,
    VocabWord? selectedAnswer,
    List<VocabWord>? questions,
    String? level,
    bool? isUnlockTest,
    String? unlockTargetLevel,
    String? countryId,
    int? timeLeft,
    int? maxTime,
  }) {
    return VocabQuizState(
      status: status ?? this.status,
      currentWord: currentWord ?? this.currentWord,
      options: options ?? this.options,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      isLastAnswerCorrect: isLastAnswerCorrect,
      selectedAnswer: selectedAnswer,
      questions: questions ?? this.questions,
      level: level ?? this.level,
      isUnlockTest: isUnlockTest ?? this.isUnlockTest,
      unlockTargetLevel: unlockTargetLevel ?? this.unlockTargetLevel,
      countryId: countryId ?? this.countryId,
      timeLeft: timeLeft ?? this.timeLeft,
      maxTime: maxTime ?? this.maxTime,
    );
  }
}

class VocabQuizNotifier extends Notifier<VocabQuizState> {
  Timer? _timer;

  @override
  VocabQuizState build() {
    ref.onDispose(() => _timer?.cancel());
    return const VocabQuizState();
  }

  void startQuiz(
    String countryId,
    String level, {
    bool isUnlockTest = false,
    String? unlockTargetLevel,
    bool isMasteredReview = false,
    int questionCount = 10,
  }) {
    final List<VocabWord> allWords = [...(vocabularyData[countryId] ?? [])];
    final userWords = ref
        .read(userVocabularyProvider.notifier)
        .getWordsForLevel(countryId, level);
    allWords.addAll(userWords);

    List<VocabWord> levelWords = allWords
        .where((w) => w.level == level)
        .toList();
    final sharedPrefs = ref.read(sharedPrefsServiceProvider);

    if (isMasteredReview) {
      levelWords = levelWords.where((word) {
        final progress = sharedPrefs.getWordProgress(word.id);
        return progress != null && progress.isMastered;
      }).toList();
    } else if (!isUnlockTest) {
      levelWords = levelWords.where((word) {
        final progress = sharedPrefs.getWordProgress(word.id);
        if (progress == null) return true; // Never studied
        if (progress.isMastered) return false; // Already learned/mastered
        return SRSCalculator.isDueForReview(progress);
      }).toList();
    }

    if (levelWords.isEmpty) {
      state = state.copyWith(status: VocabQuizStatus.finished);
      return;
    }

    final random = Random();
    levelWords.shuffle(random);
    final questions = levelWords.take(questionCount).toList();

    state = state.copyWith(
      status: VocabQuizStatus.playing,
      questions: questions,
      currentQuestionIndex: 0,
      lives: isUnlockTest
          ? 10
          : 3, // Unlock testte daha fazla can veya can sınırı olmamalı
      score: 0,
      level: level,
      currentWord: null,
      selectedAnswer: null,
      isUnlockTest: isUnlockTest,
      unlockTargetLevel: unlockTargetLevel,
      countryId: countryId,
      timeLeft: 10,
      maxTime: 10,
    );
    _setupCurrentQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        _timer?.cancel();
        _finishQuiz();
      }
    });
  }

  void _setupCurrentQuestion() {
    final word = state.questions[state.currentQuestionIndex];
    final random = Random();

    final countryId = ref
        .read(sharedPrefsServiceProvider)
        .getLanguageCountryId();
    final List<VocabWord> allWords = [...(vocabularyData[countryId] ?? [])];
    final userWords = ref
        .read(userVocabularyProvider.notifier)
        .getWordsForLevel(countryId, state.level);
    allWords.addAll(userWords);

    final levelWords = allWords.where((w) => w.level == state.level).toList();

    final wrongOptions = List<VocabWord>.from(levelWords)
      ..removeWhere((w) => w.id == word.id)
      ..shuffle(random);

    final options = <VocabWord>[word];
    options.addAll(wrongOptions.take(3));
    options.shuffle(random);

    state = state.copyWith(
      currentWord: word,
      options: options,
      status: VocabQuizStatus.playing,
      isLastAnswerCorrect: null,
      selectedAnswer: null,
    );
  }

  void submitAnswer(VocabWord? answer) {
    if (state.status != VocabQuizStatus.playing) return;
    _timer?.cancel();

    bool isCorrect = answer?.word == state.currentWord?.word;
    int newScore = state.score + (isCorrect ? 1 : 0);
    int newLives = state.lives - (isCorrect ? 0 : 1);

    if (!state.isUnlockTest && state.currentWord != null) {
      final sharedPrefs = ref.read(sharedPrefsServiceProvider);
      var progress =
          sharedPrefs.getWordProgress(state.currentWord!.id) ??
          WordProgress.initial(state.currentWord!.id);
      progress = SRSCalculator.processAnswer(progress, isCorrect);
      sharedPrefs.saveWordProgress(progress); // Async save
    }

    state = state.copyWith(
      status: VocabQuizStatus.answered,
      isLastAnswerCorrect: isCorrect,
      selectedAnswer: answer,
      score: newScore,
      lives: newLives,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (newLives <= 0 ||
          state.currentQuestionIndex >= state.questions.length - 1) {
        _finishQuiz();
      } else {
        state = state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1,
          timeLeft: 10,
        );
        _setupCurrentQuestion();
        _startTimer();
      }
    });
  }

  void _finishQuiz() {
    state = state.copyWith(status: VocabQuizStatus.finished);
    _handleQuizFinished();
  }

  void _handleQuizFinished() {
    // Add score to user's global progress
    ref.read(userProgressProvider.notifier).addScore(state.score);

    // Update Daily Missions
    ref.read(dailyMissionsProvider.notifier).updateProgress('quiz', 1);
    ref
        .read(dailyMissionsProvider.notifier)
        .updateProgress('score', state.score);
    ref
        .read(dailyMissionsProvider.notifier)
        .updateProgress('word', state.questions.length);

    // Check Vocab Achievements based on total score or count
    final totalXp = ref.read(userProgressProvider).score;
    if (totalXp >= 5000) {
      ref.read(achievementsProvider.notifier).unlockAchievement('vocab_1000');
    }
    if (totalXp >= 1000) {
      ref.read(achievementsProvider.notifier).unlockAchievement('vocab_100');
    }

    if (state.isUnlockTest &&
        state.unlockTargetLevel != null &&
        state.countryId != null) {
      final double maxPossibleScore = state.questions.length * 1.0;
      final double successPercentage = (state.score / maxPossibleScore) * 100.0;

      if (successPercentage >= 90) {
        final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
        final targetIndex = levels.indexOf(state.unlockTargetLevel!);
        if (targetIndex != -1) {
          final countryId = state.countryId!;
          final newLevel = targetIndex + 1;
          ref
              .read(sharedPrefsServiceProvider)
              .unlockLanguageLevel(countryId, newLevel);
          ref
              .read(languageLevelProvider.notifier)
              .updateLevel(countryId, newLevel);
        }
      }
    }
  }

  void reset() {
    state = const VocabQuizState();
  }
}

final vocabQuizProvider = NotifierProvider<VocabQuizNotifier, VocabQuizState>(
  () => VocabQuizNotifier(),
);
