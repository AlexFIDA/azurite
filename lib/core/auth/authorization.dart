import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  // РЕГИСТРАЦИЯ
  Future<void> signUp(String email, String password, String username) async {
    try {
      // 1. Создаем пользователя в базе
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // 2. Обновляем его профиль, добавляя Логин (username)
      await credential.user?.updateDisplayName(username);
    } catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // ВХОД
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // ВЫХОД
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Приватный метод для перевода страшных ошибок Firebase на человеческий язык
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'Пользователь не найден';
        case 'wrong-password': return 'Неверный пароль';
        case 'email-already-in-use': return 'Эта почта уже занята';
        case 'weak-password': return 'Пароль слишком простой (минимум 6 символов)';
        case 'invalid-email': return 'Неверный формат почты';
        default: return 'Ошибка: ${e.message}';
      }
    }
    return 'Произошла неизвестная ошибка';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(firebaseAuthProvider));
});