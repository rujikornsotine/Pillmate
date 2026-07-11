import '../../../../core/utils/result.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

/// แก้ไขข้อมูลยาที่มีอยู่แล้ว พร้อมอัปเดตเวลาแก้ไขล่าสุด
class UpdateMedicationUseCase {
  UpdateMedicationUseCase({required MedicationRepository repository})
    : _repository = repository;

  final MedicationRepository _repository;

  Future<Result<void>> call({
    required Medication existing,
    required String name,
    required String dosage,
    required String quantity,
    String? imagePath,
    String? note,
  }) {
    // สร้าง Medication ใหม่ตรงๆ แทนการใช้ copyWith เพราะ imagePath และ note
    // เป็นค่าที่ผู้ใช้อาจตั้งใจล้างให้เป็น null ได้ (copyWith แบบ ?? จะทำให้ล้างค่าไม่ได้)
    final updated = Medication(
      id: existing.id,
      name: name,
      dosage: dosage,
      quantity: quantity,
      imagePath: imagePath,
      note: note,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return _repository.updateMedication(updated);
  }
}
