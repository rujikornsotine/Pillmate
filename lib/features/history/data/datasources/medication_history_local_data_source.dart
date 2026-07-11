import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../models/medication_history_model.dart';

/// จัดการ CRUD ของข้อมูลประวัติการทานยาใน Hive Box โดยตรง (ชั้น Data เท่านั้นที่เข้าถึง Hive ได้)
class MedicationHistoryLocalDataSource {
  MedicationHistoryLocalDataSource({required Box<MedicationHistoryModel> box})
    : _box = box;

  final Box<MedicationHistoryModel> _box;

  /// เปิด Hive Box สำหรับประวัติการทานยา ต้องเรียกก่อนสร้าง MedicationHistoryLocalDataSource
  static Future<Box<MedicationHistoryModel>> openBox() {
    return Hive.openBox<MedicationHistoryModel>(HiveBoxes.histories);
  }

  /// ดึงประวัติทั้งหมด เรียงจากเวลาที่ควรทานล่าสุดไปเก่าสุด
  Future<List<MedicationHistoryModel>> getAll() async {
    final models = _box.values.toList();
    models.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return models;
  }

  /// เพิ่มรายการประวัติใหม่
  Future<void> create(MedicationHistoryModel model) async {
    await _box.put(model.id, model);
  }
}
