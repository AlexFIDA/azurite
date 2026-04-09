import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task_model.dart';
import '../data/todo_repository.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final TaskModel task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
  }

  // Метод для сохранения изменений
  void _save() {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descController.text,
    );
    // Здесь нам понадобится метод updateTask в репозитории (добавим ниже)
    ref.read(todoRepositoryProvider).updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.archive_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              ref.read(todoRepositoryProvider).deleteTask(widget.task.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название без рамок
                  TextField(
                    controller: _titleController,
                    onChanged: (_) => _save(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Название'),
                  ),
                  // Описание
                  TextField(
                    controller: _descController,
                    onChanged: (_) => _save(),
                    maxLines: null, // Авто-высота
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Описание'),
                  ),
                  const SizedBox(height: 20),
                  
                  // Ряд кнопок как на скрине
                  Wrap(
                    spacing: 8,
                    children: [
                      _ActionChip(icon: Icons.calendar_today, label: 'Сегодня', color: Colors.green),
                      _ActionChip(icon: Icons.flag_outlined, label: 'Приоритет', color: Colors.grey),
                      _ActionChip(icon: Icons.alarm, label: 'Напоминания', color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Нижняя панель с выбором проекта (Входящие)
          const Divider(),
          ListTile(
            leading: const Icon(Icons.inbox, color: Colors.blue),
            title: const Text('Входящие'),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Маленький вспомогательный виджет для кнопок-чипов
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}