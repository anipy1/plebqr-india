import 'package:plebqr_india/key_value_storage/src/models/receipt_summary_cm.dart';
import 'package:plebqr_india/key_value_storage/src/models/settled_payment_cm.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/invoice_rm.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/payment_status_rm.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/receipt_summary_rm.dart';

extension ReceiptSummaryRMtoCM on ReceiptSummaryRM {
  ReceiptSummaryCM toCacheModel() {
    return ReceiptSummaryCM(
      utr: utr,
      amount: amount,
      status: status,
      createdAt: createdAt,
      referenceId: referenceId,
      beneficiaryAccount: beneficiaryAccount,
      beneficiaryName: beneficiaryName,
    );
  }
}

/// Creates a SettledPaymentCM from InvoiceRM and PaymentStatusRM.
///
/// This mapper combines data from the invoice generation response and
/// the settled payment status response to create a complete cache model.
extension InvoiceAndStatusRMtoCM on InvoiceRM {
  SettledPaymentCM toSettledPaymentCacheModel(
    PaymentStatusRM paymentStatus, {
    required int amountInSats,
  }) {
    final receiptSummary = paymentStatus.receiptData!.summary.toCacheModel();
    return SettledPaymentCM(
      receiptSummary: receiptSummary,
      checkoutUrl: successAction.url,
      lightningInvoice: pr,
      amountInSats: amountInSats,
      tracker: successAction.tracker,
      upiId: successAction.upiId,
      currencyAmount: successAction.ccyAmount,
      settledAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}
