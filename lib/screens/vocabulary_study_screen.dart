import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vocabulary.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../providers/user_vocabulary_provider.dart';
import '../providers/vocabulary_load_provider.dart';
import '../models/word_progress.dart';
import '../services/sound_service.dart';
import '../providers/shared_prefs_provider.dart';

class VocabularyStudyScreen extends ConsumerStatefulWidget {
  final String countryId;
  final String level;

  const VocabularyStudyScreen({
    super.key,
    required this.countryId,
    required this.level,
  });

  @override
  ConsumerState<VocabularyStudyScreen> createState() =>
      _VocabularyStudyScreenState();
}

class _VocabularyStudyScreenState extends ConsumerState<VocabularyStudyScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _initialized = false;
  List<dynamic> _words = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initWords() {
    if (_initialized) return;
    final allWords = [...(vocabularyData[widget.countryId] ?? [])];

    // Add user words
    final userWords = ref
        .read(userVocabularyProvider.notifier)
        .getWordsForLevel(widget.countryId, widget.level);
    allWords.addAll(userWords);

    final sharedPrefs = ref.read(sharedPrefsServiceProvider);

    debugPrint(
      'Study Screen: Found ${allWords.length} total words (static + user) for country ${widget.countryId}',
    );

    final levelWords = allWords.where((w) => w.level == widget.level).toList();
    debugPrint(
      'Study Screen: Found ${levelWords.length} words for level ${widget.level}',
    );

    _words = levelWords.where((w) {
      final progress = sharedPrefs.getWordProgress(w.id);
      return progress == null || !progress.isMastered;
    }).toList();

    debugPrint(
      'Study Screen: ${(_words).length} words ready to study (after mastered filter)',
    );

    _initialized = true;
  }

  void _nextPage(int totalWords) {
    if (_currentIndex < totalWords - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ref.read(soundServiceProvider).playMove();
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ref.read(soundServiceProvider).playMove();
    }
  }

  Future<void> _markAsLearned(String wordId) async {
    final sharedPrefs = ref.read(sharedPrefsServiceProvider);
    var progress =
        sharedPrefs.getWordProgress(wordId) ?? WordProgress.initial(wordId);
    progress = progress.copyWith(isMastered: true);
    await sharedPrefs.saveWordProgress(progress);
    ref.read(wordProgressVersionProvider.notifier).increment();
    ref.read(soundServiceProvider).playCorrect();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.translate('learned_success_msg')),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    setState(() {
      _words.removeAt(_currentIndex);
      if (_currentIndex >= _words.length && _currentIndex > 0) {
        _currentIndex--;
      }
    });
  }

  Future<void> _toggleFavorite(String wordId) async {
    final sharedPrefs = ref.read(sharedPrefsServiceProvider);
    var progress =
        sharedPrefs.getWordProgress(wordId) ?? WordProgress.initial(wordId);
    progress = progress.copyWith(isFavorite: !progress.isFavorite);
    await sharedPrefs.saveWordProgress(progress);
    ref.read(wordProgressVersionProvider.notifier).increment();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vocabAsync = ref.watch(vocabularyLoadProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final progressBgColor = isDark
        ? textColor.withValues(alpha: 0.05)
        : const Color(0xFFE2E8F0);
    final helperColor = isDark
        ? textColor.withValues(alpha: 0.3)
        : const Color(0xFF475569);
    final studyCardBg = isDark
        ? Colors.blueAccent.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.96);
    final studyCardBorder = isDark
        ? Colors.blueAccent.withValues(alpha: 0.28)
        : const Color(0xFF334155).withValues(alpha: 0.16);
    final labelColor = isDark
        ? textColor.withValues(alpha: 0.35)
        : const Color(0xFF475569);
    final exampleColor = isDark
        ? textColor.withValues(alpha: 0.7)
        : const Color(0xFF1E293B);
    final dividerColor = isDark
        ? textColor.withValues(alpha: 0.05)
        : const Color(0xFFCBD5E1);
    final translationColor = isDark
        ? const Color(0xFF10B981)
        : const Color(0xFF047857);
    final chipBg = isDark
        ? textColor.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);
    final chipBorder = isDark
        ? textColor.withValues(alpha: 0.1)
        : const Color(0xFFCBD5E1);
    final bookmarkColor = isDark
        ? textColor.withValues(alpha: 0.3)
        : const Color(0xFF475569);
    if (!vocabAsync.hasValue) {
      return GradientScaffold(
        appBar: AppBar(
          title: Text(
            l10n.translate('study_words'),
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: Center(
          child: vocabAsync.hasError
              ? Text('${vocabAsync.error}')
              : const CircularProgressIndicator(),
        ),
      );
    }

    _initWords();
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    if (_words.isEmpty) {
      return GradientScaffold(
        appBar: AppBar(
          title: Text(
            l10n.translate('study_words'),
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: GlassContainer(
                borderRadius: 28,
                color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 64,
                      color: const Color(0xFF10B981), // Emerald 500
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.translate('great_job'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.translate('no_words_to_study'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: _StudyNavButton(
                        label: l10n.translate('back'),
                        icon: Icons.arrow_back_rounded,
                        accent: const Color(0xFF94A3B8),
                        enabled: true,
                        filled: true,
                        onTap: () => Navigator.pop(context),
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

    final progress = (_currentIndex + 1) / _words.length;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.translate('study_learn_suffix')} · ${widget.level}',
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_words.length}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: progressBgColor,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('dont_forget_learned'),
                style: TextStyle(
                  fontSize: 12,
                  color: helperColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _words.length,
                  itemBuilder: (context, index) {
                    final word = _words[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Center(
                          child: SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                                maxHeight: constraints.maxHeight,
                              ),
                              child: GlassContainer(
                                borderRadius: 28,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 22,
                                ),
                                color: studyCardBg,
                                border: Border.all(
                                  color: studyCardBorder,
                                  width: 1.5,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: chipBg,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: chipBorder,
                                            ),
                                          ),
                                          child: Text(
                                            word.level,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF6366F1),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _markAsLearned(word.id),
                                          icon: const Icon(
                                            Icons.bookmark_add_outlined,
                                          ),
                                          color: bookmarkColor,
                                          tooltip: l10n.translate('add_to_learned'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.translate('word_label'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w700,
                                        color: labelColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        word.word,
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: textColor,
                                          height: 1.15,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(color: dividerColor, height: 1),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.translate('meaning_label'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w700,
                                        color: labelColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      word.translation,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: translationColor,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(color: dividerColor, height: 1),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.translate('example_sentence_label'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w700,
                                        color: labelColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      word.example,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        color: exampleColor,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _toggleFavorite(word.id),
                                          icon: Icon(
                                            ref
                                                        .watch(
                                                          sharedPrefsServiceProvider,
                                                        )
                                                        .getWordProgress(
                                                          word.id,
                                                        )
                                                        ?.isFavorite ==
                                                    true
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: Colors.amber,
                                            size: 32,
                                          ),
                                        ),
                                        const Spacer(),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _markAsLearned(word.id),
                                          icon: const Icon(
                                            Icons.check_circle_outline_rounded,
                                          ),
                                          label: Text(l10n.translate('i_learned')),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF10B981,
                                            ).withValues(alpha: 0.1),
                                            foregroundColor: const Color(
                                              0xFF10B981,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              side: const BorderSide(
                                                color: Color(0xFF10B981),
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StudyNavButton(
                      label: l10n.translate('prev'),
                      icon: Icons.arrow_back_ios_new_rounded,
                      accent: const Color(0xFF94A3B8),
                      enabled: _currentIndex > 0,
                      filled: false,
                      onTap: _prevPage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StudyNavButton(
                      label: l10n.translate('next'),
                      icon: Icons.arrow_forward_ios_rounded,
                      accent: const Color(0xFF60A5FA),
                      enabled: _currentIndex < _words.length - 1,
                      filled: true,
                      onTap: () => _nextPage(_words.length),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final bool enabled;
  final bool filled;
  final VoidCallback onTap;

  const _StudyNavButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.enabled,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textOnButton = isDark ? Colors.white : const Color(0xFF0F172A);
    final disabledText = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : const Color(0xFF94A3B8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: filled && enabled
                ? LinearGradient(
                    colors: [
                      accent.withValues(alpha: isDark ? 0.45 : 0.28),
                      accent.withValues(alpha: isDark ? 0.22 : 0.16),
                    ],
                  )
                : null,
            color: (filled && enabled)
                ? null
                : accent.withValues(alpha: enabled ? (isDark ? 0.12 : 0.10) : 0.05),
            border: Border.all(
              color: accent.withValues(alpha: enabled ? (isDark ? 0.45 : 0.30) : 0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: enabled
                    ? textOnButton
                    : disabledText,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? textOnButton
                      : disabledText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
