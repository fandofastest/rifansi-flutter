// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_activity_input.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyActivityAdapter extends TypeAdapter<DailyActivity> {
  @override
  final int typeId = 1;

  @override
  DailyActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyActivity(
      id: fields[0] as String,
      spkId: fields[1] as String,
      spkDetails: fields[24] as SPKDetails?,
      date: fields[2] as String,
      areaId: fields[3] as String,
      weather: fields[4] as String,
      status: fields[5] as String,
      workStartTime: fields[6] as String,
      workEndTime: fields[7] as String,
      startImages: (fields[8] as List).cast<String>(),
      finishImages: (fields[9] as List).cast<String>(),
      closingRemarks: fields[10] as String,
      progressPercentage: fields[11] as double,
      activityDetails: (fields[12] as List).cast<ActivityDetail>(),
      equipmentLogs: (fields[13] as List).cast<EquipmentLog>(),
      manpowerLogs: (fields[14] as List).cast<ManpowerLog>(),
      materialUsageLogs: (fields[15] as List).cast<MaterialUsageLog>(),
      otherCosts: (fields[16] as List).cast<OtherCost>(),
      createdAt: fields[17] as String?,
      updatedAt: fields[18] as String?,
      isSynced: fields[19] as bool,
      localId: fields[20] as String?,
      lastSyncAttempt: fields[21] as DateTime?,
      syncRetryCount: fields[22] as int,
      syncError: fields[23] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyActivity obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.spkId)
      ..writeByte(24)
      ..write(obj.spkDetails)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.areaId)
      ..writeByte(4)
      ..write(obj.weather)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.workStartTime)
      ..writeByte(7)
      ..write(obj.workEndTime)
      ..writeByte(8)
      ..write(obj.startImages)
      ..writeByte(9)
      ..write(obj.finishImages)
      ..writeByte(10)
      ..write(obj.closingRemarks)
      ..writeByte(11)
      ..write(obj.progressPercentage)
      ..writeByte(12)
      ..write(obj.activityDetails)
      ..writeByte(13)
      ..write(obj.equipmentLogs)
      ..writeByte(14)
      ..write(obj.manpowerLogs)
      ..writeByte(15)
      ..write(obj.materialUsageLogs)
      ..writeByte(16)
      ..write(obj.otherCosts)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.isSynced)
      ..writeByte(20)
      ..write(obj.localId)
      ..writeByte(21)
      ..write(obj.lastSyncAttempt)
      ..writeByte(22)
      ..write(obj.syncRetryCount)
      ..writeByte(23)
      ..write(obj.syncError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuantityAdapter extends TypeAdapter<Quantity> {
  @override
  final int typeId = 2;

  @override
  Quantity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quantity(
      nr: fields[0] as double,
      r: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Quantity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nr)
      ..writeByte(1)
      ..write(obj.r);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityDetailAdapter extends TypeAdapter<ActivityDetail> {
  @override
  final int typeId = 3;

  @override
  ActivityDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityDetail(
      id: fields[0] as String,
      workItemId: fields[1] as String,
      actualQuantity: fields[2] as Quantity,
      status: fields[3] as String,
      remarks: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityDetail obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workItemId)
      ..writeByte(2)
      ..write(obj.actualQuantity)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.remarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentLogAdapter extends TypeAdapter<EquipmentLog> {
  @override
  final int typeId = 4;

  @override
  EquipmentLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentLog(
      id: fields[0] as String,
      equipmentId: fields[1] as String,
      fuelIn: fields[2] as double,
      fuelRemaining: fields[3] as double,
      workingHour: fields[4] as double,
      isBrokenReported: fields[5] as bool,
      remarks: fields[6] as String,
      hourlyRate: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.equipmentId)
      ..writeByte(2)
      ..write(obj.fuelIn)
      ..writeByte(3)
      ..write(obj.fuelRemaining)
      ..writeByte(4)
      ..write(obj.workingHour)
      ..writeByte(5)
      ..write(obj.isBrokenReported)
      ..writeByte(6)
      ..write(obj.remarks)
      ..writeByte(7)
      ..write(obj.hourlyRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ManpowerLogAdapter extends TypeAdapter<ManpowerLog> {
  @override
  final int typeId = 5;

  @override
  ManpowerLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManpowerLog(
      id: fields[0] as String,
      role: fields[1] as String,
      personCount: fields[2] as int,
      hourlyRate: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ManpowerLog obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.personCount)
      ..writeByte(3)
      ..write(obj.hourlyRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManpowerLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialUsageLogAdapter extends TypeAdapter<MaterialUsageLog> {
  @override
  final int typeId = 6;

  @override
  MaterialUsageLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialUsageLog(
      id: fields[0] as String,
      materialId: fields[1] as String,
      quantity: fields[2] as double,
      unitRate: fields[3] as double,
      remarks: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialUsageLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.materialId)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitRate)
      ..writeByte(4)
      ..write(obj.remarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialUsageLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OtherCostAdapter extends TypeAdapter<OtherCost> {
  @override
  final int typeId = 7;

  @override
  OtherCost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtherCost(
      id: fields[0] as String,
      costType: fields[1] as String,
      amount: fields[2] as double,
      description: fields[3] as String,
      receiptNumber: fields[4] as String?,
      remarks: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OtherCost obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.costType)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.receiptNumber)
      ..writeByte(5)
      ..write(obj.remarks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtherCostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SPKDetailsAdapter extends TypeAdapter<SPKDetails> {
  @override
  final int typeId = 8;

  @override
  SPKDetails read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SPKDetails(
      spkNo: fields[0] as String,
      title: fields[1] as String,
      projectName: fields[2] as String,
      location: fields[3] as Location?,
    );
  }

  @override
  void write(BinaryWriter writer, SPKDetails obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.spkNo)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.projectName)
      ..writeByte(3)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SPKDetailsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
