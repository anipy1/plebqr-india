// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_summary_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptSummaryRM _$ReceiptSummaryRMFromJson(Map<String, dynamic> json) =>
    ReceiptSummaryRM(
      utr: json['UTR'] as String,
      amount: (json['Amount'] as num).toInt(),
      status: json['Status'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
      referenceId: json['Reference Id'] as String,
      beneficiaryAccount: json['Beneficiary A/c'] as String,
      beneficiaryName: json['Beneficiary Name'] as String,
    );
