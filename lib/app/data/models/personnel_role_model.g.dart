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
      salaryComponent: fields[4] as SalaryComponent?,
      createdAt: fields[5] as String,
      updatedAt: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PersonnelRole obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.roleCode)
      ..writeByte(2)
      ..write(obj.roleName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.salaryComponent)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
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
    );
  }

  @override
  void write(BinaryWriter writer, SalaryComponent obj) {
    writer
      ..writeByte(6)
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
      ..write(obj.pulsa);
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
