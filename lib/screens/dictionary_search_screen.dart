import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/dictionary_result.dart';
import '../models/vocab_word.dart';
import '../services/dictionary_service.dart';
import '../services/sound_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';
import '../providers/user_vocabulary_provider.dart';

class DictionarySearchScreen extends ConsumerStatefulWidget {
  final String countryId;

  const DictionarySearchScreen({
    super.key,
    required this.countryId,
  });

  @override
  ConsumerState<DictionarySearchScreen> createState() => _DictionarySearchScreenState();
}

class _DictionarySearchScreenState extends ConsumerState<DictionarySearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  DictionaryResult? _result;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _hasSearched = true;
    });

    try {
      final res = await DictionaryService.lookupWord(query);
      setState(() {
        _result = res;
      });
      
      if (res == null) {
        ref.read(soundServiceProvider).playError();
      } else {
        ref.read(soundServiceProvider).playClick();
      }
    } catch (e) {
      ref.read(soundServiceProvider).playError();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during search: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddLevelSheet(DictionaryResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtitleColor = isDark ? Colors.white60 : const Color(0xFF475569);
        final levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
        final levelDescriptions = {
          'A1': 'Beginner',
          'A2': 'Elementary',
          'B1': 'Intermediate',
          'B2': 'Upper Intermediate',
          'C1': 'Advanced',
          'C2': 'Expert',
        };

        // Level renkleri
        final levelColors = {
          'A1': const Color(0xFF10B981), // Yeşil - Başlangıç
          'A2': const Color(0xFF34D399),
          'B1': const Color(0xFF6366F1), // İndigo - Orta
          'B2': const Color(0xFF818CF8),
          'C1': const Color(0xFFF59E0B), // Amber - İleri
          'C2': const Color(0xFFEF4444), // Kırmızı - Uzman
        };

        return Container(
          decoration: BoxDecoration(
            // Tamamen opak arka plan - şeffaflık yok
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // İkon + Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.library_add_rounded,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Level',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Add "${result.word}" to Vocabulary',
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Seviye ızgarası
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final lvl = levels[index];
                  final lvlColor = levelColors[lvl] ?? const Color(0xFF6366F1);
                  final desc = levelDescriptions[lvl] ?? '';

                  return InkWell(
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      final vocabWord = VocabWord(
                        id: 'user_${const Uuid().v4()}',
                        word: result.word,
                        translation: result.translation.isNotEmpty
                            ? result.translation
                            : result.word,
                        type: result.type,
                        example: result.example,
                        level: lvl,
                      );

                      await ref.read(userVocabularyProvider.notifier).addUserWord(
                            widget.countryId,
                            vocabWord,
                          );

                      ref.read(soundServiceProvider).playCorrect();
                      navigator.pop();

                      messenger.showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('"${result.word}" added to $lvl!'),
                              ),
                            ],
                          ),
                          backgroundColor: lvlColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: lvlColor.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: lvlColor.withValues(alpha: isDark ? 0.45 : 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: lvlColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              lvl,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: lvlColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // İptal butonu
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final searchBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);
    final searchBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFE2E8F0);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          'Advanced Dictionary Search',
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Search Input Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: searchBorder, width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _performSearch(),
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Aramak istediğiniz kelimeyi girin...',
                          hintStyle: TextStyle(
                            color: secondaryTextColor.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: secondaryTextColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search Button
                  InkWell(
                    onTap: _isLoading ? null : _performSearch,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Result Area
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _result != null
                            ? _buildResultCard(textColor, secondaryTextColor, isDark)
                            : _buildStatePrompt(textColor, secondaryTextColor),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(Color textColor, Color secondaryTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.all(24),
          color: isDark ? null : Colors.white,
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            width: 1.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Word, phonetic and Speaker icon
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _result!.word,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -1,
                          ),
                        ),
                        if (_result!.phonetic != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _result!.phonetic!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_result!.audioUrl != null)
                    InkWell(
                      onTap: () {
                        ref.read(soundServiceProvider).playRemote(_result!.audioUrl!);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFF6366F1),
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Word type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  _result!.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6366F1),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(height: 1, color: Colors.black12),
              const SizedBox(height: 20),

              // Turkish Translation Card
              Text(
                'TÜRKÇE ANLAMI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: secondaryTextColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF10B981).withValues(alpha: 0.15), Colors.transparent]
                        : [const Color(0xFFE6FDF4), const Color(0xFFF0FDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  _result!.translation.isNotEmpty
                      ? _result!.translation
                      : 'Lütfen kelime tanımına bakarak manuel doldurun.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _result!.translation.isNotEmpty
                        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
                        : secondaryTextColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // English Definition Card
              Text(
                'ENGLISH DEFINITION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: secondaryTextColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: textColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  _result!.definition,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Example Sentence Card
              if (_result!.example.isNotEmpty) ...[
                Text(
                  'USAGE EXAMPLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: secondaryTextColor,
                    letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: textColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  _result!.example,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Add Button
        ElevatedButton.icon(
          onPressed: () => _showAddLevelSheet(_result!),
          icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
          label: const Text('KELİME HAZNEME EKLE'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatePrompt(Color textColor, Color secondaryTextColor) {
    if (!_hasSearched) {
      return Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: Color(0xFF6366F1),
              ),
              const SizedBox(height: 20),
              Text(
                'Dünya Çapında Kelimeler!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Arama motorunu kullanarak milyonlarca İngilizce kelimeyi sorgulayabilir, sesli okunuşlarını dinleyebilir ve tek tıkla seviyenize ekleyebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Searched but got null result (Not found)
      return Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: GlassContainer(
          borderRadius: 28,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.redAccent.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 20),
              Text(
                'Word Not Found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The word you entered was not found in the dictionary. Please check for spelling mistakes and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
