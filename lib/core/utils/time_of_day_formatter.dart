import 'package:flutter/material.dart';

/// แปลงระหว่าง TimeOfDay กับข้อความรูปแบบ HH:mm ที่ใช้เก็บลง Hive
class TimeOfDayFormatter {
  TimeOfDayFormatter._();

  /// แปลง TimeOfDay เป็นข้อความ เช่น "08:05"
  static String format(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// แปลงข้อความรูปแบบ HH:mm กลับเป็น TimeOfDay
  static TimeOfDay parse(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
