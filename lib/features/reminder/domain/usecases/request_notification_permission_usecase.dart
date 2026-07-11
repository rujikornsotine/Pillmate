import '../../../../core/utils/result.dart';
import '../repositories/reminder_repository.dart';

/// ขอสิทธิ์การแจ้งเตือนจากผู้ใช้งาน
class RequestNotificationPermissionUseCase {
  RequestNotificationPermissionUseCase({
    required ReminderRepository repository,
  }) : _repository = repository;

  final ReminderRepository _repository;

  Future<Result<bool>> call() {
    return _repository.requestPermission();
  }
}
