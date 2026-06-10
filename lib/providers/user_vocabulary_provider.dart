import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocab_word.dart';
import 'shared_prefs_provider.dart';

class UserVocabularyNotifier extends Notifier<Map<String, List<VocabWord>>> {
  @override
  Map<String, List<VocabWord>> build() {
    return {};
  }

  SharedPrefsService get _prefs => ref.read(sharedPrefsServiceProvider);

  void loadUserWords(String countryId) {
    final words = _prefs.getUserWords(countryId);
    state = {...state, countryId: words};
  }

  Future<void> addUserWord(String countryId, VocabWord word) async {
    await _prefs.saveUserWord(countryId, word);
    final words = _prefs.getUserWords(countryId);
    state = {...state, countryId: words};
  }

  Future<void> removeUserWord(String countryId, String wordId) async {
    await _prefs.deleteUserWord(countryId, wordId);
    final words = _prefs.getUserWords(countryId);
    state = {...state, countryId: words};
  }

  List<VocabWord> loadUserWordsForScreen(String countryId) {
    if (!state.containsKey(countryId)) {
      final words = _prefs.getUserWords(countryId);
      // Notifier'da state güncellerken dikkatli olunmalı (asenkron olmayan metodlarda)
      Future.microtask(() {
        state = {...state, countryId: words};
      });
      return words;
    }
    return state[countryId]!;
  }

  List<VocabWord> getWordsForLevel(String countryId, String level) {
    if (!state.containsKey(countryId)) {
      // Microtask kullanarak state güncellemesini bir sonraki frame'e erteleyelim
      // Build sırasında state güncellenmesini engellemek için
      final words = _prefs.getUserWords(countryId);
      Future.microtask(() {
        state = {...state, countryId: words};
      });
      return words.where((w) => w.level == level).toList();
    }
    return state[countryId]?.where((w) => w.level == level).toList() ?? [];
  }
}

final userVocabularyProvider = NotifierProvider<UserVocabularyNotifier, Map<String, List<VocabWord>>>(() {
  return UserVocabularyNotifier();
});
