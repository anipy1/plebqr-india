import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plebqr_india/component_library/component_library.dart';
import 'package:plebqr_india/domain_models/domain_models.dart';
import 'package:plebqr_india/features/transactions/src/transactions_cubit.dart';
import 'package:plebqr_india/features/transactions/src/transactions_state.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<TransactionsCubit, TransactionsState>(
        builder: (context, state) {
          if (state.isLoading && state.transactions.isEmpty) {
            return const CenteredCircularProgressIndicator();
          }

          if (state.error != null && state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: Spacing.mediumLarge),
                  Text(
                    'Failed to load transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Spacing.medium),
                  ElevatedButton(
                    onPressed:
                        () =>
                            context
                                .read<TransactionsCubit>()
                                .loadTransactions(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: Spacing.mediumLarge),
                  Text(
                    'No transactions yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: Spacing.small),
                  Text(
                    'Your settled payments will appear here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh:
                () => context.read<TransactionsCubit>().refreshTransactions(),
            child: ListView.builder(
              padding: const EdgeInsets.all(Spacing.mediumLarge),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                return _TransactionItem(transaction: transaction);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final SettledPayment transaction;

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.medium),
      child: InkWell(
        onTap: () async {
          try {
            final uri = Uri.parse(transaction.checkoutUrl);
            final launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (!launched && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open checkout URL')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error opening URL: $e')));
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.mediumLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Amount and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${transaction.currencyAmount}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (transaction.amountInSats > 0) ...[
                          const SizedBox(height: Spacing.xSmall),
                          Text(
                            '${transaction.amountInSats} sats',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDate(transaction.settledAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(width: Spacing.small),
                      Icon(Icons.launch, size: 16, color: Colors.grey[600]),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Spacing.medium),
              // Beneficiary info
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: Spacing.small),
                  Expanded(
                    child: Text(
                      transaction.receiptSummary.beneficiaryName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xSmall),
              // UPI ID
              Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: Spacing.small),
                  Expanded(
                    child: Text(
                      transaction.upiId,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xSmall),
              // UTR
              Row(
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: Spacing.small),
                  Expanded(
                    child: Text(
                      'UTR: ${transaction.receiptSummary.utr}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
