import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task_model.dart';
import '../../../core/auth/authorization.dart';

// Провайдер для доступа к репозиторию задач
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref);
});

// Провайдер-поток, который будет в реальном времени отдавать список задач UI
// autoDispose значит, что когда мы уходим с экрана задач, поток закрывается, экономя память.
final tasksStreamProvider = StreamProvider.autoDispose<List<TaskModel>>((ref) {
  return ref.watch(todoRepositoryProvider).watchTasks();
});

class TodoRepository {
  final Ref _ref;
  TodoRepository(this._ref);

  // Приватный геттер для доступа к коллекции задач.
  // Архитектурно ВАЖНО: мы привязываем задачи к ID конкретного пользователя.
  // Никто другой не увидит твои задачи в базе.
  CollectionReference get _db {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');
  }

  // ЧТЕНИЕ: Возвращает поток задач, отсортированный по дате создания (новые сверху)
  Stream<List<TaskModel>> watchTasks() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots() // Слушаем базу в реальном времени
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // СОЗДАНИЕ: Отправляем новую задачу в Firebase
  Future<void> addTask(TaskModel task) async {
    await _db.add(task.toMap());
  }

  // ОБНОВЛЕНИЕ: Меняем статус (Выполнена/Не выполнена)
  Future<void> toggleTaskStatus(String taskId, bool isDone) async {
    await _db.doc(taskId).update({'isDone': isDone});
  }

  // УДАЛЕНИЕ: Удаляем задачу из базы по ID
  Future<void> deleteTask(String taskId) async {
    await _db.doc(taskId).delete();
  }
}