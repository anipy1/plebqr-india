import 'package:json_annotation/json_annotation.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/success_action_rm.dart';

part 'invoice_rm.g.dart';

@JsonSerializable(createToJson: false)
class InvoiceRM {
  const InvoiceRM({
    required this.pr,
    required this.routes,
    required this.successAction,
  });

  final String pr;
  final List<dynamic> routes;
  @JsonKey(name: 'successAction')
  final SuccessActionRM successAction;

  static InvoiceRM fromJson(Map<String, dynamic> json) =>
      _$InvoiceRMFromJson(json);
}
