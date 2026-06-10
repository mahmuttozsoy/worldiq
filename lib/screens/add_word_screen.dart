import 'package:flutter/material.dart';
import 'package:world_iq/providers/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/vocab_word.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';
import '../providers/user_vocabulary_provider.dart';
import '../services/dictionary_service.dart';
import '../services/sound_service.dart';
import '../models/dictionary_result.dart';

class AddWordScreen extends ConsumerStatefulWidget {
  final String countryId;
  final String level;

  const AddWordScreen({
    super.key,
    required this.countryId,
    required this.level,
  });

  @override
  ConsumerState<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends ConsumerState<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _exampleController = TextEditingController();
  String _selectedType = 'noun';
  bool _isSearching = false;
  DictionaryResult? _searchedResult;

  final List<String> _wordTypes = [
    'noun',
    'verb',
    'adjective',
    'adverb',
    'phrase',
    'other'
  ];

  Future<void> _lookupWord() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.translate('please_enter_word')),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searchedResult = null;
    });

    try {
      final result = await DictionaryService.lookupWord(word);
      if (result != null) {
        setState(() {
          _searchedResult = result;
          _selectedType = result.type;
          if (result.translation.isNotEmpty) {
            _translationController.text = result.translation;
          }
          if (result.example.isNotEmpty) {
            _exampleController.text = result.example;
          }
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dictionary data filled successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        if (result.audioUrl != null) {
          ref.read(soundServiceProvider).playRemote(result.audioUrl!);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Word not found in dictionary. Please enter manually.'),
            backgroundColor: Colors.amber,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  Future<void> _saveWord() async {
    if (_formKey.currentState!.validate()) {
      final newWord = VocabWord(
        id: 'user_${const Uuid().v4()}',
        word: _wordController.text.trim(),
        translation: _translationController.text.trim(),
        type: _selectedType,
        example: _exampleController.text.trim(),
        level: widget.level,
      );

      await ref.read(userVocabularyProvider.notifier).addUserWord(
            widget.countryId,
            newWord,
          );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('add_word_success')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF475569);
    final inputBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF8FAFC); // Slate 50
    final inputBorder = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFE2E8F0); // Slate 200

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('add_new_word_title'),
          style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassContainer(
                borderRadius: 32,
                color: isDark ? null : const Color(0xFFF8FAFC), // Slate 50
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('add_word_desc').replaceAll('{level}', widget.level),
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _wordController,
                      label: l10n.translate('word_input_label'),
                      hint: 'e.g. Adventure',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      inputBg: inputBg,
                      inputBorder: inputBorder,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.translate('word_error') : null,
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF6366F1),
                              ),
                              tooltip: 'Get from Dictionary',
                              onPressed: _lookupWord,
                            ),
                    ),
                    if (_searchedResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _searchedResult!.word,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                if (_searchedResult!.phonetic != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    _searchedResult!.phonetic!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                if (_searchedResult!.audioUrl != null)
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.volume_up_rounded,
                                      color: Color(0xFF6366F1),
                                    ),
                                    onPressed: () {
                                      ref.read(soundServiceProvider).playRemote(_searchedResult!.audioUrl!);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'English Definition:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: secondaryTextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _searchedResult!.definition,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _translationController,
                      label: l10n.translate('meaning_input_label'),
                      hint: 'e.g. Adventure',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      inputBg: inputBg,
                      inputBorder: inputBorder,
                      validator: (value) =>
                          value == null || value.isEmpty ? l10n.translate('meaning_error') : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.translate('word_type_label'),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: inputBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          dropdownColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: secondaryTextColor),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          items: _wordTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _exampleController,
                      label: l10n.translate('example_sentence_label'),
                      hint: 'e.g. Life is a great adventure.',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                      inputBg: inputBg,
                      inputBorder: inputBorder,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveWord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1), // Indigo 500
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.translate('save_btn'),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color textColor,
    required Color secondaryTextColor,
    required Color inputBg,
    required Color inputBorder,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5)),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 2,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
