import 'package:json_annotation/json_annotation.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/receipt_summary_rm.dart';

part 'receipt_data_rm.g.dart';

@JsonSerializable(createToJson: false)
class ReceiptDataRM {
  const ReceiptDataRM({required this.summary});

  final ReceiptSummaryRM summary;

  static ReceiptDataRM fromJson(Map<String, dynamic> json) =>
      _$ReceiptDataRMFromJson(json);
}
