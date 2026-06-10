import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/word_model.dart';

/// Kelime dağarcığı yükleme işlemlerini yöneten servis.
/// Performans için JSON ayrıştırma işlemini arka planda (Isolate) yapar.
class VocabService {
  // Bellek içi önbellekleme (isteğe bağlı)
  static final Map<String, List<WordModel>> _cache = {};

  /// Belirtilen seviyedeki (a1, a2, b1...) kelimeleri yükler.
  /// Sadece ihtiyaç duyulduğunda çağrılır.
  static Future<List<WordModel>> loadWordsByLevel(String level) async {
    final String normalizedLevel = level.toLowerCase();
    
    // Eğer daha önce yüklenmişse önbellekten getir
    if (_cache.containsKey(normalizedLevel)) {
      debugPrint('Kelime önbellekten yüklendi: $normalizedLevel');
      return _cache[normalizedLevel]!;
    }

    try {
      debugPrint('Kelime dosyası yükleniyor: assets/vocabulary/en/$normalizedLevel.json');
      
      // JSON dosyasını asset'lerden oku
      final String jsonString = await rootBundle.loadString(
        'assets/vocabulary/en/$normalizedLevel.json'
      );

      // JSON ayrıştırma işlemini compute (Isolate) ile arka plana at
      // Bu sayede büyük JSON dosyalarında bile UI thread bloklanmaz.
      final List<WordModel> words = await compute(_parseWords, jsonString);
      
      // Önbelleğe kaydet
      _cache[normalizedLevel] = words;
      
      return words;
    } catch (e) {
      debugPrint('Kelimeler yüklenirken hata oluştu ($level): $e');
      return [];
    }
  }

  /// Isolate içinde çalışacak olan ayrıştırma fonksiyonu.
  /// Static veya top-level olmalıdır.
  static List<WordModel> _parseWords(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((item) => WordModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  
  /// Belleği temizlemek için kullanılabilir.
  static void clearCache() => _cache.clear();
}
