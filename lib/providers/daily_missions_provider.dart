import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_mission.dart';
import 'shared_prefs_provider.dart';
import 'user_progress_provider.dart';

class DailyMissionsNotifier extends Notifier<List<DailyMission>> {
  @override
  List<DailyMission> build() {
    return _loadMissions();
  }

  List<DailyMission> _loadMissions() {
    final prefs = ref.read(sharedPreferencesProvider);
    final lastDate = prefs.getString('missions_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate != today) {
      prefs.setString('missions_date', today);
      return _generateNewMissions();
    } else {
      return [
      DailyMission(
        id: 'm1',
        title: 'mission_quiz_desc',
        goal: 3,
        currentProgress: prefs.getInt('mission_m1') ?? 0,
        isCompleted: prefs.getBool('mission_m1_done') ?? false,
        rewardXp: 50,
        type: 'quiz'
      ),
      DailyMission(
        id: 'm2',
        title: 'mission_score_desc',
        goal: 500,
        currentProgress: prefs.getInt('mission_m2') ?? 0,
        isCompleted: prefs.getBool('mission_m2_done') ?? false,
        rewardXp: 100,
        type: 'score'
      ),
      DailyMission(
        id: 'm3',
        title: 'mission_word_desc',
        goal: 10,
        currentProgress: prefs.getInt('mission_m3') ?? 0,
        isCompleted: prefs.getBool('mission_m3_done') ?? false,
        rewardXp: 75,
        type: 'word'
      ),
      ];
    }
  }

  List<DailyMission> _generateNewMissions() {
    final prefs = ref.read(sharedPreferencesProvider);
    final missions = [
      DailyMission(id: 'm1', title: 'mission_quiz_desc', goal: 3, rewardXp: 50, type: 'quiz'),
      DailyMission(id: 'm2', title: 'mission_score_desc', goal: 500, rewardXp: 100, type: 'score'),
      DailyMission(id: 'm3', title: 'mission_word_desc', goal: 10, rewardXp: 75, type: 'word'),
    ];
    for (var m in missions) {
      prefs.setInt('mission_${m.id}', 0);
      prefs.setBool('mission_${m.id}_done', false);
    }
    return missions;
  }

  void updateProgress(String type, int amount) {
    state = [
      for (final mission in state)
        if (mission.type == type && !mission.isCompleted)
          _updateMission(mission, amount)
        else
          mission
    ];
  }

  DailyMission _updateMission(DailyMission mission, int amount) {
    final newProgress = mission.currentProgress + amount;
    final isDone = newProgress >= mission.goal;

    if (isDone && !mission.isCompleted) {
      // Give reward
      ref.read(userProgressProvider.notifier).addScore(mission.rewardXp);
    }

    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setInt('mission_${mission.id}', newProgress);
    prefs.setBool('mission_${mission.id}_done', isDone);

    return mission.copyWith(
      currentProgress: newProgress,
      isCompleted: isDone,
    );
  }
}

final dailyMissionsProvider = NotifierProvider<DailyMissionsNotifier, List<DailyMission>>(() {
  return DailyMissionsNotifier();
});
