/// ข้อมูลยาหนึ่งรายการ (Domain Entity ไม่มี dependency กับ Flutter หรือ Hive)
class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.quantity,
    this.imagePath,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// รหัสประจำตัวยา ไม่ซ้ำกัน
  final String id;

  /// ชื่อยา
  final String name;

  /// ขนาดยา เช่น "500 mg"
  final String dosage;

  /// จำนวนที่ต้องรับประทานต่อครั้ง เช่น "1 เม็ด"
  final String quantity;

  /// พาธรูปภาพยาที่เก็บในเครื่อง
  final String? imagePath;

  /// หมายเหตุเพิ่มเติม
  final String? note;

  /// เวลาที่สร้างข้อมูล
  final DateTime createdAt;

  /// เวลาที่แก้ไขข้อมูลล่าสุด
  final DateTime updatedAt;
}
