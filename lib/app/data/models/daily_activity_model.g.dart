// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyActivityAdapter extends TypeAdapter<DailyActivity> {
  @override
  final int typeId = 25;

  @override
  DailyActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyActivity(
      id: fields[0] as String,
      date: fields[1] as String,
      location: fields[2] as String,
      weather: fields[3] as String,
      status: fields[4] as String,
      workStartTime: fields[5] as String,
      workEndTime: fields[6] as String,
      startImages: (fields[7] as List).cast<String>(),
      finishImages: (fields[8] as List).cast<String>(),
      closingRemarks: fields[9] as String,
      createdAt: fields[10] as String,
      updatedAt: fields[11] as String,
      progressPercentage: fields[12] as double,
      activityDetails: (fields[13] as List).cast<ActivityDetail>(),
      equipmentLogs: (fields[14] as List).cast<EquipmentLog>(),
      manpowerLogs: (fields[15] as List).cast<ManpowerLog>(),
      materialUsageLogs: (fields[16] as List).cast<MaterialUsageLog>(),
      otherCosts: (fields[17] as List).cast<OtherCost>(),
      spkDetail: fields[18] as SPK?,
      userDetail: fields[19] as User,
      isSynced: fields[20] as bool,
      localId: fields[21] as String?,
      lastSyncAttempt: fields[22] as DateTime?,
      syncRetryCount: fields[23] as int,
      syncError: fields[24] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyActivity obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.weather)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.workStartTime)
      ..writeByte(6)
      ..write(obj.workEndTime)
      ..writeByte(7)
      ..write(obj.startImages)
      ..writeByte(8)
      ..write(obj.finishImages)
      ..writeByte(9)
      ..write(obj.closingRemarks)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.progressPercentage)
      ..writeByte(13)
      ..write(obj.activityDetails)
      ..writeByte(14)
      ..write(obj.equipmentLogs)
      ..writeByte(15)
      ..write(obj.manpowerLogs)
      ..writeByte(16)
      ..write(obj.materialUsageLogs)
      ..writeByte(17)
      ..write(obj.otherCosts)
      ..writeByte(18)
      ..write(obj.spkDetail)
      ..writeByte(19)
      ..write(obj.userDetail)
      ..writeByte(20)
      ..write(obj.isSynced)
      ..writeByte(21)
      ..write(obj.localId)
      ..writeByte(22)
      ..write(obj.lastSyncAttempt)
      ..writeByte(23)
      ..write(obj.syncRetryCount)
      ..writeByte(24)
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

class WorkItemAdapter extends TypeAdapter<WorkItem> {
  @override
  final int typeId = 3;

