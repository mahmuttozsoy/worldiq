import 'country.dart';

enum QuizDifficulty { easy, medium, hard }

enum QuizType {
  flagToCountry,
  countryToContinent,
  capitalToCountry,
  countryToCapital,
  plateToCity,
  cityToPlate,
  cityToRegion,
  regionToCity,
}

class QuizQuestion {
  final String id;
  final QuizType type;
  final Country correctAnswer;
  final List<Country> options;

  const QuizQuestion({
    required this.id,
    required this.type,
    required this.correctAnswer,
    required this.options,
  });
}
