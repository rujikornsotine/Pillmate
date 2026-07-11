import '../../../../core/utils/result.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// ดึงรายการยาทั้งหมดของผู้ใช้งาน
class GetMedicationsUseCase {
  GetMedicationsUseCase({required MedicationRepository repository})
    : _repository = repository;

  final MedicationRepository _repository;

  Future<Result<List<Medication>>> call() {
    return _repository.getMedications();
  }
}
