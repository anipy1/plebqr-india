// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settled_payment_cm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettledPaymentCMAdapter extends TypeAdapter<SettledPaymentCM> {
  @override
  final int typeId = 1;

  @override
  SettledPaymentCM read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettledPaymentCM(
      receiptSummary: fields[0] as ReceiptSummaryCM,
      checkoutUrl: fields[1] as String,
      lightningInvoice: fields[2] as String,
      amountInSats: fields[3] as int,
      tracker: fields[4] as String,
      upiId: fields[5] as String,
      currencyAmount: fields[6] as String,
      settledAt: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SettledPaymentCM obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.receiptSummary)
      ..writeByte(1)
      ..write(obj.checkoutUrl)
      ..writeByte(2)
      ..write(obj.lightningInvoice)
      ..writeByte(3)
      ..write(obj.amountInSats)
      ..writeByte(4)
      ..write(obj.tracker)
      ..writeByte(5)
      ..write(obj.upiId)
      ..writeByte(6)
      ..write(obj.currencyAmount)
      ..writeByte(7)
      ..write(obj.settledAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettledPaymentCMAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
