import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/authorization.dart';
import '../../data/todo_repository.dart';

class TodoDrawer extends ConsumerWidget {
  final VoidCallback onAddTask;

  const TodoDrawer({super.key, required this.onAddTask});

  // Метод для вызова окна создания проекта
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
                // Создаем проект (пока используем серый цвет по умолчанию)
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

    // 1. Получаем текущий выбранный фильтр (где мы сейчас находимся?)
    final currentFilter = ref.watch(selectedProjectFilterProvider);
    // 2. Слушаем поток проектов из Firebase
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Шапка профиля
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
            
            // Кнопка добавления задачи
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.redAccent),
              title: const Text('Добавить задачу', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context); 
                onAddTask();            
              },
            ),
            
            // Основные списки
            ListTile(
              leading: Icon(Icons.inbox, color: currentFilter == 'inbox' ? Colors.blue : Colors.blue.shade200),
              title: const Text('Входящие'),
              selected: currentFilter == 'inbox',
              selectedTileColor: Colors.grey.shade100,
              onTap: () {
                // Меняем глобальное состояние на 'inbox'
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
                // Меняем глобальное состояние на 'today'
                ref.read(selectedProjectFilterProvider.notifier).state = 'today';
                Navigator.pop(context);
              },
            ),
            
            const Divider(),
            
            // Заголовок секции проектов с кнопкой "+"
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
            
            // Динамический список проектов
            Expanded(
              child: projectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Ошибка: $e')),
                data: (projects) {
                  if (projects.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Нет проектов', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final isSelected = currentFilter == project.id;
                      
                      return ListTile(
                        leading: Text('#', style: TextStyle(fontSize: 20, color: Color(project.colorValue))),
                        title: Text(project.name),
                        selected: isSelected,
                        selectedTileColor: Colors.grey.shade100,
                        onTap: () {
                          // При нажатии на проект, меняем фильтр на его ID
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