import 'package:world_iq/providers/l10n_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocab_quiz_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import 'vocab_result_screen.dart';
import '../services/sound_service.dart';
import '../models/vocab_word.dart';

class VocabQuizScreen extends ConsumerWidget {
  const VocabQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<VocabQuizState>(vocabQuizProvider, (previous, next) {
      if (next.status == VocabQuizStatus.finished) {
        ref.read(soundServiceProvider).playFinish();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VocabResultScreen()),
        );
      }
    });

    final state = ref.watch(vocabQuizProvider);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    if (state.status == VocabQuizStatus.initial || state.currentWord == null) {
      return GradientScaffold(
        appBar: AppBar(
          title: Text(
            l10n.translate('vocab_quiz_title'),
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(
                  vertical: 36,
                  horizontal: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.translate('preparing_questions'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final qIndex = state.currentQuestionIndex + 1;
    final qTotal = state.questions.length;
    final progress = qTotal > 0 ? qIndex / qTotal : 0.0;
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('vocab_quiz_title'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 4, 18, 8 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                i < state.lives
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: i < state.lives
                                    ? const Color(0xFFF43F5E) // Rose 500
                                    : textColor.withValues(alpha: 0.1),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            state.level,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF6366F1),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${state.score} ${l10n.translate('pts_label')}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          l10n.translate('question_count_msg')
                              .replaceAll('{index}', qIndex.toString())
                              .replaceAll('{total}', qTotal.toString()),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: textColor.withValues(alpha: 0.05),
                              color: const Color(0xFF10B981), // Emerald 500
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Timer Progress Bar
                    Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 16,
                          color: state.timeLeft <= 3 ? const Color(0xFFEF4444) : secondaryTextColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: state.timeLeft / state.maxTime,
                              minHeight: 6,
                              backgroundColor: textColor.withValues(alpha: 0.05),
                              color: state.timeLeft <= 3 
                                  ? const Color(0xFFEF4444) 
                                  : const Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${state.timeLeft}${l10n.translate('timeLeft_label')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: state.timeLeft <= 3 ? const Color(0xFFEF4444) : textColor,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Fixed space for feedback banner - slightly more compact
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: state.status == VocabQuizStatus.answered
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _AnswerFeedbackBanner(state: state),
                      )
                    : const SizedBox(height: 0),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                borderRadius: 28,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    Text(
                      l10n.translate('meaning_prompt'),
                      style: TextStyle(
                        fontSize: 14,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        state.currentWord!.word,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: List.generate(state.options.length, (index) {
                  final option = state.options[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuizOptionTile(
                      word: option,
                      state: state,
                      onTap: () {
                        if (state.status == VocabQuizStatus.playing) {
                          final isCorrect = option.word == state.currentWord?.word;
                          if (isCorrect) {
                            ref.read(soundServiceProvider).playCorrect();
                          } else {
                            ref.read(soundServiceProvider).playWrong();
                          }
                          ref
                              .read(vocabQuizProvider.notifier)
                              .submitAnswer(option);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                color: textColor.withValues(alpha: 0.03),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('usage_in_sentence'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFF59E0B),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.status == VocabQuizStatus.playing
                                ? state.currentWord!.example.replaceAll(
                                    RegExp(state.currentWord!.word, caseSensitive: false),
                                    '______',
                                  )
                                : state.currentWord!.example,
                            style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: textColor.withValues(alpha: 0.8),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerFeedbackBanner extends ConsumerWidget {
  final VocabQuizState state;

  const _AnswerFeedbackBanner({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final correct = state.isLastAnswerCorrect == true;
    final translation = state.currentWord?.translation ?? '';

    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 20,
      color: correct
          ? const Color(0xFF10B981).withValues(alpha: 0.15)
          : const Color(0xFFEF4444).withValues(alpha: 0.1),
      border: Border.all(
        color: correct
            ? const Color(0xFF10B981).withValues(alpha: 0.3)
            : const Color(0xFFEF4444).withValues(alpha: 0.2),
        width: 1.5,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: correct ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            child: Icon(
              correct ? Icons.check_rounded : Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  correct ? l10n.translate('congrats') : l10n.translate('correct_answer_label'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: correct ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  correct ? l10n.translate('awesome_msg') : translation,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  final VocabWord word;
  final VocabQuizState state;
  final VoidCallback onTap;

  const _QuizOptionTile({
    required this.word,
    required this.state,
    required this.onTap,
  });

  Color _fillColor(bool isDark) {
    if (state.status == VocabQuizStatus.answered) {
      if (word.word == state.currentWord?.word) {
        return const Color(0xFF10B981).withValues(alpha: 0.15);
      }
      if (word.word == state.selectedAnswer?.word) {
        return const Color(0xFFEF4444).withValues(alpha: 0.1);
      }
    }
    return isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9);
  }

  Color _borderColor(bool isDark) {
    if (state.status == VocabQuizStatus.answered) {
      if (word.word == state.currentWord?.word) {
        return const Color(0xFF10B981);
      }
      if (word.word == state.selectedAnswer?.word) {
        return const Color(0xFFEF4444);
      }
    }
    return isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state.status == VocabQuizStatus.playing ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          color: _fillColor(isDark),
          border: Border.all(color: _borderColor(isDark), width: 1.5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  word.translation,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (state.status == VocabQuizStatus.answered) ...[
                if (word.word == state.currentWord?.word)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24)
                else if (word.word == state.selectedAnswer?.word)
                  const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
