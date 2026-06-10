import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/country.dart';
import '../models/quiz_question.dart';
import '../data/countries.dart';
import '../data/turkey_cities.dart';
import 'user_progress_provider.dart';
import 'daily_missions_provider.dart';
import 'audio_provider.dart';
import 'achievements_provider.dart';
import '../services/sound_service.dart';

enum QuizStateStatus { initial, playing, answered, finished }

class QuizState {
  final QuizStateStatus status;
  final QuizQuestion? currentQuestion;
  final int currentQuestionIndex;
  final int score;
  final int timeLeft;
  final bool? isLastAnswerCorrect;
  final Country? selectedAnswer;
  final int lives;
  final QuizDifficulty difficulty;
  final int maxTime;

  QuizState({
    this.status = QuizStateStatus.initial,
    this.currentQuestion,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.timeLeft = 10,
    this.isLastAnswerCorrect,
    this.selectedAnswer,
    this.lives = 3,
    this.difficulty = QuizDifficulty.medium,
    this.maxTime = 10,
  });

  QuizState copyWith({
    QuizStateStatus? status,
    QuizQuestion? currentQuestion,
    int? currentQuestionIndex,
    int? score,
    int? timeLeft,
    bool? isLastAnswerCorrect,
    Country? selectedAnswer,
    int? lives,
    QuizDifficulty? difficulty,
    int? maxTime,
  }) {
    return QuizState(
      status: status ?? this.status,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      isLastAnswerCorrect: isLastAnswerCorrect,
      selectedAnswer: selectedAnswer,
      lives: lives ?? this.lives,
      difficulty: difficulty ?? this.difficulty,
      maxTime: maxTime ?? this.maxTime,
    );
  }
}

class QuizNotifier extends Notifier<QuizState> {
  Timer? _timer;
  List<QuizQuestion> _questions = [];

