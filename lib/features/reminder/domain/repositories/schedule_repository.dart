import '../../../../core/utils/result.dart';
import '../entities/schedule.dart';

/// Contract ของ Schedule Repository ให้ Domain Layer เรียกใช้โดยไม่รู้จัก Hive
abstract class ScheduleRepository {
  /// ดึงตารางยาทั้งหมดของผู้ใช้งาน (ทุกยารวมกัน)
  Future<Result<List<Schedule>>> getSchedules();

  /// เพิ่มตารางยาใหม่
  Future<Result<void>> createSchedule(Schedule schedule);

  /// แก้ไขตารางยา
  Future<Result<void>> updateSchedule(Schedule schedule);

  /// ลบตารางยา
  Future<Result<void>> deleteSchedule(String id);

  /// ลบตารางยาทั้งหมดที่ผูกกับยารายการหนึ่ง ใช้ตอนลบยาทิ้งเพื่อไม่ให้เหลือตารางกำพร้า
  Future<Result<void>> deleteSchedulesByMedicationId(String medicationId);
}
