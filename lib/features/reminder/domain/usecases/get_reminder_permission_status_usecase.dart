import '../../../../core/utils/result.dart';
import '../entities/reminder_permission_status.dart';
import '../repositories/reminder_repository.dart';

/// อ่านสถานะสิทธิ์ที่จำเป็นต่อการแจ้งเตือนทานยา
///
/// ใช้ตัดสินใจว่าต้องแสดงคำอธิบายและปุ่มขอสิทธิ์ให้ผู้ใช้หรือไม่ ต้องเรียกใหม่
/// ทุกครั้งที่แอปกลับมาทำงาน เพราะผู้ใช้เปลี่ยนสิทธิ์จากหน้าตั้งค่าของระบบได้ตลอด
class GetReminderPermissionStatusUseCase {
  GetReminderPermissionStatusUseCase({required ReminderRepository repository})
    : _repository = repository;

  final ReminderRepository _repository;

  Future<Result<ReminderPermissionStatus>> call() {
    return _repository.getPermissionStatus();
  }
}
