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

  // НОВЫЕ ПЕРЕМЕННЫЕ СОСТОЯНИЯ
  DateTime? _selectedDate;
  int _selectedPriority = 4; // По умолчанию приоритет обычный (4)

  @override
  void initState() {
    super.initState();
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

  // НОВЫЙ МЕТОД: Выбор даты
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent, // Цвет в стиле Todoist
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Вспомогательный метод для определения цвета флажка
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _submitTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // НОВОЕ: Передаем дату и приоритет в модель
    final newTask = TaskModel(
      id: '', 
      title: title,
      description: _descController.text.trim(),
      createdAt: DateTime.now(),
      dueDate: _selectedDate,
      priority: _selectedPriority,
    );

    ref.read(todoRepositoryProvider).addTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // КНОПКА ДАТЫ
                  ActionChip(
                    avatar: Icon(Icons.calendar_today_outlined, size: 16, color: _selectedDate != null ? Colors.green : Colors.grey),
                    label: Text(
                      _selectedDate != null 
                          // Форматируем дату вручную (дд.мм)
                          ? '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}'
                          : 'Сегодня',
                      style: TextStyle(color: _selectedDate != null ? Colors.green : Colors.grey),
                    ),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.grey.shade300),
                    onPressed: () => _selectDate(context),
                  ),
                  const SizedBox(width: 8),

                  // КНОПКА ПРИОРИТЕТА (Вызов всплывающего меню)
                  PopupMenuButton<int>(
                    initialValue: _selectedPriority,
                    onSelected: (value) => setState(() => _selectedPriority = value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.flag, color: Colors.red), SizedBox(width: 8), Text('Приоритет 1')])),
                      const PopupMenuItem(value: 2, child: Row(children: [Icon(Icons.flag, color: Colors.orange), SizedBox(width: 8), Text('Приоритет 2')])),
                      const PopupMenuItem(value: 3, child: Row(children: [Icon(Icons.flag, color: Colors.blue), SizedBox(width: 8), Text('Приоритет 3')])),
                      const PopupMenuItem(value: 4, child: Row(children: [Icon(Icons.flag_outlined, color: Colors.grey), SizedBox(width: 8), Text('Приоритет 4')])),
                    ],
                    child: ActionChip(
                      avatar: Icon(
                        _selectedPriority == 4 ? Icons.flag_outlined : Icons.flag, 
                        size: 16, 
                        color: _getPriorityColor(_selectedPriority)
                      ),
                      label: Text(
                        'P$_selectedPriority',
                        style: TextStyle(color: _getPriorityColor(_selectedPriority)),
                      ),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(color: Colors.grey.shade300),
                      onPressed: null, // Нажатие обрабатывает PopupMenuButton
                    ),
                  ),
                ],
              ),
              // КНОПКА ОТПРАВКИ
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
}