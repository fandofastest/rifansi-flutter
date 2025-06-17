// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_progress_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkProgressAdapter extends TypeAdapter<WorkProgress> {
  @override
  final int typeId = 15;

  @override
  WorkProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkProgress(
      workItemId: fields[0] as String,
      workItemName: fields[1] as String,
      unit: fields[2] as String,
      boqVolumeR: fields[3] as double,
      boqVolumeNR: fields[4] as double,
      progressVolumeR: fields[5] as double,
      progressVolumeNR: fields[6] as double,
      workingDays: fields[7] as int,
      rateR: fields[9] as double,
      rateNR: fields[10] as double,
      dailyTargetR: fields[13] as double,
      dailyTargetNR: fields[14] as double,
      rateDescriptionR: fields[11] as String?,
      rateDescriptionNR: fields[12] as String?,
      remarks: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkProgress obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.workItemId)
      ..writeByte(1)
      ..write(obj.workItemName)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.boqVolumeR)
      ..writeByte(4)
      ..write(obj.boqVolumeNR)
      ..writeByte(5)
      ..write(obj.progressVolumeR)
      ..writeByte(6)
      ..write(obj.progressVolumeNR)
      ..writeByte(7)
      ..write(obj.workingDays)
      ..writeByte(8)
      ..write(obj.remarks)
      ..writeByte(9)
      ..write(obj.rateR)
      ..writeByte(10)
      ..write(obj.rateNR)
      ..writeByte(11)
      ..write(obj.rateDescriptionR)
      ..writeByte(12)
      ..write(obj.rateDescriptionNR)
      ..writeByte(13)
      ..write(obj.dailyTargetR)
      ..writeByte(14)
      ..write(obj.dailyTargetNR);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
