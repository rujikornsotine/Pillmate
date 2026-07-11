import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/constants/reminder_constants.dart';
import 'package:pillmate/core/services/notification_service.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';
import 'package:pillmate/features/reminder/data/repositories/reminder_repository_impl.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';
import 'package:pillmate/features/reminder/domain/services/schedule_occurrence_calculator.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockNotificationService notificationService;
  late ReminderRepositoryImpl repository;

  setUp(() {
    notificationService = MockNotificationService();
    repository = ReminderRepositoryImpl(
      notificationService: notificationService,
    );
  });

  test('requestPermission คืนค่า Success พร้อมผลลัพธ์จาก service', () async {
    when(
      () => notificationService.requestPermission(),
    ).thenAnswer((_) async => true);

    final result = await repository.requestPermission();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (granted) => expect(granted, isTrue),
      failure: (_) => fail('should not fail'),
    );
  });

  test('cancelAllReminders เรียก service.cancelAll', () async {
    when(() => notificationService.cancelAll()).thenAnswer((_) async {});

    final result = await repository.cancelAllReminders();

    expect(result.isSuccess, isTrue);
    verify(() => notificationService.cancelAll()).called(1);
  });

  test('scheduleReminders ตั้งเวลาแจ้งเตือนสำหรับทุกมื้อที่คำนวณได้', () async {
    when(
      () => notificationService.scheduleDoseReminder(
        medicationId: any(named: 'medicationId'),
        occurrence: any(named: 'occurrence'),
        medicationName: any(named: 'medicationName'),
        dosage: any(named: 'dosage'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async {});

    final schedule = Schedule(
      id: 'sch-1',
      medicationId: 'med-1',
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final medication = Medication(
      id: 'med-1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await repository.scheduleReminders(
      schedule: schedule,
      medication: medication,
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => notificationService.scheduleDoseReminder(
        medicationId: 'med-1',
        occurrence: any(named: 'occurrence'),
        medicationName: 'พาราเซตามอล',
        dosage: '500 mg',
        quantity: '1 เม็ด',
      ),
    ).called(greaterThan(0));
  });

  test('scheduleReminders ข้ามมื้อที่อยู่ใน takenDoseKeys ไม่ตั้งแจ้งเตือน', () async {
    when(
      () => notificationService.scheduleDoseReminder(
        medicationId: any(named: 'medicationId'),
        occurrence: any(named: 'occurrence'),
        medicationName: any(named: 'medicationName'),
        dosage: any(named: 'dosage'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async {});

    final schedule = Schedule(
      id: 'sch-1',
      medicationId: 'med-1',
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final medication = Medication(
      id: 'med-1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // สร้างคีย์ของทุกมื้อที่จะถูกคำนวณ เพื่อให้ถูกข้ามทั้งหมด
    final occurrences = ScheduleOccurrenceCalculator.calculate(
      schedule,
      from: DateTime.now(),
      windowDays: ReminderConstants.syncWindowDays,
    );
    final takenKeys = occurrences
        .map((o) => ScheduleOccurrenceCalculator.doseKey('med-1', o))
        .toSet();

    final result = await repository.scheduleReminders(
      schedule: schedule,
      medication: medication,
      takenDoseKeys: takenKeys,
    );

    expect(result.isSuccess, isTrue);
    verifyNever(
      () => notificationService.scheduleDoseReminder(
        medicationId: any(named: 'medicationId'),
        occurrence: any(named: 'occurrence'),
        medicationName: any(named: 'medicationName'),
        dosage: any(named: 'dosage'),
        quantity: any(named: 'quantity'),
      ),
    );
  });

  test('cancelDoseReminder เรียก service ยกเลิกมื้อยาที่ระบุ', () async {
    final occurrence = DateTime(2026, 1, 2, 8);
    when(
      () => notificationService.cancelDoseReminder(
        medicationId: any(named: 'medicationId'),
        occurrence: any(named: 'occurrence'),
      ),
    ).thenAnswer((_) async {});

    final result = await repository.cancelDoseReminder(
      medicationId: 'med-1',
      occurrence: occurrence,
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => notificationService.cancelDoseReminder(
        medicationId: 'med-1',
        occurrence: occurrence,
      ),
    ).called(1);
  });
}
