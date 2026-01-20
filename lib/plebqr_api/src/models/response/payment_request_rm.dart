import 'package:json_annotation/json_annotation.dart';

part 'payment_request_rm.g.dart';

@JsonSerializable(createToJson: false)
class PaymentRequestRM {
  const PaymentRequestRM({
    required this.callback,
    required this.maxSendable,
    required this.minSendable,
    required this.commentAllowed,
    required this.tag,
    required this.metadata,
  });

  final String callback;
  @JsonKey(name: 'maxSendable')
  final int maxSendable;
  @JsonKey(name: 'minSendable')
  final int minSendable;
  @JsonKey(name: 'commentAllowed')
  final int commentAllowed;
  final String tag;
  final String metadata;

  static PaymentRequestRM fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestRMFromJson(json);
}
