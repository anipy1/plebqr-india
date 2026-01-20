// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequestRM _$PaymentRequestRMFromJson(Map<String, dynamic> json) =>
    PaymentRequestRM(
      callback: json['callback'] as String,
      maxSendable: (json['maxSendable'] as num).toInt(),
      minSendable: (json['minSendable'] as num).toInt(),
      commentAllowed: (json['commentAllowed'] as num).toInt(),
      tag: json['tag'] as String,
      metadata: json['metadata'] as String,
    );
