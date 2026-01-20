import 'package:equatable/equatable.dart';
import 'package:plebqr_india/domain_models/src/receipt_summary.dart';

class SettledPayment extends Equatable {
  const SettledPayment({
    required this.receiptSummary,
    required this.checkoutUrl,
    required this.lightningInvoice,
    required this.amountInSats,
    required this.tracker,
    required this.upiId,
    required this.currencyAmount,
    required this.settledAt,
  });

  final ReceiptSummary receiptSummary;
  final String checkoutUrl;
  final String lightningInvoice;
  final int amountInSats;
  final String tracker;
  final String upiId;
  final String currencyAmount;
  final int settledAt;

  @override
  List<Object?> get props => [
    receiptSummary,
    checkoutUrl,
    lightningInvoice,
    amountInSats,
    tracker,
    upiId,
    currencyAmount,
    settledAt,
  ];
}
