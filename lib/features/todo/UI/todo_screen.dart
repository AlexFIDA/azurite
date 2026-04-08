import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/authorization.dart';
import '../data/todo_repository.dart';
import 'widgets/todo_drawer.dart';
import 'widgets/add_task_bottom_sheet.dart'; // НОВОЕ: импорт нашей панели

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  // НОВОЕ: Метод вызова панели. Он живет внутри класса TodoScreen.
  void _openAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksStreamProvider);
    final user = ref.watch(authStateProvider).value;
    final userName = user?.displayName ?? 'пользователь';

    return Scaffold(
      backgroundColor: Colors.white,
      // НОВОЕ: Передаем метод _openAddTaskSheet в наш Drawer
      drawer: TodoDrawer(
        onAddTask: () => _openAddTaskSheet(context),
      ), 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Сегодня', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          // НОВОЕ: Кнопка ПЛЮС в верхнем правом углу (как альтернатива)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.redAccent),
            onPressed: () => _openAddTaskSheet(context),
          ),
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
          if (tasks.isEmpty) {
            return _buildEmptyState(context, userName);
          }
          
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
      // НОВОЕ: Плавающая кнопка внизу справа (удобно тянуться пальцем, если список длинный)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        shape: const CircleBorder(),
        onPressed: () => _openAddTaskSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // НОВОЕ: Вызываем панель при клике на текст "Добавить задачу"
          InkWell(
            onTap: () => _openAddTaskSheet(context),
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text('Добавить задачу', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}