import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plebqr_india/plebqr_repository/plebqr_repository.dart';
import 'package:plebqr_india/features/transactions/src/transactions_cubit.dart';
import 'package:plebqr_india/features/transactions/src/transactions_view.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({required this.repository, super.key});

  final PlebQrRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionsCubit>(
      create:
          (_) => TransactionsCubit(repository: repository)..loadTransactions(),
      child: const TransactionsView(),
    );
  }
}
