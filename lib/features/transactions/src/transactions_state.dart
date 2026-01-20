import 'package:equatable/equatable.dart';
import 'package:plebqr_india/domain_models/domain_models.dart';

class TransactionsState extends Equatable {
  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  final List<SettledPayment> transactions;
  final bool isLoading;
  final dynamic error;

  TransactionsState copyWith({
    List<SettledPayment>? transactions,
    bool? isLoading,
    dynamic error,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [transactions, isLoading, error];
}
