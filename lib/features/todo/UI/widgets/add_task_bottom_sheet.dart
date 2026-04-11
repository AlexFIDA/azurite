import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/task_model.dart';
import '../../data/todo_repository.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _focusNode = FocusNode();

  String _selectedProjectId = 'inbox';
  DateTime? _selectedDate; // Состояние для даты
  int _priority = 4;        // Состояние для приоритета (1 - макс, 4 - мин)

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(selectedProjectFilterProvider);
    if (currentFilter != 'today' && currentFilter != 'inbox') {
      _selectedProjectId = currentFilter;
    }
    // Если мы в фильтре "Сегодня", логично сразу ставить сегодняшнюю дату
    if (currentFilter == 'today') {
      _selectedDate = DateTime.now();
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  // Метод выбора даты
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submitTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newTask = TaskModel(
      id: '',
      title: title,
      description: _descController.text.trim(),
      createdAt: DateTime.now(),
      projectId: _selectedProjectId,
      dueDate: _selectedDate, // Передаем дату
      priority: _priority,    // Передаем приоритет
    );

    ref.read(todoRepositoryProvider).addTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            focusNode: _focusNode,
            decoration: const InputDecoration(hintText: 'Название задачи', border: InputBorder.none),
          ),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(hintText: 'Описание', border: InputBorder.none),
          ),
          const SizedBox(height: 12),
          
          // Выбор проекта (уже был)
          projectsAsync.when(
            data: (projects) => _buildProjectPicker(projects),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // КНОПКА ДАТЫ
                  IconButton(
                    onPressed: _pickDate, 
                    icon: Icon(
                      Icons.calendar_today_outlined, 
                      color: _selectedDate != null ? Colors.blue : Colors.grey
                    ),
                  ),
                  // ВЫБОР ПРИОРИТЕТА
                  PopupMenuButton<int>(
                    initialValue: _priority,
                    onSelected: (val) => setState(() => _priority = val),
                    icon: Icon(
                      Icons.flag_outlined, 
                      color: _getPriorityColor(_priority)
                    ),
                    itemBuilder: (context) => [
                      _priorityItem(1, 'Приоритет 1', Colors.red),
                      _priorityItem(2, 'Приоритет 2', Colors.orange),
                      _priorityItem(3, 'Приоритет 3', Colors.blue),
                      _priorityItem(4, 'Приоритет 4', Colors.grey),
                    ],
                  ),
                ],
              ),
              IconButton.filled(
                onPressed: _submitTask,
                style: IconButton.styleFrom(backgroundColor: Colors.redAccent),
                icon: const Icon(Icons.arrow_upward),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<int> _priorityItem(int value, String text, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(Icons.flag, color: color, size: 20),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  Color _getPriorityColor(int p) {
    switch(p) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildProjectPicker(List projects) {
    String currentProjectName = 'Входящие';
    if (_selectedProjectId != 'inbox') {
      try {
        currentProjectName = projects.firstWhere((p) => p.id == _selectedProjectId).name;
      } catch (_) {}
    }

    return PopupMenuButton<String>(
      onSelected: (id) => setState(() => _selectedProjectId = id),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'inbox', child: Text('📥 Входящие')),
        ...projects.map((p) => PopupMenuItem(value: p.id, child: Text('# ${p.name}'))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Text(currentProjectName, style: TextStyle(color: Colors.grey.shade700)),
      ),
    );
  }
}