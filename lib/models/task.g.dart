// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      subject: fields[1] as String,
      description: fields[2] as String,
      date: fields[3] as DateTime,
      priority: fields[4] as int,
      subtasks: (fields[5] as List?)?.cast<String>(),
      isDone: fields[6] as bool,
      timeMinutes: fields[7] as int?,
      endTimeMinutes: fields[9] as int?,
      homework: fields[8] as String?,
      recurrence: fields[10] as int,
      recurrenceWeekdays: (fields[11] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.subtasks)
      ..writeByte(6)
      ..write(obj.isDone)
      ..writeByte(7)
      ..write(obj.timeMinutes)
      ..writeByte(8)
      ..write(obj.homework)
      ..writeByte(9)
      ..write(obj.endTimeMinutes)
      ..writeByte(10)
      ..write(obj.recurrence)
      ..writeByte(11)
      ..write(obj.recurrenceWeekdays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
