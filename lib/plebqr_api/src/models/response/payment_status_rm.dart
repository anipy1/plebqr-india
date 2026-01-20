import 'package:json_annotation/json_annotation.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/receipt_data_rm.dart';

part 'payment_status_rm.g.dart';

@JsonSerializable(createToJson: false)
class PaymentStatusRM {
  const PaymentStatusRM({required this.status, this.receiptData});

  final String status;
  @JsonKey(name: 'receiptData')
  final ReceiptDataRM? receiptData;

  static PaymentStatusRM fromJson(Map<String, dynamic> json) =>
      _$PaymentStatusRMFromJson(json);
}
