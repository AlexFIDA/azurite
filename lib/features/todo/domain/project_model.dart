import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final int colorValue; // Храним цвет как число, чтобы легко красить иконки
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProjectModel(
      id: documentId,
      name: map['name'] ?? 'Без названия',
      colorValue: map['colorValue'] ?? 0xFF9E9E9E, // Серый цвет по умолчанию
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'colorValue': colorValue,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}