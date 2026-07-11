import '../../../../core/utils/result.dart';
import '../entities/medication.dart';

/// Contract ของ Medication Repository ให้ Domain Layer เรียกใช้โดยไม่รู้จัก Hive
abstract class MedicationRepository {
  /// ดึงข้อมูลยาทั้งหมด
  Future<Result<List<Medication>>> getMedications();

  /// ดึงข้อมูลยาตาม id
  Future<Result<Medication>> getMedicationById(String id);

  /// เพิ่มข้อมูลยาใหม่
  Future<Result<void>> createMedication(Medication medication);

  /// แก้ไขข้อมูลยา
  Future<Result<void>> updateMedication(Medication medication);

  /// ลบข้อมูลยา
  Future<Result<void>> deleteMedication(String id);
}