  @override
  QuizState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return QuizState();
  }

  void startQuiz(QuizType type, QuizDifficulty difficulty) {
    int time = difficulty == QuizDifficulty.easy
        ? 15
        : (difficulty == QuizDifficulty.hard ? 5 : 10);
    _generateQuestions(type, difficulty);
    state = QuizState(
      status: QuizStateStatus.playing,
      currentQuestion: _questions[0],
      currentQuestionIndex: 0,
      score: 0,
      timeLeft: time,
      maxTime: time,
      lives: 3,
      difficulty: difficulty,
    );
    _startTimer();
  }

  void _generateQuestions(QuizType type, QuizDifficulty difficulty) {
    final random = Random();
    _questions = [];

    // Handle Turkey-specific quizzes
    bool isTurkeyQuiz = type == QuizType.plateToCity ||
        type == QuizType.cityToPlate ||
        type == QuizType.cityToRegion ||
        type == QuizType.regionToCity;

    if (isTurkeyQuiz) {
      List<Country> turkeyPool = turkeyCities.map((city) {
        return Country(
          id: city.plate,
          name: city.name,
          flagPath: '', // No flag for cities
          continent: city.region,
          plateCode: city.plate,
          region: city.region,
          hints: city.hints,
        );
      }).toList();

      turkeyPool.shuffle(random);

      for (int i = 0; i < 10; i++) {
        if (i >= turkeyPool.length) break;
        Country correct = turkeyPool[i];
        List<Country> options = [correct];

        // Generate distractors
        List<Country> others = List.from(turkeyPool)
          ..removeWhere((c) => c.id == correct.id)
          ..shuffle(random);

        if (type == QuizType.cityToRegion || type == QuizType.regionToCity) {
          // District regions distractors
          Set<String> usedRegions = {correct.region!};
          for (var o in others) {
            if (!usedRegions.contains(o.region!)) {
              usedRegions.add(o.region!);
              options.add(o);
            }
            if (options.length == 4) {
              break;
            }
          }
        } else {
          options.addAll(others.take(3));
        }

        options.shuffle(random);
        _questions.add(
          QuizQuestion(
            id: 'tr_q_$i',
            type: type,
            correctAnswer: correct,
            options: options,
          ),
        );
      }
      return;
    }

    List<Country> pool = List.from(
      countriesData.where((c) => c.difficulty == difficulty),
    );
    if (pool.length < 10) {
      pool = List.from(
        countriesData,
      ); // Fallback in case pool is too small somehow
    }

    if (type == QuizType.capitalToCountry ||
        type == QuizType.countryToCapital) {
      pool.removeWhere((c) => c.capital.isEmpty);
    }
    pool.shuffle(random);

    for (int i = 0; i < 10; i++) {
      if (i >= pool.length) break;
      Country correct = pool[i];

      List<Country> options = [correct];

      if (type == QuizType.countryToContinent) {
        Set<String> usedContinents = {correct.continent};
        List<Country> shuffledData = List.from(countriesData)..shuffle(random);

        for (var c in shuffledData) {
          if (!usedContinents.contains(c.continent)) {
            usedContinents.add(c.continent);
            options.add(c);
          }
          if (options.length == 4) {
            break;
          }
        }
      } else if (type == QuizType.capitalToCountry ||
          type == QuizType.countryToCapital) {
        Set<String> usedCapitals = {correct.capital};
        List<Country> shuffledData = List.from(pool)..shuffle(random);

        for (var c in shuffledData) {
          if (!usedCapitals.contains(c.capital) && c.id != correct.id) {
            usedCapitals.add(c.capital);
            options.add(c);
          }
          if (options.length == 4) {
            break;
          }
        }
      } else {
        // flagToCountry
        List<Country> others = List.from(pool)
          ..removeWhere((c) => c.id == correct.id)
          ..shuffle(random);
        options.addAll(others.take(3));
      }

      options.shuffle(random);

      _questions.add(
        QuizQuestion(
          id: 'q_$i',
          type: type,
          correctAnswer: correct,
          options: options,
        ),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(
          timeLeft: state.timeLeft - 1,
          isLastAnswerCorrect: state.isLastAnswerCorrect,
          selectedAnswer: state.selectedAnswer,
        );
      } else {
        // Time's up - Game Over
        _timer?.cancel();
        _finishQuiz();
      }
    });
  }

  void submitAnswer(Country? answer) {
    if (state.status != QuizStateStatus.playing) return;
    _timer?.cancel();

    bool isCorrect = answer?.id == state.currentQuestion?.correctAnswer.id;
    int points = state.difficulty == QuizDifficulty.easy
        ? 1
        : (state.difficulty == QuizDifficulty.hard ? 2 : 1);
    int newScore = state.score + (isCorrect ? points : 0);

    int lifePenalty = state.difficulty == QuizDifficulty.hard ? 2 : 1;
    int newLives = state.lives - (isCorrect ? 0 : lifePenalty);

    state = state.copyWith(
      status: QuizStateStatus.answered,
      score: newScore,
      lives: newLives,
      isLastAnswerCorrect: isCorrect,
      selectedAnswer: answer,
    );

    if (isCorrect) {
      ref.read(soundServiceProvider).playCorrect();
    } else {
      ref.read(soundServiceProvider).playWrong();
    }
  }

  void nextQuestion() {
    if (state.lives <= 0) {
      _finishQuiz();
      return;
    }

    if (state.currentQuestionIndex < _questions.length - 1) {
      int nextIndex = state.currentQuestionIndex + 1;
      state = QuizState(
        status: QuizStateStatus.playing,
        currentQuestion: _questions[nextIndex],
        currentQuestionIndex: nextIndex,
        score: state.score,
        timeLeft: state.maxTime,
        maxTime: state.maxTime,
        lives: state.lives,
        difficulty: state.difficulty,
      );
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    state = state.copyWith(
      status: QuizStateStatus.finished,
      isLastAnswerCorrect: state.isLastAnswerCorrect,
      selectedAnswer: state.selectedAnswer,
    );

    ref.read(userProgressProvider.notifier).addScore(state.score);
    ref.read(audioProvider.notifier).playFinish();

    // Update Daily Missions
    ref.read(dailyMissionsProvider.notifier).updateProgress('quiz', 1);
    ref
        .read(dailyMissionsProvider.notifier)
        .updateProgress('score', state.score);

    final achProvider = ref.read(achievementsProvider.notifier);
    final finalUserProgress = ref.read(userProgressProvider);
    achProvider.unlockAchievement('first_game');

    if (finalUserProgress.score >= 500) {
      achProvider.unlockAchievement('score_500');
    }
    if (finalUserProgress.streak >= 10) {
      achProvider.unlockAchievement('streak_10');
    }
    if (state.lives == 3 && state.score == 100) {
      achProvider.unlockAchievement('perfect_game');
    }
  }

  void reset() {
    state = QuizState();
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});
