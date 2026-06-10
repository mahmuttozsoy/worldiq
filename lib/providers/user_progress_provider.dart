import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_progress.dart';
import '../models/avatar.dart';
import '../services/firebase_service.dart';

import 'shared_prefs_provider.dart';
import 'achievements_provider.dart';

final userProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseServiceProvider).getNotifications();
});

final outgoingRequestsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.watch(firebaseServiceProvider).getOutgoingRequestsStream();
});

final followersCountProvider = StreamProvider.family<int, String>((ref, uid) {
  return ref.watch(firebaseServiceProvider).getFollowersCount(uid);
});

final followingCountProvider = StreamProvider.family<int, String>((ref, uid) {
  return ref.watch(firebaseServiceProvider).getFollowingCount(uid);
});

final matchHistoryProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
      return ref.watch(firebaseServiceProvider).getMatchHistoryStream(uid);
    });

final dailyChallengeProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(firebaseServiceProvider).getDailyChallenge();
});

final isDailyCompletedProvider = FutureProvider<bool>((ref) {
  return ref.watch(firebaseServiceProvider).isDailyChallengeCompleted();
});

final followersStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String?>((ref, uid) {
      return ref.watch(firebaseServiceProvider).getFollowersStream(uid);
    });

final followingStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String?>((ref, uid) {
      return ref.watch(firebaseServiceProvider).getFollowingStream(uid);
    });

final otherUserProgressProvider = FutureProvider.family<UserProgress?, String>((
  ref,
  uid,
) async {
  return ref.watch(firebaseServiceProvider).getUserProgress(uid);
});

final followStatusProvider = StreamProvider.family<bool, String>((ref, uid) {
  return ref.watch(firebaseServiceProvider).checkFollowStatus(uid);
});

class UserProgressNotifier extends Notifier<UserProgress> {
  String _getUid() {
    return ref.read(userProvider).value?.uid ?? 'guest';
  }

  @override
  UserProgress build() {
    // Auth durumu değiştiğinde bu provider kendini yenileyecek
    ref.watch(userProvider);

    final uid = _getUid();
    final prefs = ref.watch(sharedPreferencesProvider);

    // Key'leri UID'ye özel yapıyoruz
    final savedName = prefs.getString('userName_$uid');
    final name = savedName ?? (uid == 'guest' ? 'Traveling Student' : 'Traveler');
    final level = prefs.getInt('level_$uid') ?? 1;
    final score = prefs.getInt('score_$uid') ?? 0;
    int streak = prefs.getInt('streak_$uid') ?? 0;
    final bestScore = prefs.getInt('bestScore_$uid') ?? 0;
    final lastLoginStr = prefs.getString('lastLoginDate_$uid');
    String selectedAvatarId = prefs.getString('selectedAvatarId_$uid') ?? 'm1';

    // Eğer isim yoksa ve giriş yapılmışsa Firestore'dan çekmeyi dene
    if (savedName == null && uid != 'guest') {
      _fetchFromFirestore(uid);
    }

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? lastLogin;

    if (lastLoginStr != null) {
      try {
        lastLogin = DateTime.parse(lastLoginStr);
      } catch (_) {}
    }

    if (lastLogin != null) {
      final difference = today
          .difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day))
          .inDays;

      if (difference == 1) {
        streak += 1;
        prefs.setInt('streak_$uid', streak);
        prefs.setString('lastLoginDate_$uid', today.toIso8601String());
      } else if (difference > 1) {
        streak = 1;
        prefs.setInt('streak_$uid', streak);
        prefs.setString('lastLoginDate_$uid', today.toIso8601String());
      }
    } else {
      streak = 1;
      prefs.setInt('streak_$uid', streak);
      prefs.setString('lastLoginDate_$uid', today.toIso8601String());
    }

    // Başarımları kontrol et
    if (streak >= 30) {
      ref.read(achievementsProvider.notifier).unlockAchievement('streak_30');
    } else if (streak >= 10) {
      ref.read(achievementsProvider.notifier).unlockAchievement('streak_10');
    }

    return UserProgress(
      name: name,
      level: level,
      score: score,
      streak: streak,
      bestScore: bestScore,
      lastLoginDate: today,
      selectedAvatarId: selectedAvatarId,
    );
  }

  Future<void> _fetchFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final name = data['name'] ?? 'Traveler';
        final score = data['score'] ?? 0;

        final prefs = ref.read(sharedPreferencesProvider);
        prefs.setString('userName_$uid', name);
        prefs.setInt('score_$uid', score);

        // State'i güncelle
        state = state.copyWith(name: name, score: score);
      }
    } catch (e) {
      debugPrint('Firestore data fetch error: $e');
    }
  }

  void updateName(String newName) {
    final uid = _getUid();
    final prefs = ref.read(sharedPreferencesProvider);
    state = state.copyWith(name: newName);
    prefs.setString('userName_$uid', newName);
    ref.read(firebaseServiceProvider).syncUserProgress(state);
  }

  void updateAvatar(String avatarId) {
    final uid = _getUid();
    final prefs = ref.read(sharedPreferencesProvider);
    state = state.copyWith(selectedAvatarId: avatarId);
    prefs.setString('selectedAvatarId_$uid', avatarId);
    ref.read(firebaseServiceProvider).syncUserProgress(state);
  }

  void updatePrivacy(bool isPrivate) {
    final uid = _getUid();
    final prefs = ref.read(sharedPreferencesProvider);
    state = state.copyWith(isPrivate: isPrivate);
    prefs.setBool('isPrivate_$uid', isPrivate);
    ref.read(firebaseServiceProvider).updatePrivacy(isPrivate);
  }

  void updateProgress(UserProgress newProgress) {
    state = newProgress;
    ref.read(firebaseServiceProvider).syncUserProgress(state);
  }

  void addScore(int points) {
    final uid = _getUid();
    final prefs = ref.read(sharedPreferencesProvider);
    int newScore = state.score + points;
    int newLevel = _calculateLevel(newScore);
    int newBest = newScore > state.bestScore ? newScore : state.bestScore;

    final achNotifier = ref.read(achievementsProvider.notifier);
    if (newScore >= 6000) achNotifier.unlockAchievement('score_6000');
    if (newScore >= 1500) achNotifier.unlockAchievement('score_1500');
    if (newScore >= 500) achNotifier.unlockAchievement('score_500');

    String league = _calculateLeague(newScore);
    String avatarId = state.selectedAvatarId;
    final avatar = avatarsData.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => avatarsData[0],
    );
    if (!avatar.isUnlocked(newScore, league)) {
      avatarId = 'm1';
      prefs.setString('selectedAvatarId_$uid', avatarId);
    }

    state = state.copyWith(
      score: newScore,
      level: newLevel,
      bestScore: newBest,
      selectedAvatarId: avatarId,
    );

    prefs.setInt('score_$uid', newScore);
    prefs.setInt('level_$uid', newLevel);
    prefs.setInt('bestScore_$uid', newBest);

    ref.read(firebaseServiceProvider).syncUserProgress(state);
  }

  String getLeague() {
    return _calculateLeague(state.score);
  }

  String _calculateLeague(int score) {
    if (score >= 6000) return 'Diamond';
    if (score >= 3000) return 'Platinum';
    if (score >= 1500) return 'Gold';
    if (score >= 500) return 'Silver';
    return 'Bronze';
  }

  int _calculateLevel(int score) {
    return (score / 200).floor() + 1;
  }
}

final userProgressProvider =
    NotifierProvider<UserProgressNotifier, UserProgress>(() {
      return UserProgressNotifier();
    });
