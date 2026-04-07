import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_model.dart';
import '../../../core/auth/authorization.dart';

// 1. Провайдер для доступа к логике репозитория
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref);
});

// 2. Провайдер-поток для автоматического обновления списка транзакций на экране
final transactionsStreamProvider = StreamProvider.autoDispose<List<TransactionModel>>((ref) {
  return ref.watch(financeRepositoryProvider).watchTransactions();
});

class FinanceRepository {
  final Ref _ref;
  FinanceRepository(this._ref);

  // Путь к коллекции в облаке: users / {ID_пользователя} / transactions
  CollectionReference get _db {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) throw Exception('Пользователь не в системе');
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  // Слушаем изменения в базе в реальном времени
  Stream<List<TransactionModel>> watchTransactions() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Добавляем запись
  Future<void> addTransaction(TransactionModel tx) async {
    await _db.add(tx.toMap());
  }

  // Удаляем запись
  Future<void> deleteTransaction(String id) async {
    await _db.doc(id).delete();
  }
}