import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/medication_model.dart';

/// จัดการ CRUD ของข้อมูลยาใน Hive Box โดยตรง (ชั้น Data เท่านั้นที่เข้าถึง Hive ได้)
class MedicationLocalDataSource {
  MedicationLocalDataSource({required Box<MedicationModel> box}) : _box = box;

  final Box<MedicationModel> _box;

  /// เปิด Hive Box สำหรับยา ต้องเรียกก่อนสร้าง MedicationLocalDataSource
  static Future<Box<MedicationModel>> openBox() {
    return Hive.openBox<MedicationModel>(HiveBoxes.medications);
  }

  /// ดึงข้อมูลยาทั้งหมด เรียงจากเวลาสร้างล่าสุดไปเก่าสุด
  Future<List<MedicationModel>> getAll() async {
    final models = _box.values.toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models;
  }

  /// ดึงข้อมูลยาตาม id ถ้าไม่พบจะโยน AppException
  Future<MedicationModel> getById(String id) async {
    final model = _box.get(id);
    if (model == null) {
      throw const AppException('ไม่พบข้อมูลยาที่ต้องการ');
    }
    return model;
  }

  /// เพิ่มข้อมูลยาใหม่
  Future<void> create(MedicationModel model) async {
    await _box.put(model.id, model);
  }

  /// แก้ไขข้อมูลยาที่มีอยู่แล้ว ถ้าไม่พบจะโยน AppException
  Future<void> update(MedicationModel model) async {
    if (!_box.containsKey(model.id)) {
      throw const AppException('ไม่พบข้อมูลยาที่ต้องการแก้ไข');
    }
    await _box.put(model.id, model);
  }

  /// ลบข้อมูลยาตาม id
  Future<void> delete(String id) async {
    if (!_box.containsKey(id)) {
      throw const AppException('ไม่พบข้อมูลยาที่ต้องการลบ');
    }
    await _box.delete(id);
  }
}
