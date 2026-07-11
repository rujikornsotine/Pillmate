import '../../../../core/utils/result.dart';
import '../repositories/schedule_repository.dart';

/// ลบตารางยาทั้งหมดที่ผูกกับยารายการหนึ่ง เรียกใช้ตอนลบยาทิ้งเพื่อไม่ให้เหลือตารางกำพร้า
class DeleteSchedulesForMedicationUseCase {
  DeleteSchedulesForMedicationUseCase({
    required ScheduleRepository repository,
  }) : _repository = repository;

  final ScheduleRepository _repository;

  Future<Result<void>> call(String medicationId) {
    return _repository.deleteSchedulesByMedicationId(medicationId);
  }
}
