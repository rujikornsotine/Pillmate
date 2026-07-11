/// สถานะการรับประทานยาที่บันทึกไว้ในประวัติ
enum IntakeStatus {
  /// ทานแล้ว
  taken,

  /// เลื่อนการทาน
  snoozed,

  /// ข้ามการทาน
  skipped,
}

/// ประวัติการรับประทานยาหนึ่งรายการ (Domain Entity ไม่มี dependency กับ Flutter หรือ Hive)
class MedicationHistory {
  const MedicationHistory({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledAt,
    required this.recordedAt,
    required this.status,
  });

  /// รหัสประจำตัวของรายการประวัติ
  final String id;

  /// รหัสยาที่เกี่ยวข้อง
  final String medicationId;

  /// ชื่อยา ณ เวลาที่บันทึก (เก็บสำเนาไว้เผื่อยาถูกแก้ไขชื่อหรือลบภายหลัง)
  final String medicationName;

  /// เวลาที่ควรรับประทานยาตามตารางที่ตั้งไว้
  final DateTime scheduledAt;

  /// เวลาที่ผู้ใช้งานยืนยัน/เลื่อน/ข้ามการทานยาจริง
  final DateTime recordedAt;

  /// สถานะการรับประทานยา
  final IntakeStatus status;
}
