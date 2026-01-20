// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_status_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentStatusRM _$PaymentStatusRMFromJson(Map<String, dynamic> json) =>
    PaymentStatusRM(
      status: json['status'] as String,
      receiptData: json['receiptData'] == null
          ? null
          : ReceiptDataRM.fromJson(json['receiptData'] as Map<String, dynamic>),
    );
