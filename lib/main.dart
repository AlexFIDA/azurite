import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Добавь это
import 'firebase_options.dart';
import 'core/auth/authorization.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Оборачиваем всё приложение в ProviderScope. 
  // Это "энергосеть" для Riverpod. Без неё провайдеры не работают.
  runApp(const ProviderScope(child: SuperApp()));
}

class SuperApp extends StatelessWidget {
  const SuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azurite SuperApp',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.cyan,
      ),
      home: const AuthChecker(), // Теперь главный экран — это "Страж"
    );
  }
}

// Этот виджет решает, что видит пользователь
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Подписываемся на состояние авторизации
    final authState = ref.watch(authStateProvider);

    // .when — это крутая фишка Riverpod для обработки данных из сети
    return authState.when(
      data: (user) {
        if (user != null) return const MainShell(); // Если вошел — в меню
        return const LoginScreen(); // Если нет — на экран входа
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Ошибка: $e'))),
    );
  }
}

// Временный экран логина
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.read(authRepositoryProvider).signInAnonymously(),
          child: const Text('Войти анонимно'),
        ),
      ),
    );
  }
}

// Временный экран главного меню (наш контейнер)
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Azurite SuperApp')),
      body: const Center(child: Text('Ты внутри! Тут будут Финансы и Задачи')),
    );
  }
}