import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// โครงสร้างข้อมูลประวัติการทานยาสำหรับจัดเก็บใน Hive
class MedicationHistoryModel {
  const MedicationHistoryModel({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledAt,
    required this.recordedAt,
    required this.status,
  });

  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledAt;
  final DateTime recordedAt;

  /// ชื่อ enum ของ IntakeStatus เก็บเป็น String เพื่อความยืดหยุ่นในการอ่าน/ย้ายข้อมูล
  final String status;
}

/// TypeAdapter ของ MedicationHistoryModel เขียนด้วยมือ (ไม่ใช้ hive_generator
/// เช่นเดียวกับ MedicationModelAdapter และ ScheduleModelAdapter)
class MedicationHistoryModelAdapter extends TypeAdapter<MedicationHistoryModel> {
  @override
  final int typeId = HiveTypeIds.medicationHistoryModel;

  @override
  MedicationHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationHistoryModel(
      id: fields[0] as String,
      medicationId: fields[1] as String,
      medicationName: fields[2] as String,
      scheduledAt: fields[3] as DateTime,
      recordedAt: fields[4] as DateTime,
      status: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationHistoryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicationId)
      ..writeByte(2)
      ..write(obj.medicationName)
      ..writeByte(3)
      ..write(obj.scheduledAt)
      ..writeByte(4)
      ..write(obj.recordedAt)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
