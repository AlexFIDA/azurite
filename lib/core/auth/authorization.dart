import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).userChanges();
});

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  // РЕГИСТРАЦИЯ
  Future<void> signUp(String email, String password, String username) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(username);
      await credential.user?.reload(); // Обновляем данные пользователя, для отображения имени в приложениях
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

  // ВХОД ЧЕРЕЗ GOOGLE
  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      
      // В новой версии обязательна инициализация перед использованием
      await googleSignIn.initialize();

      // Вызываем окно авторизации (метод теперь называется authenticate)
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Получаем ключи доступа (теперь без слова await!)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Создаем учетные данные для Firebase (accessToken больше не нужен, только idToken)
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Логинимся в Firebase
      await _auth.signInWithCredential(credential);
      
    } catch (e) {
      // Если пользователь просто закрыл окно выбора аккаунта (canceled)
      // мы просто выходим из метода и ничего не делаем.
      if (e.toString().toLowerCase().contains('canceled')) return;
      
      // Иначе пробрасываем реальную ошибку
      throw Exception('Ошибка Google авторизации: $e');
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});