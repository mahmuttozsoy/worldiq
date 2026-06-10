import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_progress.dart';
import '../models/vocab_word.dart';

class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  String getLanguageCountryId() {
    return _prefs.getString('language_country_id') ?? 'us';
  }

  Future<void> setLanguageCountryId(String id) async {
    await _prefs.setString('language_country_id', id);
  }

  int getUnlockedLanguageLevel(String countryId) {
    // 1=A1, 2=A2, 3=B1, 4=B2, 5=C1, 6=C2
    return _prefs.getInt('unlocked_level_$countryId') ?? 1;
  }

  Future<void> unlockLanguageLevel(String countryId, int level) async {
    final current = getUnlockedLanguageLevel(countryId);
    if (level > current) {
      await _prefs.setInt('unlocked_level_$countryId', level);
    }
  }

  WordProgress? getWordProgress(String wordId) {
    final String? jsonString = _prefs.getString('progress_$wordId');
    if (jsonString != null) {
      try {
        return WordProgress.fromJson(json.decode(jsonString));
      } catch (e) {
        debugPrint('Error parsing WordProgress for $wordId: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveWordProgress(WordProgress progress) async {
    final String jsonString = json.encode(progress.toJson());
    await _prefs.setString('progress_${progress.wordId}', jsonString);
  }

  List<VocabWord> getUserWords(String countryId) {
    final String? jsonString = _prefs.getString('user_words_$countryId');
    if (jsonString != null) {
      try {
        final List<dynamic> list = json.decode(jsonString);
        return list.map((item) => VocabWord.fromJson(item)).toList();
      } catch (e) {
        debugPrint('Error parsing user words for $countryId: $e');
        return [];
      }
    }
    return [];
  }

  Future<void> saveUserWord(String countryId, VocabWord word) async {
    final words = getUserWords(countryId);
    words.add(word);
    final String jsonString = json.encode(words.map((w) => w.toJson()).toList());
    await _prefs.setString('user_words_$countryId', jsonString);
  }

  Future<void> deleteUserWord(String countryId, String wordId) async {
    final words = getUserWords(countryId);
    words.removeWhere((w) => w.id == wordId);
    final String jsonString = json.encode(words.map((w) => w.toJson()).toList());
    await _prefs.setString('user_words_$countryId', jsonString);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsService(prefs);
});

class LanguageLevelNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    return {};
  }

  int getLevel(String countryId) {
    return state[countryId] ??
        ref.read(sharedPrefsServiceProvider).getUnlockedLanguageLevel(countryId);
  }

  void updateLevel(String countryId, int newLevel) {
    state = {...state, countryId: newLevel};
  }
}

final languageLevelProvider = NotifierProvider<LanguageLevelNotifier, Map<String, int>>(() {
  return LanguageLevelNotifier();
});
class WordProgressVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final wordProgressVersionProvider = NotifierProvider<WordProgressVersionNotifier, int>(() {
  return WordProgressVersionNotifier();
});
