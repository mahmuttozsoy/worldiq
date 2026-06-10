class DailyMission {
  final String id;
  final String title;
  final int goal;
  final int currentProgress;
  final int rewardXp;
  final bool isCompleted;
  final String type; // 'quiz', 'score', 'word'

  DailyMission({
    required this.id,
    required this.title,
    required this.goal,
    this.currentProgress = 0,
    required this.rewardXp,
    this.isCompleted = false,
    required this.type,
  });

  DailyMission copyWith({
    int? currentProgress,
    bool? isCompleted,
  }) {
    return DailyMission(
      id: id,
      title: title,
      goal: goal,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardXp: rewardXp,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type,
    );
  }
}
