// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personnel_role_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonnelRoleAdapter extends TypeAdapter<PersonnelRole> {
  @override
  final int typeId = 20;

  @override
  PersonnelRole read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonnelRole(
      id: fields[0] as String,
      roleCode: fields[1] as String,
      roleName: fields[2] as String,
      description: fields[3] as String,
      isPersonel: fields[4] as bool,
      createdAt: fields[5] as String,
      updatedAt: fields[6] as String,
      salaryComponent: fields[7] as SalaryComponent?,
    );
  }

  @override
  void write(BinaryWriter writer, PersonnelRole obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.roleCode)
      ..writeByte(2)
      ..write(obj.roleName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.isPersonel)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.salaryComponent);
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

class SalaryComponentAdapter extends TypeAdapter<SalaryComponent> {
  @override
  final int typeId = 21;

  @override
  SalaryComponent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalaryComponent(
      id: fields[0] as String,
      gajiPokok: fields[1] as double,
      tunjanganTetap: fields[2] as double,
      tunjanganTidakTetap: fields[3] as double,
      transport: fields[4] as double,
      pulsa: fields[5] as double,
      bpjsKT: fields[6] as double,
      bpjsJP: fields[7] as double,
      bpjsKES: fields[8] as double,
      uangCuti: fields[9] as double,
      thr: fields[10] as double,
      santunan: fields[11] as double,
      hariPerBulan: fields[12] as int,
      totalGajiBulanan: fields[13] as double,
      biayaTetapHarian: fields[14] as double,
      upahLemburHarian: fields[15] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SalaryComponent obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.gajiPokok)
      ..writeByte(2)
      ..write(obj.tunjanganTetap)
      ..writeByte(3)
      ..write(obj.tunjanganTidakTetap)
      ..writeByte(4)
      ..write(obj.transport)
      ..writeByte(5)
      ..write(obj.pulsa)
      ..writeByte(6)
      ..write(obj.bpjsKT)
      ..writeByte(7)
      ..write(obj.bpjsJP)
      ..writeByte(8)
      ..write(obj.bpjsKES)
      ..writeByte(9)
      ..write(obj.uangCuti)
      ..writeByte(10)
      ..write(obj.thr)
      ..writeByte(11)
      ..write(obj.santunan)
      ..writeByte(12)
      ..write(obj.hariPerBulan)
      ..writeByte(13)
      ..write(obj.totalGajiBulanan)
      ..writeByte(14)
      ..write(obj.biayaTetapHarian)
      ..writeByte(15)
      ..write(obj.upahLemburHarian);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryComponentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
