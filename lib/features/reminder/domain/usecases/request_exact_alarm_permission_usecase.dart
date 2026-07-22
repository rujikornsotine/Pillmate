import '../../../../core/utils/result.dart';
import '../repositories/reminder_repository.dart';

/// ขอสิทธิ์การปลุกตรงเวลาจากผู้ใช้งาน
///
/// สิทธิ์นี้ต้องเปิดจากหน้าตั้งค่าของระบบ ผู้ใช้จะถูกพาออกจากแอปไปโดยที่ระบบ
/// ไม่ได้อธิบายอะไรเลย จึงต้องอธิบายเหตุผลในแอปให้เข้าใจก่อนเรียก UseCase นี้เสมอ
class RequestExactAlarmPermissionUseCase {
  RequestExactAlarmPermissionUseCase({required ReminderRepository repository})
    : _repository = repository;

  final ReminderRepository _repository;

  Future<Result<bool>> call() {
    return _repository.requestExactAlarmPermission();
  }
}
