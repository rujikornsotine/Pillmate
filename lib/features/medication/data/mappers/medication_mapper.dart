import '../../domain/entities/medication.dart';
import '../models/medication_model.dart';

/// แปลงข้อมูลระหว่าง Medication (Domain Entity) และ MedicationModel (Data Model)
class MedicationMapper {
  MedicationMapper._();

  /// แปลงจาก Entity เป็น Model เพื่อบันทึกลง Hive
  static MedicationModel toModel(Medication entity) {
    return MedicationModel(
      id: entity.id,
      name: entity.name,
      dosage: entity.dosage,
      quantity: entity.quantity,
      imagePath: entity.imagePath,
      note: entity.note,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// แปลงจาก Model ที่อ่านจาก Hive เป็น Entity สำหรับใช้งานใน Domain/Presentation
  static Medication toEntity(MedicationModel model) {
    return Medication(
      id: model.id,
      name: model.name,
      dosage: model.dosage,
      quantity: model.quantity,
      imagePath: model.imagePath,
      note: model.note,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
