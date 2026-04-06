import 'package:azurite/features/todo/UI/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/authorization.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой Органайзер'),
        centerTitle: true,
        actions: [
          // Кнопка выхода из аккаунта
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Вызываем метод signOut из нашего репозитория
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добро пожаловать!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              // GridView позволяет сделать красивую плитку из элементов
              child: GridView.count(
                crossAxisCount: 2, // Две карточки в ряд
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _ModuleCard(
                    title: 'Финансы',
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                    onTap: () {
                      // Тут позже будет переход в модуль Финансов
                      print('Переход в финансы');
                    },
                  ),
                  _ModuleCard(
                    title: 'Задачи',
                    icon: Icons.checklist_rtl,
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const TodoScreen()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Приватный виджет карточки (начинается с нижнего подчеркивания), 
// чтобы не засорять глобальное пространство имен. Он используется только здесь.
class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // InkWell дает красивый эффект ряби при нажатии (Material Design)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}