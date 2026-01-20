import 'package:hive/hive.dart';
import 'package:plebqr_india/key_value_storage/src/models/receipt_summary_cm.dart';

part 'settled_payment_cm.g.dart';

@HiveType(typeId: 1)
class SettledPaymentCM {
  const SettledPaymentCM({
    required this.receiptSummary,
    required this.checkoutUrl,
    required this.lightningInvoice,
    required this.amountInSats,
    required this.tracker,
    required this.upiId,
    required this.currencyAmount,
    required this.settledAt,
  });

  @HiveField(0)
  final ReceiptSummaryCM receiptSummary;

  @HiveField(1)
  final String checkoutUrl;

  @HiveField(2)
  final String lightningInvoice;

  @HiveField(3)
  final int amountInSats;

  @HiveField(4)
  final String tracker;

  @HiveField(5)
  final String upiId;

  @HiveField(6)
  final String currencyAmount;

  @HiveField(7)
  final int settledAt;
}
