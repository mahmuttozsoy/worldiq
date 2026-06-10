import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/dictionary_result.dart';

class DictionaryService {
  /// Queries the Free Dictionary API and MyMemory translation API for a given word.
  static Future<DictionaryResult?> lookupWord(String word) async {
    if (word.isEmpty) return null;

    final cleanedWord = word.trim().toLowerCase();
    final dictUrl = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$cleanedWord');

    try {
      debugPrint('Sözlük sorgulanıyor: $cleanedWord');
      // 1. Fetch from Free Dictionary API
      final dictResponse = await http.get(dictUrl);
      if (dictResponse.statusCode != 200) {
        debugPrint('Sözlük API hatası (${dictResponse.statusCode}): ${dictResponse.body}');
        return null;
      }

      final List<dynamic> dictData = json.decode(dictResponse.body);
      if (dictData.isEmpty) return null;

      final entry = dictData[0] as Map<String, dynamic>;
      final phonetics = entry['phonetics'] as List<dynamic>?;
      String? phonetic = entry['phonetic'] as String?;
      String? audioUrl;

      if (phonetics != null && phonetics.isNotEmpty) {
        for (var ph in phonetics) {
          final text = ph['text'] as String?;
          final audio = ph['audio'] as String?;
          if (text != null && phonetic == null) {
            phonetic = text;
          }
          if (audio != null && audio.isNotEmpty) {
            audioUrl = audio;
            // Prefer complete https URLs
            if (audioUrl.startsWith('http')) break;
          }
        }
      }

      // Handle relative audio urls (e.g. //ssl.gstatic.com...)
      if (audioUrl != null && audioUrl.startsWith('//')) {
        audioUrl = 'https:$audioUrl';
      }

      final meanings = entry['meanings'] as List<dynamic>?;
      if (meanings == null || meanings.isEmpty) return null;

      // Extract details from the first meaning and definition
      final firstMeaning = meanings[0] as Map<String, dynamic>;
      final partOfSpeech = firstMeaning['partOfSpeech'] as String? ?? 'noun';

      // Map partOfSpeech to our supported types: 'noun', 'verb', 'adjective', 'adverb', 'phrase', 'other'
      String mappedType = 'other';
      final pos = partOfSpeech.toLowerCase();
      if (['noun', 'verb', 'adjective', 'adverb', 'phrase'].contains(pos)) {
        mappedType = pos;
      } else if (pos.contains('adjective')) {
        mappedType = 'adjective';
      } else if (pos.contains('adverb')) {
        mappedType = 'adverb';
      } else if (pos.contains('verb')) {
        mappedType = 'verb';
      } else if (pos.contains('noun')) {
        mappedType = 'noun';
      }

      final definitions = firstMeaning['definitions'] as List<dynamic>?;
      if (definitions == null || definitions.isEmpty) return null;

      final firstDef = definitions[0] as Map<String, dynamic>;
      final definition = firstDef['definition'] as String? ?? '';
      
      // Look for an example sentence in the definitions
      String example = '';
      for (var def in definitions) {
        final ex = def['example'] as String?;
        if (ex != null && ex.isNotEmpty) {
          example = ex;
          break;
        }
      }
      if (example.isEmpty) {
        example = firstDef['example'] as String? ?? 'No example sentence available.';
      }

      // 2. Translate word to Turkish via MyMemory Translation API
      String translation = '';
      try {
        debugPrint('Çeviri sorgulanıyor (MyMemory): $cleanedWord');
        final translateUrl = Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(cleanedWord)}&langpair=en|tr'
        );
        final translateResponse = await http.get(translateUrl);
        if (translateResponse.statusCode == 200) {
          final transData = json.decode(translateResponse.body);
          translation = transData['responseData']['translatedText'] as String? ?? '';
          translation = translation.trim();
          
          // Remove any auto-translation notes or identical values if they match completely
          if (translation.toLowerCase() == cleanedWord) {
            translation = '';
          }
        }
      } catch (e) {
        debugPrint('Çeviri hatası: $e');
      }

      // If MyMemory failed or returned empty/identical, let the user fill translation
      if (translation.isEmpty) {
        translation = '';
      }

      return DictionaryResult(
        word: entry['word'] as String? ?? word,
        phonetic: phonetic,
        audioUrl: audioUrl,
        type: mappedType,
        definition: definition,
        example: example,
        translation: translation,
      );
    } catch (e) {
      debugPrint('Sözlük arama hatası ($word): $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('Network')) {
        throw 'İnternet bağlantısı yok veya sunucuya erişilemiyor. Lütfen internetinizi kontrol edin.';
      }
      rethrow;
    }
  }
}
