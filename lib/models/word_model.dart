class WordModel {
  final String id;
  final String word;
  final String translation;
  final String example;
  final String level;

  WordModel({
    required this.id,
    required this.word,
    required this.translation,
    required this.example,
    required this.level,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      example: json['example'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'example': example,
      'level': level,
    };
  }
}
