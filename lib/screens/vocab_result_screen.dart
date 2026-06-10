import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../providers/vocab_quiz_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';

class VocabResultScreen extends ConsumerStatefulWidget {
  const VocabResultScreen({super.key});

  @override
  ConsumerState<VocabResultScreen> createState() => _VocabResultScreenState();
}

class _VocabResultScreenState extends ConsumerState<VocabResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(vocabQuizProvider);
      if (state.isUnlockTest) {
        final double maxPossibleScore = state.questions.length * 10.0;
        if ((state.score / maxPossibleScore) >= 0.9) _confettiController.play();
      } else {
        if (state.score > 0) _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(vocabQuizProvider);
    final double maxPossibleScore = state.questions.length * 10.0;
    final double percentage = (state.score / maxPossibleScore) * 100.0;
    final bool isSuccess = state.isUnlockTest ? percentage >= 90 : true;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF475569);

    return GradientScaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.isUnlockTest ? l10n.translate('challenge_result') : l10n.translate('test_completed'),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (state.isUnlockTest) ...[
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isSuccess ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.1),
                          border: Border.all(
                            color: (isSuccess ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isSuccess ? Icons.lock_open_rounded : Icons.lock_rounded,
                          color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isSuccess 
                          ? l10n.translate('level_unlocked_msg').replaceAll('{level}', state.unlockTargetLevel ?? '')
                          : l10n.translate('level_lock_failed'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isSuccess) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('unlock_requirement_msg').replaceAll('{percentage}', percentage.toStringAsFixed(1)),
                        style: TextStyle(fontSize: 15, color: secondaryTextColor, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 48),
                  ],
                  GlassContainer(
                    borderRadius: 32,
                    padding: const EdgeInsets.all(40),
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                    child: Column(
                      children: [
                        Text(
                          l10n.translate('your_score_label'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${state.score}',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: isSuccess ? (isDark ? Colors.greenAccent : const Color(0xFF059669)) : textColor,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.translate('total_questions_label').replaceAll('{count}', state.questions.length.toString()),
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(vocabQuizProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.transparent),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.translate('back_to_academy'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
