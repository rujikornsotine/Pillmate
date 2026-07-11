/// ชื่อ Hive Box ทั้งหมดที่ใช้ในแอปพลิเคชัน ตามที่กำหนดใน architecture.md
class HiveBoxes {
  HiveBoxes._();

  static const String medications = 'medications';
  static const String schedules = 'schedules';
  static const String histories = 'histories';
  static const String settings = 'settings';
}

/// typeId ของ Hive TypeAdapter แต่ละตัว ต้องไม่ซ้ำกันภายในแอป
class HiveTypeIds {
  HiveTypeIds._();

  static const int medicationModel = 0;
  static const int scheduleModel = 1;
  static const int medicationHistoryModel = 2;
}
