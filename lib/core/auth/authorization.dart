import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// провайдер для доступа к FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// провайдер для отслеживания состояния аутентификации
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// провайдер для управления авторизацией
final authRepositoryProvider = Provider<Authorization>((ref) {
    return Authorization(ref.read(firebaseAuthProvider));
});

// Класс для управления авторизацией
class Authorization{
  final FirebaseAuth _firebaseAuth;
  Authorization(this._firebaseAuth);

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } 
    catch (e) {
      throw Exception('Ошибка входа: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    }
    catch (e){
      throw Exception('Ошибка выхода: $e');
    }
  }
}

