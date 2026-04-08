import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/authorization.dart';

class TodoDrawer extends ConsumerWidget {
  const TodoDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем текущего пользователя из провайдера авторизации.
    // .value дает нам данные напрямую (без обработки состояний loading/error),
    // так как мы точно знаем, что пользователь авторизован, если он видит этот экран.
    final user = ref.watch(authStateProvider).value;
    
    // Безопасно извлекаем имя. Если его нет — пишем дефолтное.
    final userName = user?.displayName ?? 'Пользователь';
    // Берем первую букву имени для аватарки
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Drawer(
      backgroundColor: Colors.white, // Чистый белый фон в стиле Todoist
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.notifications_none, size: 20), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.settings_outlined, size: 20), onPressed: () {}),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Кнопка добавления задачи (как в десктопе, вынесена наверх)
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.redAccent),
              title: const Text('Добавить задачу', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              onTap: () {
                // Позже привяжем логику добавления
                Navigator.pop(context); 
              },
            ),
            
            // Меню навигации
            ListTile(
              leading: const Icon(Icons.search, color: Colors.black54),
              title: const Text('Поиск'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.inbox, color: Colors.blue),
              title: const Text('Входящие'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.green),
              title: const Text('Сегодня', style: TextStyle(fontWeight: FontWeight.bold)),
              selected: true, // Подсвечиваем активный пункт
              selectedTileColor: Colors.grey.shade100,
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.purple),
              title: const Text('Предстоящее'),
              onTap: () {},
            ),
            
            const Divider(),
            
            // Секция проектов
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Мои проекты', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
            ),
            ListTile(
              leading: const Text('#', style: TextStyle(fontSize: 20, color: Colors.grey)),
              title: const Text('Общее'),
              trailing: const Text('12', style: TextStyle(color: Colors.grey)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}