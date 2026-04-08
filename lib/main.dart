import 'package:azurite/core/navigation/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/auth/authorization.dart'; 
import 'core/auth/authorization_screen.dart';

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

    return authState.when(
      data: (user) {
        if (user != null) return const MainShell(); 
        return const AuthScreen();
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Ошибка: $e'))),
    );
  }
}