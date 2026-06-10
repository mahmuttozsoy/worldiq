class UserProgress {
  final String name;
  final int level;
  final int score;
  final int streak;
  final int bestScore;
  final DateTime? lastLoginDate;
  final String selectedAvatarId;
  final bool isPrivate;
  final bool isOnline;
  final dynamic lastSeen; // Can be Timestamp or DateTime

  const UserProgress({
    this.name = 'Gezgin Öğrenci',
    required this.level,
    required this.score,
    required this.streak,
    required this.bestScore,
    this.lastLoginDate,
    this.selectedAvatarId = 'm1',
    this.isPrivate = false,
    this.isOnline = false,
    this.lastSeen,
  });

  UserProgress copyWith({
    String? name,
    int? level,
    int? score,
    int? streak,
    int? bestScore,
    DateTime? lastLoginDate,
    String? selectedAvatarId,
    bool? isPrivate,
    bool? isOnline,
    dynamic lastSeen,
  }) {
    return UserProgress(
      name: name ?? this.name,
      level: level ?? this.level,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestScore: bestScore ?? this.bestScore,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      selectedAvatarId: selectedAvatarId ?? this.selectedAvatarId,
      isPrivate: isPrivate ?? this.isPrivate,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
