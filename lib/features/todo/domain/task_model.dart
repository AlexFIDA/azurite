import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? deadline; // Может быть null, если дедлайна нет

  TaskModel({
    required this.id,
    required this.title,
    this.description = '', // По умолчанию пустое описание
    this.isDone = false,   // По умолчанию задача не выполнена
    required this.createdAt,
    this.deadline,
  });

  // Фабрика для сборки объекта из данных Firebase
  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? 'Без названия',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      // Аккуратно конвертируем Timestamp от Firebase в DateTime из Dart
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      // Если дедлайн есть — конвертируем, если нет — оставляем null
      deadline: map['deadline'] != null 
          ? (map['deadline'] as Timestamp).toDate() 
          : null,
    );
  }

  // Метод для превращения объекта обратно в формат для Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      // Если deadline не null, отправляем его как Timestamp, иначе null
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
    };
  }

  // Крутая фишка: метод copyWith.
  // В Dart объекты принято делать неизменяемыми (immutable). 
  // Если мы хотим "изменить" статус задачи, мы создаем её копию с новым статусом.
  TaskModel copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? deadline,
  }) {
    return TaskModel(
      id: id, // ID и createdAt никогда не меняются
      createdAt: createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      deadline: deadline ?? this.deadline,
    );
  }
}