/// รูปแบบการรับประทานยาซ้ำ
enum ScheduleFrequency {
  /// ทุกวัน
  daily,

  /// เฉพาะวันในสัปดาห์ที่เลือก
  weekly,

  /// ทุก X ชั่วโมง
  intervalHours,

  /// ทุก X วัน (เช่น วันเว้นวัน)
  everyNDays,
}

/// ตารางการรับประทานยาหนึ่งรายการ ผูกกับยาหนึ่งชนิดผ่าน medicationId
/// (Domain Entity ไม่มี dependency กับ Flutter หรือ Hive)
class Schedule {
  const Schedule({
    required this.id,
    required this.medicationId,
    required this.frequency,
    this.weekdays = const [],
    this.times = const [],
    this.intervalHours,
    this.startTime,
    this.intervalDays,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// รหัสประจำตัวตารางยา ไม่ซ้ำกัน
  final String id;

  /// รหัสยาที่ตารางนี้ผูกอยู่
  final String medicationId;

  /// รูปแบบการรับประทานยาซ้ำ
  final ScheduleFrequency frequency;

  /// วันในสัปดาห์ที่ต้องทานยา (1 = จันทร์ ... 7 = อาทิตย์) ใช้เมื่อ frequency เป็น weekly เท่านั้น
  final List<int> weekdays;

  /// เวลาที่ต้องทานยาในแต่ละวัน รูปแบบ HH:mm ใช้เมื่อ frequency เป็น daily, weekly หรือ everyNDays เท่านั้น
  final List<String> times;

  /// จำนวนชั่วโมงที่เว้นระหว่างมื้อ ใช้เมื่อ frequency เป็น intervalHours เท่านั้น
  final int? intervalHours;

  /// เวลาทานมื้อแรกของวัน รูปแบบ HH:mm ใช้เมื่อ frequency เป็น intervalHours เท่านั้น
  final String? startTime;

  /// จำนวนวันที่เว้นระหว่างวันที่ทาน (เช่น 2 = วันเว้นวัน) ใช้เมื่อ frequency เป็น everyNDays เท่านั้น
  final int? intervalDays;

  /// วันที่เริ่มตารางนี้
  final DateTime startDate;

  /// วันที่สิ้นสุดตารางนี้ ถ้าเป็น null คือไม่มีกำหนดสิ้นสุด
  final DateTime? endDate;

  /// สถานะเปิด/ปิดใช้งานตาราง โดยไม่ต้องลบทิ้ง
  final bool isActive;

  /// เวลาที่สร้างข้อมูล
  final DateTime createdAt;

  /// เวลาที่แก้ไขข้อมูลล่าสุด
  final DateTime updatedAt;
}
