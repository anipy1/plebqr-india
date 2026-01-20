import 'package:plebqr_india/domain_models/domain_models.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/receipt_summary_rm.dart';

extension ReceiptSummaryRMtoDomain on ReceiptSummaryRM {
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
