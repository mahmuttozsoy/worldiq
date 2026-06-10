class WordProgress {
  final String wordId;
  final int successCount;
  final int failCount;
  final DateTime nextReview;
  final bool isMastered;
  final bool isFavorite;

  const WordProgress({
    required this.wordId,
    required this.successCount,
    required this.failCount,
    required this.nextReview,
    this.isMastered = false,
    this.isFavorite = false,
  });

  factory WordProgress.initial(String wordId) {
    return WordProgress(
      wordId: wordId,
      successCount: 0,
      failCount: 0,
      nextReview: DateTime.now(),
      isMastered: false,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'successCount': successCount,
        'failCount': failCount,
        'nextReview': nextReview.toIso8601String(),
        'isMastered': isMastered,
        'isFavorite': isFavorite,
      };

  factory WordProgress.fromJson(Map<String, dynamic> json) => WordProgress(
        wordId: json['wordId'] as String,
        successCount: json['successCount'] ?? 0,
        failCount: json['failCount'] ?? 0,
        nextReview: DateTime.parse(json['nextReview'] as String),
        isMastered: json['isMastered'] ?? false,
        isFavorite: json['isFavorite'] ?? false,
      );

  WordProgress copyWith({
    int? successCount,
    int? failCount,
    DateTime? nextReview,
    bool? isMastered,
    bool? isFavorite,
  }) =>
      WordProgress(
        wordId: wordId,
        successCount: successCount ?? this.successCount,
        failCount: failCount ?? this.failCount,
        nextReview: nextReview ?? this.nextReview,
        isMastered: isMastered ?? this.isMastered,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}
