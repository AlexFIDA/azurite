import 'package:azurite/core/auth/authorization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/todo_repository.dart';
import 'widgets/todo_drawer.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksStreamProvider);
    
    // Получаем имя пользователя
    final user = ref.watch(authStateProvider).value;
    final userName = user?.displayName ?? 'пользователь';

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const TodoDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Сегодня', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: tasksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
        data: (tasks) {
          // Если задач нет
          if (tasks.isEmpty) {
            return _buildEmptyState(context, userName);
          }
          // Если задачи есть
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return CheckboxListTile(
                title: Text(task.title),
                value: task.isDone,
                onChanged: (val) {
                  if (val != null) {
                    ref.read(todoRepositoryProvider).toggleTaskStatus(task.id, val);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  // Верстка пустого экрана
  Widget _buildEmptyState(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              // TODO: Вызвать окно добавления задачи
            },
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text('Добавить задачу', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          ),
          
          // Расширяющийся контейнер для центрирования картинки
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Заглушка для иллюстрации. Потом заменить на Image.asset('assets/картинка')
                  Icon(Icons.spa_outlined, size: 120, color: Colors.green.shade200),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Хорошего дня, $userName.',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Сегодня вы выполнили 0 задач\nи достигли #TodoistZero!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 60), // Приподнимаем контент чуть выше центра
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}