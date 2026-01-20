import 'package:plebqr_india/domain_models/domain_models.dart';
import 'package:plebqr_india/key_value_storage/src/models/receipt_summary_cm.dart';
import 'package:plebqr_india/key_value_storage/src/models/settled_payment_cm.dart';

extension ReceiptSummaryCMtoDomain on ReceiptSummaryCM {
  ReceiptSummary toDomainModel() {
    return ReceiptSummary(
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

extension SettledPaymentCMtoDomain on SettledPaymentCM {
  SettledPayment toDomainModel() {
    return SettledPayment(
      receiptSummary: receiptSummary.toDomainModel(),
      checkoutUrl: checkoutUrl,
      lightningInvoice: lightningInvoice,
      amountInSats: amountInSats,
      tracker: tracker,
      upiId: upiId,
      currencyAmount: currencyAmount,
      settledAt: settledAt,
    );
  }
}
