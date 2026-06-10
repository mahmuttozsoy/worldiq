import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../services/firebase_service.dart';
import 'shared_prefs_provider.dart';

final List<Achievement> defaultAchievements = [
  const Achievement(id: 'first_game', title: 'Welcome', description: 'Complete your first game.', icon: '🎯'),
  const Achievement(id: 'score_500', title: 'Silver Voyager', description: 'Reach a total of 500 points.', icon: '🥈'),
  const Achievement(id: 'score_1500', title: 'Gold Hunter', description: 'Reach 1500 points and enter the Gold League.', icon: '🥇'),
  const Achievement(id: 'score_6000', title: 'Diamond King', description: 'Reach 6000 points and rule the Diamond League.', icon: '💎'),
  const Achievement(id: 'streak_10', title: 'On Fire', description: 'Maintain a 10-day streak.', icon: '🔥'),
  const Achievement(id: 'streak_30', title: 'Loyal Friend', description: 'Maintain a 30-day streak.', icon: '📅'),
  const Achievement(id: 'perfect_game', title: 'Flawless', description: 'Complete a game without losing any lives.', icon: '👑'),
  const Achievement(id: 'vocab_100', title: 'Vocabulary Builder', description: 'Learn 100 words in the Language Academy.', icon: '📚'),
  const Achievement(id: 'vocab_1000', title: 'Polyglot', description: 'Memorize exactly 1000 words.', icon: '🎓'),
  const Achievement(id: 'turkey_master', title: 'Homeland', description: 'Get 20/20 on the Turkey Cities quiz.', icon: '🇹🇷'),
  const Achievement(id: 'explorer', title: 'World Explorer', description: 'Play all continent and flag modes at least once.', icon: '🌍'),
];

class AchievementsNotifier extends Notifier<List<Achievement>> {
  @override
  List<Achievement> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    
    return defaultAchievements.map((ach) {
      bool unlocked = prefs.getBool('ach_${ach.id}') ?? false;
      return ach.copyWith(isUnlocked: unlocked);
    }).toList();
  }

  void unlockAchievement(String id) {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1 || state[index].isUnlocked) return;

    final newList = List<Achievement>.from(state);
    newList[index] = newList[index].copyWith(isUnlocked: true);
    state = newList;

    ref.read(sharedPreferencesProvider).setBool('ach_$id', true);
    
    // Firestore'a da senkronize et
    final unlockedIds = newList.where((a) => a.isUnlocked).map((a) => a.id).toList();
    ref.read(firebaseServiceProvider).updateUnlockedAchievements(unlockedIds);
  }
}

final achievementsProvider = NotifierProvider<AchievementsNotifier, List<Achievement>>(() {
  return AchievementsNotifier();
});
