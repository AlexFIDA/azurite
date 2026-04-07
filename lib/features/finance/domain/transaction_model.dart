import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final bool isIncome; // true — доход, false — расход
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.createdAt,
  });

  // Превращаем Map из Firebase в объект Dart (Десериализация)
  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      title: map['title'] ?? 'Без названия',
      // Приводим к double, так как Firestore может вернуть int
      amount: (map['amount'] ?? 0.0).toDouble(),
      isIncome: map['isIncome'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Превращаем объект Dart в Map для отправки в Firebase (Сериализация)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}