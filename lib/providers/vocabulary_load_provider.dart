import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vocabulary.dart';

final vocabularyLoadProvider = FutureProvider<bool>((ref) async {
  if (vocabularyData.isEmpty) {
    await loadVocabularyData();
  }
  return true;
});
