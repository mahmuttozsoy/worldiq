import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Mevcut oturum açmış kullanıcıyı döndürür.
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı oturum durumunu takip eden stream.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Yeni kullanıcı kaydı oluşturur ve ardından Firestore profilini oluşturur.
  Future<UserCredential?> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      debugPrint('Kayıt işlemi başlatılıyor: $email');
      // 1. Firebase Auth hesabı oluştur
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Auth hesabı oluşturuldu: ${credential.user?.uid}');

      // 2. Başarılı ise Firestore profilini oluştur
      if (credential.user != null) {
        debugPrint('Firestore profili oluşturuluyor...');
        await _firestoreService.createUserProfile(
          uid: credential.user!.uid,
          username: username,
          email: email,
        );
        debugPrint('Firestore profili başarıyla oluşturuldu.');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException (${e.code}): ${e.message}');
      _handleAuthError(e);
      rethrow;
    } catch (e) {
      debugPrint('Bilinmeyen Kayıt Hatası ($e): ${e.runtimeType}');
      rethrow;
    }
  }

  /// Mevcut kullanıcı girişi yapar.
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      rethrow;
    } catch (e) {
      debugPrint('Bilinmeyen Giriş Hatası: $e');
      rethrow;
    }
  }

  /// Oturumu kapatır.
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('Kullanıcı oturumu kapatıldı.');
    } catch (e) {
      debugPrint('Çıkış Hatası: $e');
      rethrow;
    }
  }

  /// Firebase Auth hatalarını anlamlı mesajlara dönüştürür.
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'Şifre çok zayıf.';
        break;
      case 'email-already-in-use':
        message = 'Bu e-posta adresi zaten kullanımda.';
        break;
      case 'invalid-email':
        message = 'Geçersiz e-posta adresi.';
        break;
      case 'user-not-found':
        message = 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
        break;
      case 'wrong-password':
        message = 'Hatalı şifre.';
        break;
      default:
        message = 'Bir kimlik doğrulama hatası oluştu: ${e.message}';
    }
    debugPrint('Auth Hatası (${e.code}): $message');
  }
}
