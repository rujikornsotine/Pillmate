import '../../../../core/utils/result.dart';
import '../entities/medication_history.dart';
import '../repositories/medication_history_repository.dart';

/// ดึงประวัติการทานยาทั้งหมดของผู้ใช้งาน
class GetMedicationHistoryUseCase {
  GetMedicationHistoryUseCase({
    required MedicationHistoryRepository repository,
  }) : _repository = repository;

  final MedicationHistoryRepository _repository;

  Future<Result<List<MedicationHistory>>> call() {
    return _repository.getHistory();
  }
}
