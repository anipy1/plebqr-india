import 'package:hive/hive.dart';

part 'receipt_summary_cm.g.dart';

@HiveType(typeId: 0)
class ReceiptSummaryCM {
  const ReceiptSummaryCM({
    required this.utr,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.referenceId,
    required this.beneficiaryAccount,
    required this.beneficiaryName,
  });

  @HiveField(0)
  final String utr;

  @HiveField(1)
  final int amount;

  @HiveField(2)
  final String status;

  @HiveField(3)
  final int createdAt;

  @HiveField(4)
  final String referenceId;

  @HiveField(5)
  final String beneficiaryAccount;

  @HiveField(6)
  final String beneficiaryName;
}
