import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vocabulary.dart';
import '../providers/shared_prefs_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/glass_container.dart';
import '../models/word_progress.dart';
import '../providers/user_vocabulary_provider.dart';

class MasteredWordsScreen extends ConsumerStatefulWidget {
  final String countryId;

  const MasteredWordsScreen({super.key, required this.countryId});

  @override
  ConsumerState<MasteredWordsScreen> createState() =>
      _MasteredWordsScreenState();
}

class _MasteredWordsScreenState extends ConsumerState<MasteredWordsScreen> {
  String _searchQuery = '';
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final fieldBg = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFF1F5F9); // Slate 100
    final fieldBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFE2E8F0); // Slate 200

    // Watch version to refresh when a word is removed
    ref.watch(wordProgressVersionProvider);

    final allWords = [...(vocabularyData[widget.countryId] ?? [])];
    final userWords = ref
        .read(userVocabularyProvider.notifier)
        .loadUserWordsForScreen(widget.countryId);
    allWords.addAll(userWords);

    final masteredWords = allWords.where((word) {
      final progress = sharedPrefs.getWordProgress(word.id);
      final isMastered = progress != null && progress.isMastered;
      if (!isMastered) return false;

      final isFavorite = progress.isFavorite;
      if (_showOnlyFavorites && !isFavorite) return false;

      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return word.word.toLowerCase().contains(query) ||
          word.translation.toLowerCase().contains(query);
    }).toList();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('mastered_words_title'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: l10n.translate('search_word_hint'),
                      hintStyle: TextStyle(
                        color: secondaryTextColor.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: secondaryTextColor.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: fieldBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: fieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: fieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      setState(() => _showOnlyFavorites = !_showOnlyFavorites),
                  icon: Icon(
                    _showOnlyFavorites
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: _showOnlyFavorites
                        ? const Color(0xFFF59E0B) // Amber 500
                        : secondaryTextColor.withValues(alpha: 0.5),
                  ),
                  tooltip: l10n.translate('filter_favorites'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: masteredWords.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (_searchQuery.isNotEmpty || _showOnlyFavorites)
                              ? Icons.search_off_rounded
                              : Icons.auto_awesome_rounded,
                          size: 64,
                          color: secondaryTextColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          (_searchQuery.isNotEmpty || _showOnlyFavorites)
                              ? l10n.translate('no_results_found')
                              : l10n.translate('no_mastered_words'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (_searchQuery.isNotEmpty || _showOnlyFavorites)
                              ? l10n.translate('no_results_desc')
                              : l10n.translate('no_mastered_desc'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: masteredWords.length,
                itemBuilder: (context, index) {
                  final word = masteredWords[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: GlassContainer(
                        borderRadius: 16,
                        color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
                        padding: EdgeInsets.zero,
                        child: ExpansionTile(
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          word.word,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: textColor,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                                            ),
                                          ),
                                          child: Text(
                                            word.level,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF6366F1),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          icon: Icon(
                                            sharedPrefs
                                                        .getWordProgress(
                                                          word.id,
                                                        )
                                                        ?.isFavorite ==
                                                     true
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: const Color(0xFFF59E0B),
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            final progress =
                                                sharedPrefs.getWordProgress(
                                                  word.id,
                                                ) ??
                                                WordProgress.initial(word.id);
                                            sharedPrefs.saveWordProgress(
                                              progress.copyWith(
                                                isFavorite:
                                                    !progress.isFavorite,
                                              ),
                                            );
                                            ref
                                                .read(
                                                  wordProgressVersionProvider
                                                      .notifier,
                                                )
                                                .increment();
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      word.translation,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? const Color(0xFF86EFAC)
                                            : const Color(0xFF059669), // Emerald 600
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: isDark ? Colors.redAccent : const Color(0xFFEF4444),
                              size: 22,
                            ),
                            onPressed: () {
                              _showUnmasterDialog(context, ref, word.id, l10n);
                            },
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    color: textColor.withValues(alpha: 0.1),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${l10n.translate('example_sentence_label')}:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    word.example,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
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
                },
              ),
      ),
    );
  }

  void _showUnmasterDialog(BuildContext context, WidgetRef ref, String wordId, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.translate('remove_word_title'),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          l10n.translate('remove_word_confirm'),
          style: TextStyle(
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.translate('cancel'),
              style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              final sharedPrefs = ref.read(sharedPrefsServiceProvider);
              final progress = sharedPrefs.getWordProgress(wordId);
              if (progress != null) {
                sharedPrefs.saveWordProgress(
                  progress.copyWith(isMastered: false),
                );
                ref.read(wordProgressVersionProvider.notifier).increment();
              }
              Navigator.pop(context);
            },
            child: Text(
              l10n.translate('yes_remove'),
              style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
