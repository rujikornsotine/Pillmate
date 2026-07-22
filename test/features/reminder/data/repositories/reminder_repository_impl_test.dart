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
    // ค่าเริ่มต้น: ได้รับสิทธิ์ปลุกตรงเวลา เทสต์ที่สนใจกรณีไม่ได้รับสิทธิ์จะ stub ทับเอง
    when(
      () => notificationService.canScheduleExactAlarms(),
    ).thenAnswer((_) async => true);
  });

  /// stub การตั้งเวลาแจ้งเตือนแบบรับทุก argument ใช้ร่วมกันหลายเทสต์
  void stubScheduleDoseReminder() {
    when(
      () => notificationService.scheduleDoseReminder(
        medicationId: any(named: 'medicationId'),
        occurrence: any(named: 'occurrence'),
        medicationName: any(named: 'medicationName'),
        dosage: any(named: 'dosage'),
        quantity: any(named: 'quantity'),
        useExactAlarm: any(named: 'useExactAlarm'),
      ),
    ).thenAnswer((_) async {});
  }

  Schedule buildDailySchedule() => Schedule(
    id: 'sch-1',
    medicationId: 'med-1',
    frequency: ScheduleFrequency.daily,
    times: const ['08:00'],
    startDate: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Medication buildMedication() => Medication(
    id: 'med-1',
    name: 'พาราเซตามอล',
    dosage: '500 mg',
    quantity: '1 เม็ด',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

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
    stubScheduleDoseReminder();

    final result = await repository.scheduleReminders(
      schedule: buildDailySchedule(),
      medication: buildMedication(),
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => notificationService.scheduleDoseReminder(
        medicationId: 'med-1',
        occurrence: any(named: 'occurrence'),
        medicationName: 'พาราเซตามอล',
        dosage: '500 mg',
        quantity: '1 เม็ด',
        useExactAlarm: true,
      ),
    ).called(greaterThan(0));
  });

  test(
    'scheduleReminders ยังตั้งแจ้งเตือนต่อแบบไม่ตรงเวลา เมื่อไม่ได้รับสิทธิ์ปลุกตรงเวลา',
    () async {
      stubScheduleDoseReminder();
      when(
        () => notificationService.canScheduleExactAlarms(),
      ).thenAnswer((_) async => false);

      final result = await repository.scheduleReminders(
        schedule: buildDailySchedule(),
        medication: buildMedication(),
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => notificationService.scheduleDoseReminder(
          medicationId: 'med-1',
          occurrence: any(named: 'occurrence'),
          medicationName: any(named: 'medicationName'),
          dosage: any(named: 'dosage'),
          quantity: any(named: 'quantity'),
          useExactAlarm: false,
        ),
      ).called(greaterThan(0));
    },
  );

  test('scheduleReminders ถามสิทธิ์ปลุกตรงเวลาครั้งเดียวต่อหนึ่งตาราง', () async {
    stubScheduleDoseReminder();

    await repository.scheduleReminders(
      schedule: buildDailySchedule(),
      medication: buildMedication(),
    );

    verify(() => notificationService.canScheduleExactAlarms()).called(1);
  });

  test('getPermissionStatus รวมสถานะสิทธิ์ทั้งสองอย่างเข้าด้วยกัน', () async {
    when(
      () => notificationService.areNotificationsEnabled(),
    ).thenAnswer((_) async => true);
    when(
      () => notificationService.canScheduleExactAlarms(),
    ).thenAnswer((_) async => false);

    final result = await repository.getPermissionStatus();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (status) {
        expect(status.notificationsEnabled, isTrue);
        expect(status.exactAlarmsAllowed, isFalse);
        expect(status.isFullyGranted, isFalse);
        expect(status.needsAttention, isTrue);
      },
      failure: (_) => fail('should not fail'),
    );
  });

  test('requestExactAlarmPermission คืนค่าผลลัพธ์จาก service', () async {
    when(
      () => notificationService.requestExactAlarmsPermission(),
    ).thenAnswer((_) async => true);

    final result = await repository.requestExactAlarmPermission();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (granted) => expect(granted, isTrue),
      failure: (_) => fail('should not fail'),
    );
    verify(() => notificationService.requestExactAlarmsPermission()).called(1);
  });

  test('scheduleReminders ข้ามมื้อที่อยู่ใน takenDoseKeys ไม่ตั้งแจ้งเตือน', () async {
    stubScheduleDoseReminder();

    final schedule = buildDailySchedule();
    final medication = buildMedication();

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
        useExactAlarm: any(named: 'useExactAlarm'),
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
