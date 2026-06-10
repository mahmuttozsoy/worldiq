import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_progress_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Play confetti automatically if score > 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final score = ref.read(quizProvider).score;
      if (score > 0) {
        _confettiController.play();
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
    final quizState = ref.watch(quizProvider);
    final progress = ref.watch(userProgressProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return GradientScaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    quizState.score > 0 ? l10n.translate('perfect') : l10n.translate('game_over_loss'),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  GlassContainer(
                    borderRadius: 32,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Text(
                          l10n.translate('score_earned'),
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '+${quizState.score}',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10B981), // Emerald
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: textColor.withValues(alpha: 0.05)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${progress.level}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  l10n.translate('level'),
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${progress.streak}🔥',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  l10n.translate('streak'),
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(quizProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1), // Indigo
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      l10n.translate('play_again').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
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
              colors: const [
                Color(0xFF6366F1),
                Color(0xFF10B981),
                Color(0xFFF59E0B),
                Color(0xFFF43F5E),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
