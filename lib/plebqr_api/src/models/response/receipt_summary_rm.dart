import 'package:json_annotation/json_annotation.dart';

part 'receipt_summary_rm.g.dart';

@JsonSerializable(createToJson: false)
class ReceiptSummaryRM {
  const ReceiptSummaryRM({
    required this.utr,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.referenceId,
    required this.beneficiaryAccount,
    required this.beneficiaryName,
  });

  @JsonKey(name: 'UTR')
  final String utr;
  @JsonKey(name: 'Amount')
  final int amount;
  @JsonKey(name: 'Status')
  final String status;
  @JsonKey(name: 'createdAt')
  final int createdAt;
  @JsonKey(name: 'Reference Id')
  final String referenceId;
  @JsonKey(name: 'Beneficiary A/c')
  final String beneficiaryAccount;
  @JsonKey(name: 'Beneficiary Name')
  final String beneficiaryName;

  static ReceiptSummaryRM fromJson(Map<String, dynamic> json) =>
      _$ReceiptSummaryRMFromJson(json);
}
