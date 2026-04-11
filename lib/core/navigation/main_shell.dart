import 'package:azurite/features/finance/UI/finance_screen.dart';
import 'package:azurite/features/todo/UI/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/authorization.dart';


class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем данные пользователя для приветствия
    final user = ref.watch(authStateProvider).value;
    final userName = user?.displayName ?? 'Пользователь';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Очень светло-серый фон, чтобы белые карточки выделялись
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. ШАПКА ПРОФИЛЯ
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Доброе утро,',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        // Здесь в будущем можно открыть настройки профиля
                        ref.read(authRepositoryProvider).signOut();
                      },
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          initial,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. СВОДКА (Краткая информация из модулей)
            // 2. СВОДКА (Заглушка сервисов и Дата)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Builder(
                  builder: (context) {
                    final now = DateTime.now();
                    final months = [
                   'Января', 'Февраля', 'Марта', 'Апреля', 'Мая', 'Июня',
                   'Июля', 'Августа', 'Сентября', 'Октября', 'Ноября', 'Декабря'
                  ];
              final dateString = "${now.day} ${months[now.month - 1]}";

              return Row(
                children: [
                   Expanded(
                  child: _buildSummaryCard(
                   title: 'Сервисы',
                   value: 'Добавить +',
                   icon: Icons.add_to_photos_outlined,
                    color: Colors.blueGrey,
                   ),
                  ),
             const SizedBox(width: 16),
            // КАРТОЧКА С ДАТОЙ
            Expanded(
              child: _buildSummaryCard(
                title: 'Сегодня',
                value: dateString,
                icon: Icons.calendar_today_rounded,
                color: Colors.orangeAccent,
              ),
            ),
          ],
        );
      },
    ),
  ),
),

            // 3. ЗАГОЛОВОК СЕКЦИИ СЕРВИСОВ
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 32.0, bottom: 16.0),
                child: Text(
                  'Мои сервисы',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),

            // 4. СЕТКА МИНИ-АППОВ
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 колонки
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.6, // Пропорции карточек
                ),
                delegate: SliverChildListDelegate([
                  _buildAppCard(
                    context,
                    title: 'Задачи',
                    subtitle: 'Todoist для вас',
                    icon: Icons.format_list_bulleted,
                    gradientColors: [Colors.redAccent, Colors.orangeAccent],
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TodoScreen()));
                    },
                  ),
                  _buildAppCard(
                    context,
                    title: 'Финансы',
                    subtitle: 'Учет бюджета',
                    icon: Icons.pie_chart_outline,
                    gradientColors: [Colors.blueAccent, Colors.purpleAccent],
                    onTap: () {
                      Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => const FinanceScreen())
                        );
                    },
                  ),
                ]),
              ),
            ),
            
            // Отступ снизу для красоты скролла
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // --- Вспомогательные виджеты ---

  // Виджет маленькой карточки сводки
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // Виджет большой карточки мини-аппа
  Widget _buildAppCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}