import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/todo_repository.dart';
import '../domain/task_model.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Подписываемся на поток задач
    final tasksAsyncValue = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои Задачи'),
        backgroundColor: Colors.blueAccent.withOpacity(0.2),
      ),
      // Обрабатываем три состояния потока (загрузка, ошибка, данные)
      body: tasksAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Ошибка: $error')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('Пока нет задач. Добавь первую!'));
          }
          // Рисуем список задач
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return CheckboxListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    // Перечеркиваем текст, если задача выполнена
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: task.description.isNotEmpty 
                    ? Text(task.description) 
                    : null,
                value: task.isDone,
                // При клике на чекбокс дергаем метод обновления в репозитории
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    ref.read(todoRepositoryProvider).toggleTaskStatus(task.id, newValue);
                  }
                },
              );
            },
          );
        },
      ),
      // Кнопка добавления новой задачи
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Окно для ввода новой задачи
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая задача'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Что нужно сделать?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = titleController.text.trim();
              if (text.isNotEmpty) {
                // Создаем объект задачи
                final newTask = TaskModel(
                  id: '', // Firebase сам сгенерирует ID при добавлении
                  title: text,
                  createdAt: DateTime.now(),
                );
                // Отправляем в базу
                ref.read(todoRepositoryProvider).addTask(newTask);
                Navigator.pop(context); // Закрываем окно
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}