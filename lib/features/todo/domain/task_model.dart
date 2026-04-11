import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int priority;
  final String projectId; // Связь с проектом

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.priority = 4,        // По умолчанию приоритет самый низкий (4)
    this.projectId = 'inbox', // По умолчанию кидаем в "Входящие"
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? 'Без названия',
      description: map['description'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : null,
      priority: map['priority'] ?? 4,
      projectId: map['projectId'] ?? 'inbox', 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority,
      'projectId': projectId,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    bool? isDone,
    DateTime? dueDate,
    int? priority,
    String? projectId,
  }) {
    return TaskModel(
      id: id,
      createdAt: createdAt, // Эти поля не меняются, передаем старые
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
    );
  }
}