/// ค่าคงที่เกี่ยวกับการแจ้งเตือนทานยา
class ReminderConstants {
  ReminderConstants._();

  /// Channel ของการแจ้งเตือนทานยาบน Android
  static const String androidChannelId = 'medication_reminders';
  static const String androidChannelName = 'แจ้งเตือนการทานยา';
  static const String androidChannelDescription =
      'แจ้งเตือนเมื่อถึงเวลารับประทานยา';

  /// Category ของการแจ้งเตือนทานยาบน iOS/macOS
  static const String darwinCategoryId = 'medicationReminder';

  /// รหัส Action บนการแจ้งเตือน
  static const String actionMarkAsTaken = 'mark_taken';
  static const String actionSnooze = 'snooze';

  /// รหัสเหตุการณ์พิเศษเมื่อผู้ใช้แตะที่ตัวการแจ้งเตือนโดยตรง (ไม่ใช่ปุ่ม action ใดๆ)
  /// ใช้แยกจาก actionId จริงที่มาจากปลั๊กอิน เพื่อรู้ว่าต้องแสดง popup ยืนยันการทานยา
  static const String actionOpen = 'notification_opened';

  /// ระยะเวลาก่อนแจ้งเตือนซ้ำ หากยังไม่กดยืนยันว่าทานยาแล้ว
  static const Duration followUpDelay = Duration(minutes: 15);

  /// ระยะเวลาที่เลื่อนการแจ้งเตือนออกไปเมื่อกด "เลื่อน"
  static const Duration snoozeDelay = Duration(minutes: 15);

  /// จำนวนวันล่วงหน้าที่คำนวณและตั้งเวลาแจ้งเตือนไว้ล่วงหน้าในคราวเดียว
  /// (ระบบไม่มี Background Task รันตลอดเวลา จึงต้องคำนวณใหม่ทุกครั้งที่เปิดแอป
  /// หรือมีการแก้ไขตารางยา เพื่อ "เลื่อนหน้าต่าง" การแจ้งเตือนไปข้างหน้าเรื่อยๆ)
  static const int syncWindowDays = 7;
}
