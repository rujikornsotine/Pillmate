/// สถานะสิทธิ์ที่จำเป็นต่อการแจ้งเตือนทานยา (Domain Entity ไม่มี dependency กับ Flutter)
///
/// แยกเป็น 2 สิทธิ์เพราะมีผลต่างกัน
/// - ไม่ได้ [notificationsEnabled] คือแจ้งเตือนไม่ขึ้นเลย
/// - ไม่ได้ [exactAlarmsAllowed] คือยังแจ้งเตือนได้ แต่เวลาอาจคลาดเคลื่อนหลายนาที
///   เพราะระบบจะจัดกลุ่มการปลุกเพื่อประหยัดแบตเตอรี่
class ReminderPermissionStatus {
  const ReminderPermissionStatus({
    required this.notificationsEnabled,
    required this.exactAlarmsAllowed,
  });

  /// อนุญาตให้แอปแสดงการแจ้งเตือนหรือไม่ (Android 13+ ต้องขอจากผู้ใช้)
  final bool notificationsEnabled;

  /// อนุญาตให้ตั้งการปลุกแบบตรงเวลาหรือไม่
  ///
  /// Android 14 ขึ้นไปจะไม่อนุญาตให้อัตโนมัติ ผู้ใช้ต้องเปิดเองใน
  /// การตั้งค่าระบบ > การเข้าถึงพิเศษ > การปลุกและการช่วยเตือน
  final bool exactAlarmsAllowed;

  /// true เมื่อได้รับสิทธิ์ครบ การแจ้งเตือนจะทำงานตรงเวลาตามที่ตั้งไว้
  bool get isFullyGranted => notificationsEnabled && exactAlarmsAllowed;

  /// true เมื่อยังมีสิทธิ์ที่ควรแจ้งให้ผู้ใช้ทราบและขอเพิ่ม
  bool get needsAttention => !isFullyGranted;
}
