import 'package:json_annotation/json_annotation.dart';

part 'success_action_rm.g.dart';

@JsonSerializable(createToJson: false)
class SuccessActionRM {
  const SuccessActionRM({
    required this.tag,
    required this.description,
    required this.url,
    required this.upiId,
    required this.ccyAmount,
    required this.ccy,
    required this.tracker,
  });

  final String tag;
  final String description;
  final String url;
  @JsonKey(name: 'upi_id')
  final String upiId;
  @JsonKey(name: 'ccy_amount')
  final String ccyAmount;
  final String ccy;
  final String tracker;

  static SuccessActionRM fromJson(Map<String, dynamic> json) =>
      _$SuccessActionRMFromJson(json);
}
