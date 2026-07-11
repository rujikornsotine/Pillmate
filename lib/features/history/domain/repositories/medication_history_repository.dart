import '../../../../core/utils/result.dart';
import '../entities/medication_history.dart';

/// Contract ของ Medication History Repository ให้ Domain Layer เรียกใช้โดยไม่รู้จัก Hive
///
/// หมายเหตุ: ประวัติการทานยาไม่ถูกลบตามเมื่อลบยาทิ้ง (ต่างจาก Schedule) เพราะ
/// MedicationHistory เก็บสำเนาชื่อยาไว้แล้ว ประวัติจึงยังมีความหมายและควรอยู่ต่อ
/// เป็นบันทึกย้อนหลังแม้ยาต้นทางจะถูกลบไปแล้ว
abstract class MedicationHistoryRepository {
  /// ดึงประวัติการทานยาทั้งหมด
  Future<Result<List<MedicationHistory>>> getHistory();

  /// บันทึกประวัติการทานยาใหม่หนึ่งรายการ
  Future<Result<void>> recordIntake(MedicationHistory history);
}
