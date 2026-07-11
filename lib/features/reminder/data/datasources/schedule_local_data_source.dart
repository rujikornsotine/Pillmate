import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/schedule_model.dart';

/// จัดการ CRUD ของข้อมูลตารางยาใน Hive Box โดยตรง (ชั้น Data เท่านั้นที่เข้าถึง Hive ได้)
class ScheduleLocalDataSource {
  ScheduleLocalDataSource({required Box<ScheduleModel> box}) : _box = box;

  final Box<ScheduleModel> _box;

  /// เปิด Hive Box สำหรับตารางยา ต้องเรียกก่อนสร้าง ScheduleLocalDataSource
  static Future<Box<ScheduleModel>> openBox() {
    return Hive.openBox<ScheduleModel>(HiveBoxes.schedules);
  }

  /// ดึงตารางยาทั้งหมด เรียงจากเวลาสร้างล่าสุดไปเก่าสุด
  Future<List<ScheduleModel>> getAll() async {
    final models = _box.values.toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models;
  }

  /// เพิ่มตารางยาใหม่
  Future<void> create(ScheduleModel model) async {
    await _box.put(model.id, model);
  }

  /// แก้ไขตารางยาที่มีอยู่แล้ว ถ้าไม่พบจะโยน AppException
  Future<void> update(ScheduleModel model) async {
    if (!_box.containsKey(model.id)) {
      throw const AppException('ไม่พบตารางยาที่ต้องการแก้ไข');
    }
    await _box.put(model.id, model);
  }

  /// ลบตารางยาตาม id
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const AppException('ไม่พบตารางยาที่ต้องการลบ');
    }
    await _box.delete(id);
  }

  /// ลบตารางยาทั้งหมดที่ผูกกับยารายการหนึ่ง ใช้ตอนลบยาทิ้ง
  Future<void> deleteByMedicationId(String medicationId) async {
    final idsToDelete = _box.values
        .where((model) => model.medicationId == medicationId)
        .map((model) => model.id)
        .toList();
    await _box.deleteAll(idsToDelete);
  }
}
