import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'authorization.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // НОВОЕ: Контроллер для подтверждения пароля
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  
  // НОВОЕ: Переменная для хранения текста ошибки пароля
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Не забываем очищать память!
    _usernameController.dispose();
    super.dispose();
  }

  // НОВОЕ: Метод для проверки надежности пароля
  String? _validatePassword(String password) {
    if (password.isEmpty) return null; // Не ругаемся на пустое поле
    if (password.length < 5) return 'Минимум 5 символов';
    if (!password.contains(RegExp(r'[a-zA-Zа-яА-Я]'))) return 'Добавьте хотя бы одну букву';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Добавьте хотя бы одну цифру';
    // Проверка на спецсимволы (всё, что не буква и не цифра)
    if (!password.contains(RegExp(r'[^a-zA-Z0-9а-яА-Я]'))) return 'Добавьте спецсимвол (например, @, !, _)';
    
    return null; // Если дошли сюда — пароль идеален!
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    // Базовая проверка на пустоту
    if (email.isEmpty || password.isEmpty || (!_isLogin && (username.isEmpty || confirmPassword.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля!')),
      );
      return;
    }

    // НОВОЕ: Специфичные проверки для регистрации
    if (!_isLogin) {
      if (_passwordError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, придумайте более надежный пароль')),
        );
        return;
      }
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароли не совпадают!')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await ref.read(authRepositoryProvider).signIn(email, password);
      } else {
        await ref.read(authRepositoryProvider).signUp(email, password, username);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
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
                obscureText: true,
                // НОВОЕ: "Слушаем" каждое нажатие клавиши
                onChanged: (value) {
                  if (!_isLogin) {
                    setState(() {
                      _passwordError = _validatePassword(value);
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  // НОВОЕ: Показываем ошибку прямо под полем
                  errorText: !_isLogin ? _passwordError : null,
                ),
              ),
              const SizedBox(height: 16),

              // НОВОЕ: Поле подтверждения пароля (только для регистрации)
              if (!_isLogin) ...[
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Подтвердите пароль',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                const SizedBox(height: 8),
              ],

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
                  setState(() {
                    _isLogin = !_isLogin;
                    _passwordError = null;
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  });
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