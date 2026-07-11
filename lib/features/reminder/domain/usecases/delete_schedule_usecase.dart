import '../../../../core/utils/result.dart';
import '../repositories/schedule_repository.dart';

/// ลบตารางยาตาม id
class DeleteScheduleUseCase {
  DeleteScheduleUseCase({required ScheduleRepository repository})
    : _repository = repository;

  final ScheduleRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteSchedule(id);
  }
}
