import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task_model.dart';
import '../domain/project_model.dart'; // Обязательный импорт модели проекта
import '../../../core/auth/authorization.dart';

// ==========================================
// ПРОВАЙДЕРЫ (Должны быть ВНЕ класса)
// ==========================================

// Глобальное состояние: какой проект/фильтр сейчас выбран
final selectedProjectFilterProvider = StateProvider<String>((ref) {
  return 'today'; 
});

// Доступ к самому репозиторию
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref);
});

// Поток задач
final tasksStreamProvider = StreamProvider.autoDispose<List<TaskModel>>((ref) {
  return ref.watch(todoRepositoryProvider).watchTasks();
});

// Поток проектов
final projectsStreamProvider = StreamProvider.autoDispose<List<ProjectModel>>((ref) {
  return ref.watch(todoRepositoryProvider).watchProjects();
});


// ==========================================
// КЛАСС РЕПОЗИТОРИЯ
// ==========================================

class TodoRepository {
  final Ref _ref;
  TodoRepository(this._ref);

  // --- БАЗЫ ДАННЫХ ---

  CollectionReference get _tasksDb {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');
  }

  CollectionReference get _projectsDb {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('projects');
  }

  // --- МЕТОДЫ ДЛЯ ЗАДАЧ ---

  Stream<List<TaskModel>> watchTasks() {
    return _tasksDb.snapshots().map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Сортируем: сначала важные, потом по дате
      tasks.sort((a, b) {
        int res = a.priority.compareTo(b.priority);
        if (res != 0) return res;
        
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        return 0;
      });
      
      return tasks;
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _tasksDb.add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasksDb.doc(task.id).update(task.toMap());
  }

  Future<void> toggleTaskStatus(String taskId, bool isDone) async {
    await _tasksDb.doc(taskId).update({'isDone': isDone});
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksDb.doc(taskId).delete();
  }

  // --- МЕТОДЫ ДЛЯ ПРОЕКТОВ ---

  Stream<List<ProjectModel>> watchProjects() {
    return _projectsDb
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> addProject(String name, int colorValue) async {
    final newProject = ProjectModel(
      id: '',
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );
    await _projectsDb.add(newProject.toMap());
  }
}