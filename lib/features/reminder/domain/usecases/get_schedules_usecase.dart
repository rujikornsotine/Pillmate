import '../../../../core/utils/result.dart';
import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

/// ดึงตารางยาทั้งหมดของผู้ใช้งาน
class GetSchedulesUseCase {
  GetSchedulesUseCase({required ScheduleRepository repository})
    : _repository = repository;

  final ScheduleRepository _repository;

  Future<Result<List<Schedule>>> call() {
    return _repository.getSchedules();
  }
}
