import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/authorization.dart';
import '../../data/todo_repository.dart';

class TodoDrawer extends ConsumerWidget {
  const TodoDrawer({super.key}); // Убрали коллбек onAddTask из конструктора

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый проект'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Название проекта'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = nameController.text.trim();
              if (text.isNotEmpty) {
                ref.read(todoRepositoryProvider).addProject(text, 0xFF9E9E9E);
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final userName = user?.displayName ?? 'Пользователь';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    final currentFilter = ref.watch(selectedProjectFilterProvider);
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pink.shade400,
                radius: 16,
                child: Text(
                  initial, 
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            
            // УБРАЛИ КНОПКУ "ДОБАВИТЬ ЗАДАЧУ" ОТСЮДА
            
            ListTile(
              leading: Icon(Icons.inbox, color: currentFilter == 'inbox' ? Colors.blue : Colors.blue.shade200),
              title: const Text('Входящие'),
              selected: currentFilter == 'inbox',
              selectedTileColor: Colors.grey.shade100,
              onTap: () {
                ref.read(selectedProjectFilterProvider.notifier).state = 'inbox';
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: currentFilter == 'today' ? Colors.green : Colors.green.shade200),
              title: const Text('Сегодня'),
              selected: currentFilter == 'today',
              selectedTileColor: Colors.grey.shade100,
              onTap: () {
                ref.read(selectedProjectFilterProvider.notifier).state = 'today';
                Navigator.pop(context);
              },
            ),
            
            const Divider(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Мои проекты', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20, color: Colors.grey),
                    onPressed: () => _showAddProjectDialog(context, ref),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Ошибка: $e')),
                data: (projects) {
                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ListTile(
                        leading: Text('#', style: TextStyle(fontSize: 20, color: Color(project.colorValue))),
                        title: Text(project.name),
                        selected: currentFilter == project.id,
                        selectedTileColor: Colors.grey.shade100,
                        onTap: () {
                          ref.read(selectedProjectFilterProvider.notifier).state = project.id;
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}