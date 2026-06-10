import 'dart:math';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_question.dart';
import '../models/country.dart';
import 'result_screen.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _showHint = false;
  String? _currentHint;

  void _generateRandomHint(List<String> hints) {
    if (hints.isEmpty) {
      _currentHint = null;
    } else {
      _currentHint = hints[Random().nextInt(hints.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    ref.listen<QuizState>(quizProvider, (previous, next) {
      if (next.status == QuizStateStatus.finished) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
      // Reset hint for new question
      if (previous?.currentQuestionIndex != next.currentQuestionIndex) {
        setState(() {
          _showHint = false;
          _currentHint = null;
        });
      }
    });

    if (state.status == QuizStateStatus.initial ||
        state.currentQuestion == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = state.currentQuestion!;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.translate('question_label')} ${state.currentQuestionIndex + 1}/10',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: const [],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _StatItem(
                                label: l10n.translate('time_label'),
                                value: '${state.timeLeft}s',
                                color: state.timeLeft <= 3 ? const Color(0xFFEF4444) : textColor,
                              ),
                              Row(
                                children: List.generate(3, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Icon(
                                      index < state.lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: index < state.lives ? const Color(0xFFF43F5E) : secondaryTextColor.withValues(alpha: 0.2),
                                      size: 18,
                                    ),
                                  );
                                }),
                              ),
                              _StatItem(
                                label: l10n.translate('score_label'),
                                value: state.score.toString(),
                                color: const Color(0xFF6366F1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: state.timeLeft / state.maxTime,
                              minHeight: 4,
                              backgroundColor: textColor.withValues(alpha: 0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                state.timeLeft <= (state.maxTime * 0.3) ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Unified Question Card
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                  child: child,
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey<int>(state.currentQuestionIndex),
                              child: GlassContainer(
                                borderRadius: 24,
                                padding: const EdgeInsets.all(20),
                                color: Colors.white.withValues(alpha: 0.05),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildQuestionTitle(question, l10n, textColor),
                                    const SizedBox(height: 20),
                                    _buildQuestionVisual(question, textColor, isDark),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildHintSection(question, l10n, textColor),
                      const SizedBox(height: 20),
                      // Options
                      Column(
                        children: [
                          ...question.options.map((option) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _OptionButton(
                                country: option,
                                questionType: question.type,
                                state: state,
                                onTap: () {
                                  if (state.status == QuizStateStatus.playing) {
                                    notifier.submitAnswer(option);
                                    Future.delayed(const Duration(seconds: 1), () {
                                      notifier.nextQuestion();
                                    });
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionTitle(QuizQuestion question, AppLocalizations l10n, Color textColor) {
    String msgKey;
    switch (question.type) {
      case QuizType.flagToCountry:
        msgKey = 'which_country_flag_msg';
        break;
      case QuizType.countryToContinent:
        msgKey = 'which_continent_msg';
        break;
      case QuizType.capitalToCountry:
        msgKey = 'which_country_capital_msg';
        break;
      case QuizType.plateToCity:
        msgKey = 'plate_to_city_msg';
        break;
      case QuizType.cityToPlate:
        msgKey = 'city_to_plate_msg';
        break;
      case QuizType.cityToRegion:
        msgKey = 'city_to_region_msg';
        break;
      case QuizType.regionToCity:
        msgKey = 'region_to_city_msg';
        break;
      default:
        msgKey = 'what_is_capital_msg';
    }
    return Text(
      l10n.translate(msgKey),
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildQuestionVisual(QuizQuestion question, Color textColor, bool isDark) {
    if (question.type == QuizType.flagToCountry) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 15))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(question.correctAnswer.flagPath, height: 140, width: 220, fit: BoxFit.cover),
          ),
        ),
      );
    }

    String mainText = '';
    Color mainColor = const Color(0xFF6366F1);

    switch (question.type) {
      case QuizType.countryToContinent:
        mainText = question.correctAnswer.name;
        mainColor = const Color(0xFF6366F1);
        break;
      case QuizType.capitalToCountry:
        mainText = question.correctAnswer.capital;
        mainColor = const Color(0xFFF59E0B);
        break;
      case QuizType.countryToCapital:
        mainText = question.correctAnswer.name;
        mainColor = const Color(0xFF8B5CF6);
        break;
      case QuizType.plateToCity:
        mainText = question.correctAnswer.plateCode!;
        mainColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
        break;
      case QuizType.cityToPlate:
      case QuizType.cityToRegion:
        mainText = question.correctAnswer.name;
        mainColor = const Color(0xFF10B981);
        break;
      case QuizType.regionToCity:
        mainText = question.correctAnswer.region!;
        mainColor = const Color(0xFFEF4444);
        break;
      default:
        mainText = question.correctAnswer.name;
    }

    if (question.type == QuizType.plateToCity) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B), width: 4),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
            const BoxShadow(color: Colors.white, blurRadius: 2, offset: Offset(-2, -2), spreadRadius: 0),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF003399),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TR', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Text(
              mainText,
              style: const TextStyle(
                fontSize: 84,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: 4,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      mainText,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: mainColor,
        letterSpacing: -0.5,
        shadows: [
          Shadow(color: mainColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 3))
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildHintSection(QuizQuestion question, AppLocalizations l10n, Color textColor) {
    List<String> availableHints = List.from(question.correctAnswer.hints);
    final String thisPlace = question.correctAnswer.plateCode != null ? l10n.translate('this_city') : l10n.translate('this_country');

    // Add fallback hints if empty or based on question type
    if (availableHints.isEmpty) {
      // Turkey specific fallbacks
      if (question.correctAnswer.region != null && question.type != QuizType.cityToRegion && question.type != QuizType.regionToCity) {
        availableHints.add(l10n.translate('hint_region_pattern').replaceAll('{region}', question.correctAnswer.region!));
      }
      if (question.correctAnswer.plateCode != null && question.type != QuizType.plateToCity && question.type != QuizType.cityToPlate) {
        availableHints.add(l10n.translate('hint_plate_pattern').replaceAll('{plate}', question.correctAnswer.plateCode!));
      }

      // Global specific fallbacks
      if (question.correctAnswer.capital.isNotEmpty && question.type != QuizType.capitalToCountry && question.type != QuizType.countryToCapital) {
        availableHints.add(l10n.translate('hint_capital_pattern').replaceAll('{capital}', question.correctAnswer.capital));
      }
      if (question.correctAnswer.continent.isNotEmpty && question.type != QuizType.countryToContinent) {
        availableHints.add(l10n.translate('hint_continent_pattern').replaceAll('{continent}', question.correctAnswer.continent));
      }
    }

    // Anonymize hints (Remove answer name)
    availableHints = availableHints.map((hint) {
      String anonymized = hint.replaceAll(question.correctAnswer.name, thisPlace);
      // Clean up common Turkish suffixes if name was replaced
      if (anonymized != hint) {
        anonymized = anonymized.replaceAll('ülkesinin', thisPlace).replaceAll('şehrinin', thisPlace);
      }
      return anonymized;
    }).toList();

    if (availableHints.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        if (!_showHint)
          TextButton.icon(
            onPressed: () {
              if (_currentHint == null) {
                _generateRandomHint(availableHints);
              }
              setState(() => _showHint = true);
            },
            icon: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 18),
            label: Text(
              l10n.translate('show_hint'),
              style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        if (_showHint && _currentHint != null)
          GestureDetector(
            onTap: () => setState(() => _showHint = false),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _currentHint!,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.5), letterSpacing: 1)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _OptionButton extends ConsumerWidget {
  final Country country;
  final QuizType questionType;
  final QuizState state;
  final VoidCallback onTap;

  const _OptionButton({required this.country, required this.questionType, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    Color getButtonColor() {
      if (state.status != QuizStateStatus.answered) return isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC);
      bool isThisCorrect = country.id == state.currentQuestion?.correctAnswer.id;
      bool isThisSelected = country.id == state.selectedAnswer?.id;
      
      if (isThisCorrect) return const Color(0xFF10B981).withValues(alpha: 0.1);
      if (isThisSelected) return const Color(0xFFEF4444).withValues(alpha: 0.1);
      return isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF1F5F9);
    }

    Color getBorderColor() {
      if (state.status != QuizStateStatus.answered) return isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0);
      bool isThisCorrect = country.id == state.currentQuestion?.correctAnswer.id;
      bool isThisSelected = country.id == state.selectedAnswer?.id;
      
      if (isThisCorrect) return const Color(0xFF10B981);
      if (isThisSelected) return const Color(0xFFEF4444);
      return Colors.transparent;
    }

    String getButtonText() {
      final l10n = AppLocalizations.of(context)!;
      switch (questionType) {
        case QuizType.flagToCountry:
        case QuizType.capitalToCountry:
        case QuizType.plateToCity:
        case QuizType.regionToCity:
          return l10n.translate(country.name);
        case QuizType.countryToContinent:
          return l10n.translate(country.continent);
        case QuizType.countryToCapital:
          return l10n.translate(country.capital);
        case QuizType.cityToPlate:
          return country.plateCode!;
        case QuizType.cityToRegion:
          return l10n.translate(country.region!);
      }
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: getBorderColor(), width: state.status == QuizStateStatus.answered ? 2.5 : 1.5),
                boxShadow: state.status == QuizStateStatus.answered && (country.id == state.currentQuestion?.correctAnswer.id || country.id == state.selectedAnswer?.id)
                    ? [BoxShadow(color: getBorderColor().withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]
                    : [],
              ),
              child: GlassContainer(
                borderRadius: 24,
                color: getButtonColor(),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        getButtonText(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (state.status == QuizStateStatus.answered && (country.id == state.currentQuestion?.correctAnswer.id || country.id == state.selectedAnswer?.id))
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.elasticOut,
                        builder: (context, val, child) {
                          return Transform.scale(
                            scale: val,
                            child: Icon(
                              country.id == state.currentQuestion?.correctAnswer.id ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: country.id == state.currentQuestion?.correctAnswer.id ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              size: 20,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
