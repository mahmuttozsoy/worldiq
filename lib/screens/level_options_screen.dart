import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';
import '../providers/vocab_quiz_provider.dart';
import '../providers/user_vocabulary_provider.dart';
import '../data/vocabulary.dart';
import 'vocab_quiz_screen.dart';
import 'vocabulary_study_screen.dart';
import 'mastered_words_screen.dart';
import 'add_word_screen.dart';
import '../providers/shared_prefs_provider.dart';

String _levelSubtitle(String level, AppLocalizations l10n) {
  switch (level) {
    case 'A1':
      return l10n.translate('level_a1_desc');
    case 'A2':
      return l10n.translate('level_a2_desc');
    case 'B1':
      return l10n.translate('level_b1_desc');
    case 'B2':
      return l10n.translate('level_b2_desc');
    case 'C1':
      return l10n.translate('level_c1_desc');
    case 'C2':
      return l10n.translate('level_c2_desc');
    default:
      return l10n.translate('level_default_desc');
  }
}

/// Açık bir CEFR seviyesi için çalışma modu seçimi — tam genişlik panel, gelişmiş ilerleme göstergesi.
class LevelOptionsScreen extends ConsumerWidget {
  final String countryId;
  final String level;

  const LevelOptionsScreen({
    super.key,
    required this.countryId,
    required this.level,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pad = MediaQuery.paddingOf(context);
    final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? Colors.white60
        : const Color(0xFF475569);

    // Listen to version changes to trigger rebuild
    ref.watch(wordProgressVersionProvider);

    // Progress calculation
    final allWords = [...(vocabularyData[countryId] ?? [])];
    final userWords = ref
        .read(userVocabularyProvider.notifier)
        .getWordsForLevel(countryId, level);
    allWords.addAll(userWords);

    final levelWords = allWords.where((w) => w.level == level).toList();
    final totalWords = levelWords.length;

    int masteredWordsCount = 0;
    if (totalWords > 0) {
      masteredWordsCount = levelWords.where((word) {
        final progress = sharedPrefs.getWordProgress(word.id);
        return progress != null && progress.isMastered;
      }).length;
    }

    final progressPercent = totalWords > 0
        ? (masteredWordsCount / totalWords)
        : 0.0;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('level_suffix').replaceAll('{level}', level),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              size: 22,
              color: textColor.withValues(alpha: 0.7),
            ),
            onPressed: () => _confirmReset(context, ref, levelWords, l10n),
            tooltip: l10n.translate('reset_progress'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(18, 6, 18, 14 + pad.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GlassContainer(
                borderRadius: 32,
                border: Border.all(
                  color: Colors.transparent,
                ), // Çerçeveyi kaldırdık
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        // Level Indicator with Hero-like feel
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: textColor.withValues(alpha: 0.05),
                              border: Border.all(
                                color: textColor.withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [textColor, const Color(0xFF6366F1)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds),
                                child: Text(
                                  level,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _levelSubtitle(level, l10n),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n
                              .translate('words_count_msg')
                              .replaceAll('{count}', totalWords.toString()),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Progress Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.translate('level_progress'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '%${(progressPercent * 100).toInt()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: textColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutCubic,
                                  height: 10,
                                  width:
                                      (constraints.maxWidth - 48) *
                                      progressPercent,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF818CF8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n
                                  .translate('words_learned_msg')
                                  .replaceAll(
                                    '{mastered}',
                                    masteredWordsCount.toString(),
                                  )
                                  .replaceAll('{total}', totalWords.toString()),
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Action Cards
                        _ActionCard(
                          title: l10n.translate('learn_words'),
                          subtitle: l10n.translate('learn_words_desc'),
                          icon: Icons.menu_book_rounded,
                          accent: const Color(0xFF60A5FA),
                          delayMs: 200,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VocabularyStudyScreen(
                                  countryId: countryId,
                                  level: level,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: l10n.translate('test_yourself'),
                          subtitle: l10n.translate('test_yourself_desc'),
                          icon: Icons.quiz_rounded,
                          accent: const Color(0xFF4ADE80),
                          delayMs: 400,
                          onTap: () => _showQuizCountPicker(
                            context,
                            ref,
                            countryId,
                            level,
                            false,
                            l10n: l10n,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: l10n.translate('mastered_words_title'),
                          subtitle: l10n.translate('mastered_words_desc'),
                          icon: Icons.bookmarks_rounded,
                          accent: const Color(0xFFC4B5FD),
                          delayMs: 600,
                          onTap: () {
                            _showMasteredOptions(
                              context,
                              ref,
                              countryId,
                              level,
                              masteredWordsCount,
                              l10n,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _ActionCard(
                          title: l10n.translate('add_custom_word'),
                          subtitle: l10n.translate('add_custom_word_desc'),
                          icon: Icons.add_circle_outline_rounded,
                          accent: const Color(0xFFF87171),
                          delayMs: 800,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddWordScreen(
                                  countryId: countryId,
                                  level: level,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMasteredOptions(
    BuildContext context,
    WidgetRef ref,
    String countryId,
    String level,
    int count,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subTextColor = isDark
            ? Colors.white.withValues(alpha: 0.55)
            : const Color(0xFF475569);
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            14,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF94A3B8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.bookmarks_rounded,
                    color: Color(0xFFC4B5FD),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('mastered_words_title'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          l10n
                              .translate('words_learned_msg')
                              .replaceAll('{mastered}', count.toString())
                              .replaceAll(
                                '{total}',
                                '',
                              ), // We don't have total here but words_learned_msg is flexible
                          style: TextStyle(fontSize: 13, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _BottomSheetAction(
                title: l10n.translate('view_word_list'),
                subtitle: l10n.translate('view_word_list_desc'),
                icon: Icons.list_alt_rounded,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MasteredWordsScreen(countryId: countryId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _BottomSheetAction(
                title: l10n.translate('practice_test'),
                subtitle: l10n.translate('practice_test_desc'),
                icon: Icons.psychology_rounded,
                color: const Color(0xFFF472B6),
                onTap: () {
                  Navigator.pop(context);
                  _showQuizCountPicker(
                    context,
                    ref,
                    countryId,
                    level,
                    true,
                    masteredCount: count,
                    l10n: l10n,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuizCountPicker(
    BuildContext context,
    WidgetRef ref,
    String countryId,
    String level,
    bool isReview, {
    int? masteredCount,
    required AppLocalizations l10n,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final helperColor = isDark
            ? Colors.white.withValues(alpha: 0.55)
            : const Color(0xFF475569);
        final cardBg = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : const Color(0xFFF8FAFC);
        final cardBorder = isDark
            ? Colors.white.withValues(alpha: 0.2)
            : const Color(0xFFCBD5E1);
        final disabledBg = isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFE2E8F0);
        final disabledText = isDark
            ? Colors.white.withValues(alpha: 0.45)
            : const Color(0xFF94A3B8);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            14,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFF94A3B8),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('select_question_count'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [20, 50, 100].map((count) {
                  final bool disabled =
                      isReview &&
                      masteredCount != null &&
                      masteredCount < count;
                  return InkWell(
                    onTap: disabled
                        ? null
                        : () async {
                            Navigator.pop(context);
                            ref
                                .read(vocabQuizProvider.notifier)
                                .startQuiz(
                                  countryId,
                                  level,
                                  isMasteredReview: isReview,
                                  questionCount: count,
                                );

                            final quizState = ref.read(vocabQuizProvider);
                            if (quizState.status ==
                                VocabQuizStatus.finished) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.translate('not_enough_words'),
                                  ),
                                ),
                              );
                            } else {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VocabQuizScreen(),
                                ),
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: disabled ? disabledBg : cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: disabled
                              ? cardBorder.withValues(alpha: 0.7)
                              : cardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: disabled ? disabledText : titleColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (isReview) ...[
                const SizedBox(height: 16),
                Text(
                  l10n
                      .translate('words_learned_msg')
                      .replaceAll('{mastered}', masteredCount.toString())
                      .replaceAll('{total}', ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: helperColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _confirmReset(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> levelWords,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? Colors.white60
        : const Color(0xFF475569);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          l10n.translate('reset_progress'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
        ),
        content: Text(
          l10n.translate('reset_progress_confirm').replaceAll('{level}', level),
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              final sharedPrefs = ref.read(sharedPrefsServiceProvider);
              for (var word in levelWords) {
                final progress = sharedPrefs.getWordProgress(word.id);
                if (progress != null) {
                  sharedPrefs.saveWordProgress(
                    progress.copyWith(isMastered: false),
                  );
                }
              }
              ref.read(wordProgressVersionProvider.notifier).increment();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.translate('reset_success'))),
              );
            },
            child: Text(
              l10n
                  .translate('reset_progress')
                  .split(' ')
                  .last, // Use a part of it or just add 'reset' key
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BottomSheetAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF475569);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFCBD5E1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : const Color(0xFF94A3B8),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final int delayMs;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.delayMs = 0,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? Colors.white60
        : const Color(0xFF475569);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDark ? null : Colors.white.withValues(alpha: 0.5),
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.accent.withValues(alpha: 0.25),
                            widget.accent.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: isDark
                        ? widget.accent.withValues(alpha: 0.3)
                        : widget.accent.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.accent.withValues(
                              alpha: isDark ? 0.3 : 0.15,
                            ),
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: textColor.withValues(alpha: 0.2),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
