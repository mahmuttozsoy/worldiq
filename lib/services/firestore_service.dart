import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// Yeni kullanıcı profilini Firestore üzerinde oluşturur.
  Future<void> createUserProfile({
    required String uid,
    required String username,
    required String email,
  }) async {
    try {
      await _db.collection(_collection).doc(uid).set({
        'uid': uid,
        'name': username,
        'email': email,
        'score': 0,
        'level': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Kullanıcı profili başarıyla oluşturuldu: $uid');
    } catch (e) {
      debugPrint('Firestore Profil Oluşturma Hatası: $e');
      rethrow;
    }
  }

  /// Mevcut kullanıcının puanını atomik olarak artırır.
  Future<void> addScore(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _db.collection(_collection).doc(user.uid).update({
        'score': FieldValue.increment(score),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Puan başarıyla eklendi: +$score');
    } catch (e) {
      debugPrint('Firestore Puan Güncelleme Hatası: $e');
      rethrow;
    }
  }

  /// Kullanıcı profilini getirir.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection(_collection).doc(uid).get();
    return doc.data();
  }

  /// Kullanıcı verilerini anlık olarak dinlemek için bir stream.
  Stream<DocumentSnapshot> getUserDataStream(String uid) {
    return _db.collection(_collection).doc(uid).snapshots();
  }
}
