import 'package:equatable/equatable.dart';

class ReceiptSummary extends Equatable {
  const ReceiptSummary({
    required this.utr,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.referenceId,
    required this.beneficiaryAccount,
    required this.beneficiaryName,
  });

  final String utr;
  final int amount;
  final String status;
  final int createdAt;
  final String referenceId;
  final String beneficiaryAccount;
  final String beneficiaryName;

  @override
  List<Object?> get props => [
    utr,
    amount,
    status,
    createdAt,
    referenceId,
    beneficiaryAccount,
    beneficiaryName,
  ];
}
