import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/vocab_word.dart';

Map<String, List<VocabWord>> vocabularyData = {};

const Map<String, String> countryLanguageMap = {
  'us': 'İngilizce',
  'gb': 'İngilizce',
  'ca': 'İngilizce',
  'au': 'İngilizce',
};

// Map country codes to the primary language code used in vocabulary.json
const Map<String, String> countryToLangCode = {
  'us': 'en',
  'gb': 'en',
  'ca': 'en',
  'au': 'en',
};

Future<void> loadVocabularyData() async {
  try {
    final String jsonString = await rootBundle.loadString(
      'assets/data/vocabulary.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final Map<String, List<VocabWord>> parsedData = {};

    jsonData.forEach((langCode, levelsObj) {
      final List<VocabWord> words = [];
      final levelsMap = levelsObj as Map<String, dynamic>;

      levelsMap.forEach((levelStr, wordsArray) {
        int levelCount = 0;
        if (wordsArray is List) {
          void processList(List list) {
            for (var item in list) {
              if (item is Map) {
                try {
                  words.add(
                    VocabWord(
                      id: item['id']?.toString() ?? '',
                      word: item['word']?.toString() ?? '',
                      translation: item['translation']?.toString() ?? '',
                      type: item['type']?.toString() ?? '',
                      example: item['example']?.toString() ?? '',
                      level: item['level']?.toString() ?? levelStr,
                    ),
                  );
                  levelCount++;
                } catch (e) {
                  debugPrint('Error parsing word map: $e');
                }
              } else if (item is List) {
                processList(item);
              }
            }
          }

          processList(wordsArray);
        }
        debugPrint('Loaded $levelCount words for $langCode - $levelStr');
      });

      parsedData[langCode] = words;
      debugPrint('Total words for $langCode: ${words.length}');
    });

    // Populate vocabularyData using country codes so the app doesn't break
    countryToLangCode.forEach((countryId, langCode) {
      if (parsedData.containsKey(langCode)) {
        vocabularyData[countryId] = parsedData[langCode]!;
        debugPrint(
          'Mapped $countryId to $langCode (${vocabularyData[countryId]!.length} words)',
        );
      } else {
        vocabularyData[countryId] = [];
      }
    });
  } catch (e) {
    debugPrint('Error loading vocabulary JSON: $e');
  }
}
