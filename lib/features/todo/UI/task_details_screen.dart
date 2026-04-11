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
  
  // Состояния для динамических полей
  DateTime? _dueDate;
  int _priority = 4;
  String _projectId = 'inbox';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    
    // Инициализируем локальное состояние данными из задачи
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _projectId = widget.task.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Общий метод сохранения
  void _save() {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text,
      description: _descController.text,
      dueDate: _dueDate,
      priority: _priority,
      projectId: _projectId,
    );
    ref.read(todoRepositoryProvider).updateTask(updatedTask);
  }

  // Логика выбора даты
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      _save();
    }
  }

  // Красивое форматирование даты для лейбла
  String _getDateLabel() {
    if (_dueDate == null) return 'Установить дату';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);

    if (selected == today) return 'Сегодня';
    if (selected == today.add(const Duration(days: 1))) return 'Завтра';
    
    return "${selected.day}.${selected.month}.${selected.year}";
  }

  Color _getPriorityColor(int p) {
    switch (p) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsStreamProvider).value ?? [];
    
    // Определяем имя текущего проекта
    String projectName = 'Входящие';
    if (_projectId != 'inbox') {
      try {
        projectName = projects.firstWhere((p) => p.id == _projectId).name;
      } catch (_) {}
    }

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
                  TextField(
                    controller: _titleController,
                    onChanged: (_) => _save(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Название'),
                  ),
                  TextField(
                    controller: _descController,
                    onChanged: (_) => _save(),
                    maxLines: null,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Описание'),
                  ),
                  const SizedBox(height: 20),
                  
                  // СЕКЦИЯ КНОПОК
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Кнопка даты
                      _ActionChip(
                        icon: Icons.calendar_today, 
                        label: _getDateLabel(), 
                        color: _dueDate != null ? Colors.green : Colors.grey,
                        onTap: _pickDate,
                      ),
                      // Кнопка приоритета
                      PopupMenuButton<int>(
                        onSelected: (val) {
                          setState(() => _priority = val);
                          _save();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 1, child: Text('Приоритет 1')),
                          const PopupMenuItem(value: 2, child: Text('Приоритет 2')),
                          const PopupMenuItem(value: 3, child: Text('Приоритет 3')),
                          const PopupMenuItem(value: 4, child: Text('Приоритет 4')),
                        ],
                        child: _ActionChip(
                          icon: Icons.flag_outlined, 
                          label: 'P$_priority', 
                          color: _getPriorityColor(_priority),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(),
          
          // НИЖНИЙ ВЫБОР ПРОЕКТА
          PopupMenuButton<String>(
            onSelected: (id) {
              setState(() => _projectId = id);
              _save();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'inbox', child: Text('📥 Входящие')),
              ...projects.map((p) => PopupMenuItem(value: p.id, child: Text('# ${p.name}'))),
            ],
            child: ListTile(
              leading: Icon(
                _projectId == 'inbox' ? Icons.inbox : Icons.list_alt, 
                color: Colors.blue
              ),
              title: Text(projectName),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
          ),
        ],
      ),
    );
  }
}

// Обновленный виджет чипа (теперь с поддержкой нажатия)
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}