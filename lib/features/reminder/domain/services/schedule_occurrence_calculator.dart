import '../entities/schedule.dart';

/// คำนวณเวลาที่ยาแต่ละมื้อของตารางหนึ่งจะต้องแจ้งเตือน ภายในช่วงเวลาที่กำหนด
///
/// เป็น Pure Dart ไม่มี dependency กับ Flutter หรือ flutter_local_notifications
/// เพื่อให้ทดสอบได้ง่ายและสอดคล้องกับกฎ Domain Layer ใน architecture.md
class ScheduleOccurrenceCalculator {
  ScheduleOccurrenceCalculator._();

  /// สร้างคีย์ระบุมื้อยาหนึ่งมื้อแบบไม่ซ้ำกัน จากรหัสยา + เวลาที่ต้องทาน
  /// ใช้ให้ตรงกันทั้งฝั่งประวัติการทานยา (บันทึกด้วย scheduledAt) และฝั่งการแจ้งเตือน
  /// (คำนวณจาก occurrence) เพื่อจับคู่กันได้ว่ามื้อไหนทานแล้ว
  static String doseKey(String medicationId, DateTime occurrence) {
    return '$medicationId|${occurrence.toIso8601String()}';
  }

  /// คำนวณเวลาแจ้งเตือนทั้งหมดของ [schedule] ตั้งแต่ [from] ไปอีก [windowDays] วัน
  /// โดยจะไม่คำนวณเวลาที่อยู่ก่อน [schedule.startDate] หรือหลัง [schedule.endDate]
  static List<DateTime> calculate(
    Schedule schedule, {
    required DateTime from,
    required int windowDays,
  }) {
    final windowEnd = from.add(Duration(days: windowDays));

    var rangeStart = from;
    if (schedule.startDate.isAfter(rangeStart)) {
      rangeStart = schedule.startDate;
    }

    var rangeEnd = windowEnd;
    if (schedule.endDate != null && schedule.endDate!.isBefore(rangeEnd)) {
      rangeEnd = schedule.endDate!;
    }

    if (rangeStart.isAfter(rangeEnd)) return const [];

    return switch (schedule.frequency) {
      ScheduleFrequency.daily => _byDay(
        schedule,
        rangeStart,
        rangeEnd,
        matchesDay: (_) => true,
      ),
      ScheduleFrequency.weekly => _byDay(
        schedule,
        rangeStart,
        rangeEnd,
        matchesDay: (day) => schedule.weekdays.contains(day.weekday),
      ),
      ScheduleFrequency.everyNDays => _byDay(
        schedule,
        rangeStart,
        rangeEnd,
        matchesDay: _matchesIntervalDays(schedule),
      ),
      ScheduleFrequency.intervalHours => _byInterval(
        schedule,
        rangeStart,
        rangeEnd,
      ),
    };
  }

  static bool Function(DateTime day) _matchesIntervalDays(Schedule schedule) {
    final intervalDays = schedule.intervalDays;
    if (intervalDays == null || intervalDays <= 0) {
      return (_) => false;
    }
    final startDateOnly = DateTime(
      schedule.startDate.year,
      schedule.startDate.month,
      schedule.startDate.day,
    );
    return (day) => day.difference(startDateOnly).inDays % intervalDays == 0;
  }

  static List<DateTime> _byDay(
    Schedule schedule,
    DateTime start,
    DateTime end, {
    required bool Function(DateTime day) matchesDay,
  }) {
    final result = <DateTime>[];
    var day = DateTime(start.year, start.month, start.day);
    final lastDay = DateTime(end.year, end.month, end.day);

    while (!day.isAfter(lastDay)) {
      if (matchesDay(day)) {
        for (final time in schedule.times) {
          final occurrence = _combine(day, time);
          if (!occurrence.isBefore(start) && !occurrence.isAfter(end)) {
            result.add(occurrence);
          }
        }
      }
      day = day.add(const Duration(days: 1));
    }
    return result;
  }

  static List<DateTime> _byInterval(
    Schedule schedule,
    DateTime start,
    DateTime end,
  ) {
    final intervalHours = schedule.intervalHours;
    final startTime = schedule.startTime;
    if (intervalHours == null || intervalHours <= 0 || startTime == null) {
      return const [];
    }

    final firstOccurrence = _combine(
      DateTime(
        schedule.startDate.year,
        schedule.startDate.month,
        schedule.startDate.day,
      ),
      startTime,
    );
    final intervalMinutes = intervalHours * 60;

    // ข้ามไปยังมื้อแรกที่ >= start โดยตรงด้วยการคำนวณ (ไม่ loop ทีละมื้อ)
    var occurrence = firstOccurrence;
    final minutesBehind = start.difference(firstOccurrence).inMinutes;
    if (minutesBehind > 0) {
      final stepsToSkip = (minutesBehind / intervalMinutes).ceil();
      occurrence = firstOccurrence.add(
        Duration(minutes: intervalMinutes * stepsToSkip),
      );
    }

    final result = <DateTime>[];
    while (!occurrence.isAfter(end)) {
      if (!occurrence.isBefore(start)) {
        result.add(occurrence);
      }
      occurrence = occurrence.add(Duration(minutes: intervalMinutes));
    }
    return result;
  }

  static DateTime _combine(DateTime day, String time) {
    final parts = time.split(':');
    return DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
