import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';

/// โครงสร้างข้อมูลตารางยาสำหรับจัดเก็บใน Hive
class ScheduleModel {
  const ScheduleModel({
    required this.id,
    required this.medicationId,
    required this.frequency,
    required this.weekdays,
    required this.times,
    this.intervalHours,
    this.startTime,
    this.intervalDays,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String medicationId;

  /// ชื่อ enum ของ ScheduleFrequency เก็บเป็น String เพื่อความยืดหยุ่นในการอ่าน/ย้ายข้อมูล
  final String frequency;
  final List<int> weekdays;
  final List<String> times;
  final int? intervalHours;
  final String? startTime;
  final int? intervalDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// TypeAdapter ของ ScheduleModel เขียนด้วยมือ (ไม่ใช้ hive_generator เช่นเดียวกับ MedicationModelAdapter)
class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = HiveTypeIds.scheduleModel;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleModel(
      id: fields[0] as String,
      medicationId: fields[1] as String,
      frequency: fields[2] as String,
      weekdays: (fields[3] as List).cast<int>(),
      times: (fields[4] as List).cast<String>(),
      intervalHours: fields[5] as int?,
      startTime: fields[6] as String?,
      startDate: fields[7] as DateTime,
      endDate: fields[8] as DateTime?,
      isActive: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
      // fields[12] อาจไม่มีในข้อมูลเก่าที่บันทึกไว้ก่อนเพิ่มฟิลด์นี้ (คืนค่า null ได้ปลอดภัย)
      intervalDays: fields[12] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicationId)
      ..writeByte(2)
      ..write(obj.frequency)
      ..writeByte(3)
      ..write(obj.weekdays)
      ..writeByte(4)
      ..write(obj.times)
      ..writeByte(5)
      ..write(obj.intervalHours)
      ..writeByte(6)
      ..write(obj.startTime)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.intervalDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
