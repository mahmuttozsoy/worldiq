import 'quiz_question.dart';

class Country {
  final String id;
  final String name;
  final String flagPath;
  final String continent;
  final String capital;
  final QuizDifficulty difficulty;
  final List<String> hints;
  final String? plateCode;
  final String? region;

  const Country({
    required this.id,
    required this.name,
    required this.flagPath,
    required this.continent,
    this.capital = '',
    this.difficulty = QuizDifficulty.medium,
    this.hints = const [],
    this.plateCode,
    this.region,
  });
}
