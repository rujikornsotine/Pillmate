import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// โครงสร้างข้อมูลยาสำหรับจัดเก็บใน Hive
class MedicationModel {
  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.quantity,
    this.imagePath,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String dosage;
  final String quantity;
  final String? imagePath;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// TypeAdapter ของ MedicationModel เขียนด้วยมือ (ไม่ใช้ hive_generator
/// เพื่อไม่ต้องเพิ่ม dependency ใหม่ที่ไม่จำเป็นตามข้อกำหนดใน ai-context.md)
class MedicationModelAdapter extends TypeAdapter<MedicationModel> {
  @override
  final int typeId = HiveTypeIds.medicationModel;

  @override
  MedicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationModel(
      id: fields[0] as String,
      name: fields[1] as String,
      dosage: fields[2] as String,
      quantity: fields[3] as String,
      imagePath: fields[4] as String?,
      note: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.dosage)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
