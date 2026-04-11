import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/authorization.dart';
import '../data/todo_repository.dart';
import 'widgets/todo_drawer.dart';
import 'widgets/add_task_bottom_sheet.dart';
import 'task_details_screen.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  // Вспомогательный метод для получения цвета по приоритету
  Color _getPriorityColor(int p) {
    switch (p) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey.shade400;
    }
  }

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
    final filter = ref.watch(selectedProjectFilterProvider);
    final projects = ref.watch(projectsStreamProvider).value ?? [];

    // Динамический заголовок
    String title = 'Сегодня';
    if (filter == 'inbox') {
      title = 'Входящие';
    } else if (filter != 'today') {
      try {
        title = projects.firstWhere((p) => p.id == filter).name;
      } catch (_) {
        title = 'Проект';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const TodoDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
          if (tasks.isEmpty) {
            return _buildEmptyState(context, userName);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.isDone,
                  // Обновленные свойства чекбокса для отображения приоритета
                  side: BorderSide(
                    color: task.isDone ? Colors.grey : _getPriorityColor(task.priority),
                    width: 2,
                  ),
                  activeColor: Colors.grey,
                  shape: const CircleBorder(),
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(todoRepositoryProvider)
                          .toggleTaskStatus(task.id, val);
                    }
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? Colors.grey : Colors.black87,
                  ),
                ),
                subtitle: task.description.isNotEmpty
                    ? Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(task: task),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        shape: const CircleBorder(),
        onPressed: () => _openAddTaskSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa_outlined, size: 120, color: Colors.green.shade200),
                  const SizedBox(height: 24),
                  Text(
                    'Хорошего дня, $userName.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Сегодня вы выполнили все задачи',
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