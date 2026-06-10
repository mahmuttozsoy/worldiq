import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Sync user progress to Firestore
  Future<void> syncUserProgress(UserProgress progress) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'name': progress.name,
        'level': progress.level,
        'score': progress.score,
        'streak': progress.streak,
        'bestScore': progress.bestScore,
        'selectedAvatarId': progress.selectedAvatarId,
        'isPrivate': progress.isPrivate,
        'lastUpdate': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Update privacy status
  Future<void> updatePrivacy(bool isPrivate) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'isPrivate': isPrivate,
      });
    }
  }

  // Update unlocked achievements
  Future<void> updateUnlockedAchievements(List<String> achievementIds) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({
        'unlockedAchievements': achievementIds,
      });
    }
  }

  // Search users by name

  // Search users by name or username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // Firestore is case-sensitive.
    // We are searching in both 'name' and 'username' fields.
    final nameQuery = _db
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(5)
        .get();

    final usernameQuery = _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(5)
        .get();

    final results = await Future.wait([nameQuery, usernameQuery]);

    final Map<String, Map<String, dynamic>> uniqueUsers = {};

    for (var snapshot in results) {
      for (var doc in snapshot.docs) {
        uniqueUsers[doc.id] = {...doc.data(), 'uid': doc.id};
      }
    }

    return uniqueUsers.values.toList();
  }

  // Add friend - Denormalized for speed
  Future<void> addFriend(Map<String, dynamic> friendData) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('friends')
          .doc(friendData['uid'])
          .set({
            'name': friendData['name'] ?? 'Anonymous',
            'score': friendData['score'] ?? 0,
            'level': friendData['level'] ?? 1,
            'selectedAvatarId': friendData['selectedAvatarId'] ?? 'm1',
            'addedAt': FieldValue.serverTimestamp(),
          });
    }
  }

  // Send friend request
  Future<void> sendFriendRequest(Map<String, dynamic> targetUser) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Cannot add self
    if (user.uid == targetUser['uid']) return;

    await _db.collection('notifications').add({
      'fromId': user.uid,
      'fromName':
          (await _db.collection('users').doc(user.uid).get()).data()?['name'] ??
          'Someone',
      'toId': targetUser['uid'],
      'type': 'friend_request',
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      'userData': {
        'uid': user.uid,
        'name':
            (await _db.collection('users').doc(user.uid).get())
                .data()?['name'] ??
            'Bilinmiyor',
        'score':
            (await _db.collection('users').doc(user.uid).get())
                .data()?['score'] ??
            0,
        'level':
            (await _db.collection('users').doc(user.uid).get())
                .data()?['level'] ??
            1,
        'selectedAvatarId':
            (await _db.collection('users').doc(user.uid).get())
                .data()?['selectedAvatarId'] ??
            'm1',
      },
    });
  }

  // Accept friend request
  Future<void> acceptFriendRequest(Map<String, dynamic> note) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final fromData = note['userData'];

    // Make both sides follow each other
    await followUser(fromData);

    // Update notification
    await _db.collection('notifications').doc(note['id']).update({
      'status': 'accepted',
    });
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String noteId) async {
    await _db.collection('notifications').doc(noteId).update({
      'status': 'rejected',
    });
  }

  // Send Game Invite
  Future<void> sendInvite(
    String targetUid,
    String gameType, [
    String? difficulty,
    String? sessionId,
  ]) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final myData = (await _db.collection('users').doc(user.uid).get()).data();
    final myName = myData?['name'] ?? 'Someone';

    await _db.collection('notifications').add({
      'toId': targetUid,
      'fromId': user.uid,
      'fromName': myName,
      'type': 'game_invite',
      'gameName': gameType,
      'difficulty': difficulty,
      'sessionId': sessionId,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
    });
  }

  // Listen for notifications
  Stream<List<Map<String, dynamic>>> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('notifications')
        .where('toId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // Mark notification as seen
  Future<void> markNotificationAsSeen(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'status': 'seen',
    });
  }

  // Get outgoing friend requests list
  Stream<List<Map<String, dynamic>>> getOutgoingRequestsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('notifications')
        .where('fromId', isEqualTo: user.uid)
        .where('type', isEqualTo: 'friend_request')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Follow User (Updated from addFriend)
  Future<void> followUser(Map<String, dynamic> targetData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final myData = (await _db.collection('users').doc(user.uid).get()).data();
    if (myData == null) return;

    final targetId = targetData['uid'];

    // 1. Add to own 'following' list
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(targetId)
        .set({
          'uid': targetId,
          'name': targetData['name'] ?? 'Anonymous',
          'score': targetData['score'] ?? 0,
          'level': targetData['level'] ?? 1,
          'selectedAvatarId': targetData['selectedAvatarId'] ?? 'm1',
          'timestamp': FieldValue.serverTimestamp(),
        });

    // 2. Add self to target's 'followers' list
    await _db
        .collection('users')
        .doc(targetId)
        .collection('followers')
        .doc(user.uid)
        .set({
          'uid': user.uid,
          'name': myData['name'] ?? 'Anonymous',
          'score': myData['score'] ?? 0,
          'level': myData['level'] ?? 1,
          'selectedAvatarId': myData['selectedAvatarId'] ?? 'm1',
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  // Unfollow User
  Future<void> unfollowUser(String targetId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Remove from own 'following' list
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(targetId)
        .delete();

    // 2. Remove self from target's 'followers' list
    await _db
        .collection('users')
        .doc(targetId)
        .collection('followers')
        .doc(user.uid)
        .delete();
  }

  // Remove Follower (They follow me, I remove them)
  Future<void> removeFollower(String followerId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Remove from own 'followers' list
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('followers')
        .doc(followerId)
        .delete();

    // 2. Remove self from target's 'following' list
    await _db
        .collection('users')
        .doc(followerId)
        .collection('following')
        .doc(user.uid)
        .delete();
  }

  // Get Following Count
  Stream<int> getFollowingCount(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .map((s) => s.docs.length);
  }

  // Get Followers Count
  Stream<int> getFollowersCount(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .snapshots()
        .map((s) => s.docs.length);
  }

  // Get Followers Stream
  Stream<List<Map<String, dynamic>>> getFollowersStream([String? uid]) {
    final targetUid = uid ?? _auth.currentUser?.uid;
    if (targetUid == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'uid': doc.id})
              .toList(),
        );
  }

  // Get Following Stream (Previously getFriendsStream)
  Stream<List<Map<String, dynamic>>> getFollowingStream([String? uid]) {
    final targetUid = uid ?? _auth.currentUser?.uid;
    if (targetUid == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(targetUid)
        .collection('following')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'uid': doc.id})
              .toList(),
        );
  }

  // Get Leaderboard Stream
  Stream<List<Map<String, dynamic>>> getLeaderboardStream() {
    return _db
        .collection('users')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            'Firestore Leaderboard: ${snapshot.docs.length} documents fetched.',
          );

          final users = snapshot.docs.map((doc) {
            final data = doc.data();
            return {...data, 'uid': doc.id};
          }).toList();

          // Sort in memory (Descending)
          users.sort((a, b) {
            final scoreA = a['score'] ?? a['totalScore'] ?? 0;
            final scoreB = b['score'] ?? b['totalScore'] ?? 0;
            return scoreB.compareTo(scoreA);
          });

          return users;
        })
        .handleError((error) {
          debugPrint('Firestore Leaderboard Error: $error');
        });
  }

  // Get specific user progress
  Future<UserProgress?> getUserProgress(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserProgress(
          name: data['name'] ?? 'Unknown Traveler',
          level: data['level'] ?? 1,
          score: data['score'] ?? 0,
          streak: data['streak'] ?? 0,
          bestScore: data['bestScore'] ?? 0,
          selectedAvatarId: data['selectedAvatarId'] ?? 'm1',
          isPrivate: data['isPrivate'] ?? false,
          isOnline: data['isOnline'] ?? false,
          lastSeen: data['lastSeen'] as Timestamp?,
        );
      }
    } catch (e) {
      debugPrint('Error getting user progress: $e');
    }
    return null;
  }

  // Check if current user follows target user
  Stream<bool> checkFollowStatus(String targetUid) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // --- Multiplayer Game Sessions ---

  // Create multiplayer session
  Future<String> createGameSession(
    String targetUid,
    String gameType,
    String difficulty,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return '';

    final sessionRef = _db.collection('game_sessions').doc();
    await sessionRef.set({
      'sessionId': sessionRef.id,
      'hostId': user.uid,
      'targetId': targetUid,
      'gameType': gameType,
      'difficulty': difficulty,
      'status': 'waiting',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Send the notification (invite) as well
    await sendInvite(targetUid, gameType, difficulty, sessionRef.id);

    return sessionRef.id;
  }

  // Listen to session
  Stream<Map<String, dynamic>?> listenToGameSession(String sessionId) {
    return _db
        .collection('game_sessions')
        .doc(sessionId)
        .snapshots()
        .map((s) => s.data());
  }

  // Cancel/Delete session
  Future<void> cancelGameSession(String sessionId) async {
    try {
      await _db.collection('game_sessions').doc(sessionId).delete();
    } catch (e) {
      debugPrint('Error canceling session: $e');
    }
  }

  // Join session (Invitee accepts)
  Future<void> joinGameSession(String sessionId) async {
    try {
      await _db.collection('game_sessions').doc(sessionId).update({
        'status': 'joined',
      });
    } catch (e) {
      debugPrint('Error joining session: $e');
    }
  }

  // --- Multiplayer Chess Moves ---

  Future<void> sendChessMove(String sessionId, String move) async {
    await _db
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .add({
          'move': move,
          'timestamp': FieldValue.serverTimestamp(),
          'playerUid': _auth.currentUser?.uid,
        });
  }

  Stream<List<Map<String, dynamic>>> getChessMovesStream(String sessionId) {
    return _db
        .collection('game_sessions')
        .doc(sessionId)
        .collection('moves')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // --- Match History ---

  Future<void> saveMatchResult(
    String gameType,
    bool isWin,
    int xpGained,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('match_history')
        .add({
          'gameType': gameType,
          'isWin': isWin,
          'xpGained': xpGained,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<Map<String, dynamic>>> getMatchHistoryStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('match_history')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // --- Daily Challenge ---

  Future<Map<String, dynamic>> getDailyChallenge() async {
    final now = DateTime.now();
    final dateId = '${now.year}-${now.month}-${now.day}';

    final doc = await _db.collection('daily_challenges').doc(dateId).get();
    if (doc.exists) {
      return doc.data()!;
    } else {
      // Create a new challenge for today if it doesn't exist
      final types = ['Sudoku', 'Chess', 'City Quiz'];
      final type = types[Random().nextInt(types.length)];
      final challenge = {'type': type, 'reward': 200, 'dateId': dateId};
      await _db.collection('daily_challenges').doc(dateId).set(challenge);
      return challenge;
    }
  }

  Future<bool> isDailyChallengeCompleted() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now();
    final dateId = '${now.year}-${now.month}-${now.day}';

    final doc = await _db.collection('users').doc(user.uid).get();
    final lastDaily = doc.data()?['lastDailyCompleted'];
    return lastDaily == dateId;
  }

  Future<void> completeDailyChallenge(int reward) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateId = '${now.year}-${now.month}-${now.day}';

    await _db.collection('users').doc(user.uid).update({
      'lastDailyCompleted': dateId,
      'score': FieldValue.increment(reward),
    });

    // Also save to match history
    await saveMatchResult('Daily Challenge', true, reward);
  }

  Future<void> updateUserPresence(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
