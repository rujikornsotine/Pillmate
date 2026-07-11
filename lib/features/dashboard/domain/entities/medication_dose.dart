import '../../../history/domain/entities/medication_history.dart';
import '../../../medication/domain/entities/medication.dart';

/// มื้อยาหนึ่งมื้อที่ต้องรับประทานในวันหนึ่ง คำนวณจากตารางยา แล้วเทียบกับประวัติ
/// เพื่อบอกสถานะว่าทานแล้วหรือยัง (Domain Entity ไม่มี dependency กับ Flutter)
class MedicationDose {
  const MedicationDose({
    required this.medication,
    required this.scheduledAt,
    this.status,
  });

  /// ข้อมูลยาของมื้อนี้
  final Medication medication;

  /// เวลาที่ต้องทานยาตามตารางที่ตั้งไว้
  final DateTime scheduledAt;

  /// สถานะจากประวัติการทานยา ถ้าเป็น null คือยังไม่มีการบันทึก (ยังไม่ทาน)
  final IntakeStatus? status;

  /// true ถ้ามื้อนี้ถูกยืนยันการทานแล้ว
  bool get isTaken => status == IntakeStatus.taken;
}
