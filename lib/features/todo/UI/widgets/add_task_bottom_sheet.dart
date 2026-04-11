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

  // Состояние выбранного проекта (по умолчанию 'inbox')
  String _selectedProjectId = 'inbox';

  @override
  void initState() {
    super.initState();
    // Небольшой лайфхак: если пользователь уже находится внутри какого-то проекта,
    // логично сразу предложить ему этот проект для новой задачи.
    final currentFilter = ref.read(selectedProjectFilterProvider);
    if (currentFilter != 'today' && currentFilter != 'inbox') {
      _selectedProjectId = currentFilter;
    }
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _submitTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newTask = TaskModel(
      id: '',
      title: title,
      description: _descController.text.trim(),
      createdAt: DateTime.now(),
      projectId: _selectedProjectId, // Используем выбранный ID
    );

    ref.read(todoRepositoryProvider).addTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Получаем список проектов для выпадающего списка
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 20, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            focusNode: _focusNode,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'Название задачи',
              border: InputBorder.none,
            ),
          ),
          TextField(
            controller: _descController,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Описание',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          
          // СЕЛЕКТОР ПРОЕКТА
          projectsAsync.when(
            data: (projects) => _buildProjectPicker(projects),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Ошибка загрузки проектов'),
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.flag_outlined, color: Colors.grey),
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

  // Виджет выбора проекта (PopupMenuButton — это лаконично и удобно)
  Widget _buildProjectPicker(List projects) {
    // Находим имя текущего выбранного проекта для отображения на кнопке
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
        ...projects.map((p) => PopupMenuItem(
          value: p.id,
          child: Text('# ${p.name}'),
        )),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.list, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(currentProjectName, style: TextStyle(color: Colors.grey.shade700)),
            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}