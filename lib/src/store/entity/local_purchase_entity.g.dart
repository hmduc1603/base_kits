// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_purchase_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalPurchaseEntityAdapter extends TypeAdapter<LocalPurchaseEntity> {
  @override
  final int typeId = 0;

  @override
  LocalPurchaseEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalPurchaseEntity(
      purchasedDateInMillisecond: fields[0] as String,
      productId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalPurchaseEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.purchasedDateInMillisecond)
      ..writeByte(1)
      ..write(obj.productId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalPurchaseEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
