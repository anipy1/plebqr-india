// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_summary_cm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptSummaryCMAdapter extends TypeAdapter<ReceiptSummaryCM> {
  @override
  final int typeId = 0;

  @override
  ReceiptSummaryCM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptSummaryCM(
      utr: fields[0] as String,
      amount: fields[1] as int,
      status: fields[2] as String,
      createdAt: fields[3] as int,
      referenceId: fields[4] as String,
      beneficiaryAccount: fields[5] as String,
      beneficiaryName: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptSummaryCM obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.utr)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.referenceId)
      ..writeByte(5)
      ..write(obj.beneficiaryAccount)
      ..writeByte(6)
      ..write(obj.beneficiaryName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptSummaryCMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
