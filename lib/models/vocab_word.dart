class VocabWord {
  final String id;
  final String word;
  final String translation;
  final String type;
  final String example;
  final String level;

  const VocabWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.type,
    required this.example,
    required this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'type': type,
      'example': example,
      'level': level,
    };
  }

  factory VocabWord.fromJson(Map<String, dynamic> json) {
    return VocabWord(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      type: json['type'] as String,
      example: json['example'] as String,
      level: json['level'] as String,
    );
  }
}
