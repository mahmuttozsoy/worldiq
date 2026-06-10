
class Avatar {
  final String id;
  final String imageUrl; // We'll use icons or emojis for now, or paths to local assets
  final String name;
  final int requiredScore;
  final String? requiredLeague;
  final bool isMale;

  const Avatar({
    required this.id,
    required this.imageUrl,
    required this.name,
    this.requiredScore = 0,
    this.requiredLeague,
    required this.isMale,
  });

  bool isUnlocked(int score, String currentLeague) {
    if (score < requiredScore) return false;
    if (requiredLeague != null) {
      final leagues = ['Bronz', 'Gümüş', 'Altın', 'Platin', 'Elmas'];
      final currentIdx = leagues.indexOf(currentLeague);
      final reqIdx = leagues.indexOf(requiredLeague!);
      return currentIdx >= reqIdx;
    }
    return true;
  }
}

final List<Avatar> avatarsData = [
  // Default Open
  const Avatar(id: 'm1', imageUrl: '👨‍🎓', name: 'Öğrenci', isMale: true),
  const Avatar(id: 'w1', imageUrl: '👩‍🎓', name: 'Öğrenci', isMale: false),
  const Avatar(id: 'm2', imageUrl: '👨‍🚀', name: 'Kaşif', isMale: true),

  // Score Based
  const Avatar(id: 'w2', imageUrl: '👩‍🚀', name: 'Kaşif', requiredScore: 500, isMale: false),
  const Avatar(id: 'm3', imageUrl: '👨‍🏫', name: 'Bilgin', requiredScore: 1000, isMale: true),
  const Avatar(id: 'w3', imageUrl: '👩‍🏫', name: 'Bilgin', requiredScore: 1500, isMale: false),

  // League Based
  const Avatar(id: 'm4', imageUrl: '🤴', name: 'Kral', requiredLeague: 'Altın', isMale: true),
  const Avatar(id: 'w4', imageUrl: '👸', name: 'Kraliçe', requiredLeague: 'Altın', isMale: false),
  const Avatar(id: 'm5', imageUrl: '🧙‍♂️', name: 'Büyücü', requiredLeague: 'Platin', isMale: true),
  const Avatar(id: 'w5', imageUrl: '🧙‍♀️', name: 'Büyücü', requiredLeague: 'Platin', isMale: false),
  const Avatar(id: 'm6', imageUrl: '🦸‍♂️', name: 'Kahraman', requiredLeague: 'Elmas', isMale: true),
  const Avatar(id: 'w6', imageUrl: '🦸‍♀️', name: 'Kahraman', requiredLeague: 'Elmas', isMale: false),
];
