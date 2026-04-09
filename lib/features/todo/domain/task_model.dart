import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;  // НОВОЕ: Дата завершения
  final int priority;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.priority = 4,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? 'Без названия',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dueDate: map['deadline'] != null 
          ? (map['deadline'] as Timestamp).toDate() 
          : null,
      priority: map['priority'] ?? 4,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? dueDate,
    int? priority,
  }) {
    return TaskModel(
      id: id,
      createdAt: createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}