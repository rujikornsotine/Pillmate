import 'package:flutter_test/flutter_test.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';
import 'package:pillmate/features/reminder/domain/services/schedule_occurrence_calculator.dart';

void main() {
  group('ScheduleFrequency.daily', () {
    test('สร้างเวลาแจ้งเตือนทุกวันตามเวลาที่กำหนด ภายในหน้าต่าง 7 วัน', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.daily,
        times: const ['08:00', '20:00'],
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1, 7),
        windowDays: 3,
      );

      // หน้าต่างสิ้นสุดที่ 4 ม.ค. 07:00 พอดี จึงไม่รวมมื้อ 08:00/20:00 ของวันที่ 4
      expect(occurrences, [
        DateTime(2026, 1, 1, 8),
        DateTime(2026, 1, 1, 20),
        DateTime(2026, 1, 2, 8),
        DateTime(2026, 1, 2, 20),
        DateTime(2026, 1, 3, 8),
        DateTime(2026, 1, 3, 20),
      ]);
    });

    test('ไม่รวมเวลาที่ผ่านไปแล้วของวันแรก', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.daily,
        times: const ['08:00'],
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1, 9),
        windowDays: 1,
      );

      expect(occurrences, [DateTime(2026, 1, 2, 8)]);
    });

    test('หยุดสร้างเวลาแจ้งเตือนหลัง endDate', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.daily,
        times: const ['08:00'],
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 2, 23, 59),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1, 7),
        windowDays: 7,
      );

      expect(occurrences, [
        DateTime(2026, 1, 1, 8),
        DateTime(2026, 1, 2, 8),
      ]);
    });
  });

  group('ScheduleFrequency.weekly', () {
    test('สร้างเวลาแจ้งเตือนเฉพาะวันในสัปดาห์ที่เลือก', () {
      // 2026-01-01 คือวันพฤหัสบดี (weekday = 4)
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.weekly,
        weekdays: const [1, 3], // จันทร์, พุธ
        times: const ['09:00'],
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1),
        windowDays: 7,
      );

      // จันทร์ถัดไปคือ 5 ม.ค., พุธถัดไปคือ 7 ม.ค.
      expect(occurrences, [
        DateTime(2026, 1, 5, 9),
        DateTime(2026, 1, 7, 9),
      ]);
    });
  });

  group('ScheduleFrequency.intervalHours', () {
    test('สร้างเวลาแจ้งเตือนซ้ำทุก N ชั่วโมงนับจาก startTime', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.intervalHours,
        intervalHours: 8,
        startTime: '06:00',
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1),
        windowDays: 1,
      );

      expect(occurrences, [
        DateTime(2026, 1, 1, 6),
        DateTime(2026, 1, 1, 14),
        DateTime(2026, 1, 1, 22),
      ]);
    });

    test('ข้ามไปยังมื้อถัดไปที่ยังไม่ผ่านไปเมื่อ from อยู่ระหว่างวัน', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.intervalHours,
        intervalHours: 6,
        startTime: '06:00',
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 2, 10),
        windowDays: 1,
      );

      // มื้อคือ 06:00/12:00/18:00/00:00 ของทุกวันนับจาก 1 ม.ค. 06:00
      // หน้าต่าง [2 ม.ค. 10:00, 3 ม.ค. 10:00] จึงเหลือ 12:00, 18:00, 00:00(3), 06:00(3)
      expect(occurrences, [
        DateTime(2026, 1, 2, 12),
        DateTime(2026, 1, 2, 18),
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 3, 6),
      ]);
    });

    test('คืนค่าว่างถ้าไม่ได้กำหนด intervalHours หรือ startTime', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.intervalHours,
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1),
        windowDays: 7,
      );

      expect(occurrences, isEmpty);
    });
  });

  group('ScheduleFrequency.everyNDays', () {
    test('สร้างเวลาแจ้งเตือนทุก N วันนับจาก startDate (เช่น วันเว้นวัน)', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.everyNDays,
        intervalDays: 2,
        times: const ['08:00'],
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1),
        windowDays: 7,
      );

      expect(occurrences, [
        DateTime(2026, 1, 1, 8),
        DateTime(2026, 1, 3, 8),
        DateTime(2026, 1, 5, 8),
        DateTime(2026, 1, 7, 8),
      ]);
    });

    test('คืนค่าว่างถ้าไม่ได้กำหนด intervalDays', () {
      final schedule = Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.everyNDays,
        times: const ['08:00'],
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime(2026, 1, 1),
        windowDays: 7,
      );

      expect(occurrences, isEmpty);
    });
  });
}
