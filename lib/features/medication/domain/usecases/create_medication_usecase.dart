import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/result.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// เพิ่มข้อมูลยาใหม่ พร้อมสร้าง id และเวลาสร้าง/แก้ไขให้อัตโนมัติ
class CreateMedicationUseCase {
  CreateMedicationUseCase({required MedicationRepository repository})
    : _repository = repository;

  final MedicationRepository _repository;

  Future<Result<void>> call({
    required String name,
    required String dosage,
    required String quantity,
    String? imagePath,
    String? note,
  }) {
    final now = DateTime.now();
    final medication = Medication(
      id: IdGenerator.generate(),
      name: name,
      dosage: dosage,
      quantity: quantity,
      imagePath: imagePath,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
    return _repository.createMedication(medication);
  }
}
