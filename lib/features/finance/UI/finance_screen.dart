import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/finance_repository.dart';
import '../domain/transaction_model.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои Финансы')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Ошибка: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Нет записей'));
          
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final tx = list[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx.isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  child: Icon(
                    tx.isIncome ? Icons.add : Icons.remove,
                    color: tx.isIncome ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(tx.title),
                trailing: Text(
                  '${tx.isIncome ? "+" : "-"}${tx.amount.toStringAsFixed(2)} ₽',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tx.isIncome ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, ref),
        child: const Icon(Icons.account_balance_wallet),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false; // По умолчанию расход

    // Используем StatefulBuilder внутри диалога, чтобы обновлять состояние переключателя
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Новая операция'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Переключатель Доход/Расход
              SwitchListTile(
                title: Text(isIncome ? 'Доход' : 'Расход'),
                value: isIncome,
                onChanged: (val) => setState(() => isIncome = val),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Что купили/получили?'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Сумма'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0 && titleController.text.isNotEmpty) {
                  final newTx = TransactionModel(
                    id: '',
                    title: titleController.text,
                    amount: amount,
                    isIncome: isIncome,
                    createdAt: DateTime.now(),
                  );
                  ref.read(financeRepositoryProvider).addTransaction(newTx);
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}