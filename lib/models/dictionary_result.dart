class DictionaryResult {
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final String type; // noun, verb, adjective, adverb, phrase, other
  final String definition;
  final String example;
  final String translation;

  const DictionaryResult({
    required this.word,
    this.phonetic,
    this.audioUrl,
    required this.type,
    required this.definition,
    required this.example,
    required this.translation,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'audioUrl': audioUrl,
      'type': type,
      'definition': definition,
      'example': example,
      'translation': translation,
    };
  }

  factory DictionaryResult.fromJson(Map<String, dynamic> json) {
    return DictionaryResult(
      word: json['word'] as String,
      phonetic: json['phonetic'] as String?,
      audioUrl: json['audioUrl'] as String?,
      type: json['type'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      translation: json['translation'] as String,
    );
  }
}
