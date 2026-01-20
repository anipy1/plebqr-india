import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plebqr_india/plebqr_repository/plebqr_repository.dart';
import 'package:plebqr_india/features/transactions/src/transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({required this.repository})
    : super(const TransactionsState());

  final PlebQrRepository repository;

  Future<void> loadTransactions() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final transactions = await repository.getSettledPayments();
      // Sort by settledAt timestamp (most recent first)
      transactions.sort((a, b) => b.settledAt.compareTo(a.settledAt));
      emit(state.copyWith(transactions: transactions, isLoading: false));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error));
    }
  }

  Future<void> refreshTransactions() async {
    await loadTransactions();
  }
}
