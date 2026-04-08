import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'authorization.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  // Контроллеры для считывания текста из полей
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); // Для Логина

  bool _isLogin = true; // true - Вход, false - Регистрация
  bool _isLoading = false; // Состояние загрузки (чтобы показывать крутилку)

  // Обязательно очищаем память, когда экран закрывается
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    // Простейшая валидация
    if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля!')),
      );
      return;
    }

    setState(() => _isLoading = true); // Включаем загрузку

    try {
      if (_isLogin) {
        await ref.read(authRepositoryProvider).signIn(email, password);
      } else {
        await ref.read(authRepositoryProvider).signUp(email, password, username);
      }
      // Если всё успешно, StreamProvider сам перекинет нас на MainShell,
      // так что здесь Navigator.push не нужен!
    } catch (e) {
      // Показываем ошибку пользователю
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      // Выключаем загрузку, если мы всё ещё на этом экране (произошла ошибка)
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'С возвращением!' : 'Создать аккаунт',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Показываем поле "Логин" только при регистрации
              if (!_isLogin) ...[
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Логин (Никнейм)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Электронная почта',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true, // Скрывает пароль звездочками
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isLogin ? 'Войти' : 'Зарегистрироваться', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  // Переключаем режим Вход/Регистрация
                  setState(() => _isLogin = !_isLogin);
                },
                child: Text(_isLogin 
                    ? 'Нет аккаунта? Зарегистрируйтесь' 
                    : 'Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}