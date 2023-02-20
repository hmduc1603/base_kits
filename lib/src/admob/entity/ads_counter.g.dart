// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_counter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdsCounterAdapter extends TypeAdapter<AdsCounter> {
  @override
  final int typeId = 3;

  @override
  AdsCounter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdsCounter(
      updatedDate: fields[1] as DateTime,
      adsCounting: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AdsCounter obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.adsCounting)
      ..writeByte(1)
      ..write(obj.updatedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdsCounterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
