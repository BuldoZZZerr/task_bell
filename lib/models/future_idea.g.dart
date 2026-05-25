// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'future_idea.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FutureIdeaAdapter extends TypeAdapter<FutureIdea> {
  @override
  final int typeId = 2;

  @override
  FutureIdea read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FutureIdea(
      id: fields[0] as String,
      title: fields[1] as String,
      note: fields[2] as String,
      category: fields[3] as int,
      isDone: fields[4] == null ? false : fields[4] as bool,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FutureIdea obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isDone)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FutureIdeaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