  @override
  WorkItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkItem(
      id: fields[0] as String,
      name: fields[1] as String,
      unit: fields[2] as Unit?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UnitAdapter extends TypeAdapter<Unit> {
  @override
  final int typeId = 4;

  @override
  Unit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Unit(
      name: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Unit obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ActivityDetailAdapter extends TypeAdapter<ActivityDetail> {
  @override
  final int typeId = 5;

  @override
  ActivityDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityDetail(
      id: fields[0] as String,
      actualQuantity: fields[1] as Quantity,
      status: fields[2] as String,
      remarks: fields[3] as String,
      workItem: fields[4] as WorkItem?,
      progressPercentage: fields[5] as double?,
      dailyProgressPercentage: fields[6] as double?,
      totalProgressValue: fields[7] as double?,
      rateR: fields[8] as double?,
      rateNR: fields[9] as double?,
      rateDescriptionR: fields[10] as String?,
      rateDescriptionNR: fields[11] as String?,
      boqVolumeR: fields[12] as double?,
      boqVolumeNR: fields[13] as double?,
      dailyTargetR: fields[14] as double?,
      dailyTargetNR: fields[15] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityDetail obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.actualQuantity)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.remarks)
      ..writeByte(4)
      ..write(obj.workItem)
      ..writeByte(5)
      ..write(obj.progressPercentage)
      ..writeByte(6)
      ..write(obj.dailyProgressPercentage)
      ..writeByte(7)
      ..write(obj.totalProgressValue)
      ..writeByte(8)
      ..write(obj.rateR)
      ..writeByte(9)
      ..write(obj.rateNR)
      ..writeByte(10)
      ..write(obj.rateDescriptionR)
      ..writeByte(11)
      ..write(obj.rateDescriptionNR)
      ..writeByte(12)
      ..write(obj.boqVolumeR)
      ..writeByte(13)
      ..write(obj.boqVolumeNR)
      ..writeByte(14)
      ..write(obj.dailyTargetR)
      ..writeByte(15)
      ..write(obj.dailyTargetNR);
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

class AreaAdapter extends TypeAdapter<Area> {
  @override
  final int typeId = 15;

  @override
  Area read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Area(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Area obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FuelPriceAdapter extends TypeAdapter<FuelPrice> {
  @override
  final int typeId = 16;

  @override
  FuelPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FuelPrice(
      id: fields[0] as String,
      pricePerLiter: fields[1] as double,
      effectiveDate: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FuelPrice obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pricePerLiter)
      ..writeByte(2)
      ..write(obj.effectiveDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FuelPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentAdapter extends TypeAdapter<Equipment> {
  @override
  final int typeId = 6;

  @override
  Equipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Equipment(
      id: fields[0] as String,
      equipmentCode: fields[1] as String,
      equipmentType: fields[2] as String,
      plateOrSerialNo: fields[3] as String,
      defaultOperator: fields[4] as String,
      area: fields[5] as Area?,
      currentFuelPrice: fields[6] as FuelPrice?,
    );
  }

  @override
  void write(BinaryWriter writer, Equipment obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.equipmentCode)
      ..writeByte(2)
      ..write(obj.equipmentType)
      ..writeByte(3)
      ..write(obj.plateOrSerialNo)
      ..writeByte(4)
      ..write(obj.defaultOperator)
      ..writeByte(5)
      ..write(obj.area)
      ..writeByte(6)
      ..write(obj.currentFuelPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EquipmentLogAdapter extends TypeAdapter<EquipmentLog> {
  @override
  final int typeId = 7;

  @override
  EquipmentLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EquipmentLog(
      id: fields[0] as String,
      fuelIn: fields[1] as double,
      fuelRemaining: fields[2] as double,
      workingHour: fields[3] as double,
      isBrokenReported: fields[4] as bool,
      remarks: fields[5] as String,
      equipment: fields[6] as Equipment?,
      hourlyRate: fields[7] as double,
      rentalRatePerDay: fields[8] as double,
      fuelPrice: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, EquipmentLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fuelIn)
      ..writeByte(2)
      ..write(obj.fuelRemaining)
      ..writeByte(3)
      ..write(obj.workingHour)
      ..writeByte(4)
      ..write(obj.isBrokenReported)
      ..writeByte(5)
      ..write(obj.remarks)
      ..writeByte(6)
      ..write(obj.equipment)
      ..writeByte(7)
      ..write(obj.hourlyRate)
      ..writeByte(8)
      ..write(obj.rentalRatePerDay)
      ..writeByte(9)
      ..write(obj.fuelPrice);
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

class PersonnelRoleAdapter extends TypeAdapter<PersonnelRole> {
  @override
  final int typeId = 8;

  @override
  PersonnelRole read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonnelRole(
      id: fields[0] as String,
      roleName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PersonnelRole obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.roleName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonnelRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ManpowerLogAdapter extends TypeAdapter<ManpowerLog> {
  @override
  final int typeId = 9;

  @override
  ManpowerLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ManpowerLog(
      id: fields[0] as String,
      personCount: fields[1] as int,
      normalHoursPerPerson: fields[2] as double,
      normalHourlyRate: fields[3] as double,
      overtimeHourlyRate: fields[4] as double,
      personnelRole: fields[5] as PersonnelRole?,
    );
  }

  @override
  void write(BinaryWriter writer, ManpowerLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personCount)
      ..writeByte(2)
      ..write(obj.normalHoursPerPerson)
      ..writeByte(3)
      ..write(obj.normalHourlyRate)
      ..writeByte(4)
      ..write(obj.overtimeHourlyRate)
      ..writeByte(5)
      ..write(obj.personnelRole);
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

class MaterialAdapter extends TypeAdapter<Material> {
  @override
  final int typeId = 10;

  @override
  Material read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Material(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Material obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MaterialUsageLogAdapter extends TypeAdapter<MaterialUsageLog> {
  @override
  final int typeId = 11;

  @override
  MaterialUsageLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialUsageLog(
      id: fields[0] as String,
      quantity: fields[1] as double,
      unitRate: fields[2] as double,
      remarks: fields[3] as String,
      material: fields[4] as Material?,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialUsageLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unitRate)
      ..writeByte(3)
      ..write(obj.remarks)
      ..writeByte(4)
      ..write(obj.material);
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
  final int typeId = 12;

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

class SPKAdapter extends TypeAdapter<SPK> {
  @override
  final int typeId = 13;

  @override
  SPK read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SPK(
      id: fields[0] as String,
      spkNo: fields[1] as String,
      title: fields[2] as String,
      projectName: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SPK obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.spkNo)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.projectName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SPKAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 14;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      username: fields[1] as String,
      fullName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.fullName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
