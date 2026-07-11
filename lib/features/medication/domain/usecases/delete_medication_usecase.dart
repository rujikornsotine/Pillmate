import '../../../../core/utils/result.dart';
import '../repositories/medication_repository.dart';

/// ลบข้อมูลยาตาม id
class DeleteMedicationUseCase {
  DeleteMedicationUseCase({required MedicationRepository repository})
    : _repository = repository;

  final MedicationRepository _repository;

  Future<Result<void>> call(String id) {
    return _repository.deleteMedication(id);
  }
}
