import '../models/word_progress.dart';

class SRSCalculator {
  /// Calculate the next review date and update success/fail counts based on whether the answer was correct.
  static WordProgress processAnswer(WordProgress progress, bool isCorrect) {
    if (isCorrect) {
      final newSuccessCount = progress.successCount + 1;
      int daysToAdd = 1;
      if (newSuccessCount == 2) {
        daysToAdd = 3;
      } else if (newSuccessCount >= 3) {
        daysToAdd = 7;
      }
      
      return progress.copyWith(
        successCount: newSuccessCount,
        nextReview: DateTime.now().add(Duration(days: daysToAdd)),
      );
    } else {
      // Incorrect answer: reset success streak, increment fail count, review again today.
      return progress.copyWith(
        successCount: 0,
        failCount: progress.failCount + 1,
        nextReview: DateTime.now(),
      );
    }
  }

  /// Check if a word is due for review.
  static bool isDueForReview(WordProgress progress) {
    final now = DateTime.now();
    // If nextReview is before or equal to current time, it's due.
    return progress.nextReview.isBefore(now) || progress.nextReview.isAtSameMomentAs(now);
  }
}

