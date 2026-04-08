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

  void _submitTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newTask = TaskModel(
      id: '', 
      title: title,
      description: _descController.text.trim(),
      createdAt: DateTime.now(),
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
              // Dыбор даты и приоритета. Надо будет еще сделать
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
}