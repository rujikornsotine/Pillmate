import '../../domain/entities/medication_history.dart';
import '../models/medication_history_model.dart';

/// แปลงข้อมูลระหว่าง MedicationHistory (Domain Entity) และ MedicationHistoryModel (Data Model)
class MedicationHistoryMapper {
  MedicationHistoryMapper._();

  /// แปลงจาก Entity เป็น Model เพื่อบันทึกลง Hive
  static MedicationHistoryModel toModel(MedicationHistory entity) {
    return MedicationHistoryModel(
      id: entity.id,
      medicationId: entity.medicationId,
      medicationName: entity.medicationName,
      scheduledAt: entity.scheduledAt,
      recordedAt: entity.recordedAt,
      status: entity.status.name,
    );
  }

  /// แปลงจาก Model ที่อ่านจาก Hive เป็น Entity สำหรับใช้งานใน Domain/Presentation
  static MedicationHistory toEntity(MedicationHistoryModel model) {
    return MedicationHistory(
      id: model.id,
      medicationId: model.medicationId,
      medicationName: model.medicationName,
      scheduledAt: model.scheduledAt,
      recordedAt: model.recordedAt,
      status: IntakeStatus.values.byName(model.status),
    );
  }
}
