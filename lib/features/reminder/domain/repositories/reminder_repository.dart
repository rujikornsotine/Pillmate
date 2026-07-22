import '../../../../core/utils/result.dart';
import '../../../medication/domain/entities/medication.dart';
import '../entities/reminder_permission_status.dart';
import '../entities/schedule.dart';

/// Contract ของ Reminder Repository ให้ Domain Layer สั่งจัดการแจ้งเตือนได้
/// โดยไม่รู้จัก flutter_local_notifications โดยตรง
abstract class ReminderRepository {
  /// ขอสิทธิ์แสดงการแจ้งเตือนจากผู้ใช้งาน (แสดงเป็น dialog ในแอป)
  Future<Result<bool>> requestPermission();

  /// พาผู้ใช้ไปหน้าตั้งค่าการปลุกตรงเวลาของระบบ คืนค่าสถานะหลังผู้ใช้กลับมา
  ///
  /// ต้องอธิบายเหตุผลให้ผู้ใช้เข้าใจก่อนเรียกเสมอ เพราะผู้ใช้จะถูกพาออกจากแอป
  Future<Result<bool>> requestExactAlarmPermission();

  /// อ่านสถานะสิทธิ์ปัจจุบันทั้งหมดที่จำเป็นต่อการแจ้งเตือน
  Future<Result<ReminderPermissionStatus>> getPermissionStatus();

  /// ยกเลิกการแจ้งเตือนทั้งหมดที่ตั้งเวลาไว้
  Future<Result<void>> cancelAllReminders();

  /// ยกเลิกการแจ้งเตือนของมื้อยาหนึ่งมื้อ ใช้เมื่อผู้ใช้ยืนยันการทานยามื้อนั้นเองแล้ว
  Future<Result<void>> cancelDoseReminder({
    required String medicationId,
    required DateTime occurrence,
  });

  /// ตั้งเวลาแจ้งเตือนทุกมื้อของตารางยาหนึ่งรายการ ภายในหน้าต่างเวลาที่กำหนดไว้
  ///
  /// [takenDoseKeys] คือชุดคีย์ของมื้อที่ผู้ใช้ยืนยันการทานไปแล้ว (จาก
  /// [ScheduleOccurrenceCalculator.doseKey]) มื้อเหล่านี้จะถูกข้าม ไม่ตั้งแจ้งเตือนซ้ำ
  Future<Result<void>> scheduleReminders({
    required Schedule schedule,
    required Medication medication,
    Set<String> takenDoseKeys,
  });
}
