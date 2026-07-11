import 'dart:math';

/// ตัวสร้าง id ที่ไม่ซ้ำกันสำหรับข้อมูลในเครื่อง โดยไม่ต้องพึ่ง dependency เพิ่มเติม
class IdGenerator {
  IdGenerator._();

  static final Random _random = Random();

  /// สร้าง id ใหม่จากเวลาปัจจุบันรวมกับเลขสุ่ม
  static String generate() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final randomSuffix = _random.nextInt(1 << 32);
    return '$timestamp-$randomSuffix';
  }
}
