import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/history/domain/entities/medication_history.dart';
import 'package:pillmate/features/history/domain/repositories/medication_history_repository.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';
import 'package:pillmate/features/medication/domain/repositories/medication_repository.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';
import 'package:pillmate/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:pillmate/features/reminder/domain/repositories/schedule_repository.dart';
import 'package:pillmate/features/reminder/domain/services/schedule_occurrence_calculator.dart';
import 'package:pillmate/features/reminder/domain/usecases/sync_reminders_usecase.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

class MockScheduleRepository extends Mock implements ScheduleRepository {}

class MockMedicationRepository extends Mock implements MedicationRepository {}

class MockMedicationHistoryRepository extends Mock
    implements MedicationHistoryRepository {}

class _FakeSchedule extends Fake implements Schedule {}

class _FakeMedication extends Fake implements Medication {}

void main() {
  late MockReminderRepository reminderRepository;
  late MockScheduleRepository scheduleRepository;
  late MockMedicationRepository medicationRepository;
  late MockMedicationHistoryRepository historyRepository;
  late SyncRemindersUseCase useCase;
  late Medication medication;

  setUpAll(() {
    registerFallbackValue(_FakeSchedule());
    registerFallbackValue(_FakeMedication());
  });

  setUp(() {
    reminderRepository = MockReminderRepository();
    scheduleRepository = MockScheduleRepository();
    medicationRepository = MockMedicationRepository();
    historyRepository = MockMedicationHistoryRepository();
    useCase = SyncRemindersUseCase(
      reminderRepository: reminderRepository,
      scheduleRepository: scheduleRepository,
      medicationRepository: medicationRepository,
      historyRepository: historyRepository,
    );
    medication = Medication(
      id: 'med-1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    when(
      () => reminderRepository.cancelAllReminders(),
    ).thenAnswer((_) async => const Result.success(null));
    when(
      () => reminderRepository.scheduleReminders(
        schedule: any(named: 'schedule'),
        medication: any(named: 'medication'),
        takenDoseKeys: any(named: 'takenDoseKeys'),
      ),
    ).thenAnswer((_) async => const Result.success(null));
    // ปริยาย: ไม่มีประวัติการทานยา
    when(
      () => historyRepository.getHistory(),
    ).thenAnswer((_) async => const Result.success([]));
  });

  Schedule buildSchedule({
    bool isActive = true,
    DateTime? endDate,
    String medicationId = 'med-1',
  }) {
    return Schedule(
      id: 'sch-1',
      medicationId: medicationId,
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: DateTime(2026, 1, 1),
      endDate: endDate,
      isActive: isActive,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  test('ยกเลิกการแจ้งเตือนเดิมทั้งหมดก่อน แล้วตั้งใหม่จากตารางที่ active', () async {
    final schedule = buildSchedule();
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([schedule]));
    when(
      () => medicationRepository.getMedications(),
    ).thenAnswer((_) async => Result.success([medication]));

    final result = await useCase.call();

    expect(result.isSuccess, isTrue);
    verify(() => reminderRepository.cancelAllReminders()).called(1);
    verify(
      () => reminderRepository.scheduleReminders(
        schedule: schedule,
        medication: medication,
        takenDoseKeys: any(named: 'takenDoseKeys'),
      ),
    ).called(1);
  });

  test('ส่งคีย์ของมื้อที่ทานแล้วไปให้ scheduleReminders เพื่อข้ามการตั้งแจ้งเตือน', () async {
    final schedule = buildSchedule();
    final scheduledAt = DateTime(2026, 1, 2, 8);
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([schedule]));
    when(
      () => medicationRepository.getMedications(),
    ).thenAnswer((_) async => Result.success([medication]));
    when(() => historyRepository.getHistory()).thenAnswer(
      (_) async => Result.success([
        MedicationHistory(
          id: 'h1',
          medicationId: 'med-1',
          medicationName: 'พาราเซตามอล',
          scheduledAt: scheduledAt,
          recordedAt: scheduledAt,
          status: IntakeStatus.taken,
        ),
        // สถานะ snoozed ไม่นับเป็นทานแล้ว จึงไม่ควรถูกใส่ในคีย์ที่ข้าม
        MedicationHistory(
          id: 'h2',
          medicationId: 'med-1',
          medicationName: 'พาราเซตามอล',
          scheduledAt: DateTime(2026, 1, 3, 8),
          recordedAt: DateTime(2026, 1, 3, 8),
          status: IntakeStatus.snoozed,
        ),
      ]),
    );

    await useCase.call();

    final captured = verify(
      () => reminderRepository.scheduleReminders(
        schedule: any(named: 'schedule'),
        medication: any(named: 'medication'),
        takenDoseKeys: captureAny(named: 'takenDoseKeys'),
      ),
    ).captured;
    final takenKeys = captured.single as Set<String>;
    expect(
      takenKeys,
      contains(ScheduleOccurrenceCalculator.doseKey('med-1', scheduledAt)),
    );
    expect(
      takenKeys,
      isNot(
        contains(
          ScheduleOccurrenceCalculator.doseKey('med-1', DateTime(2026, 1, 3, 8)),
        ),
      ),
    );
  });

  test('ข้ามตารางที่ isActive เป็น false', () async {
    final schedule = buildSchedule(isActive: false);
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([schedule]));
    when(
      () => medicationRepository.getMedications(),
    ).thenAnswer((_) async => Result.success([medication]));

    await useCase.call();

    verifyNever(
      () => reminderRepository.scheduleReminders(
        schedule: any(named: 'schedule'),
        medication: any(named: 'medication'),
        takenDoseKeys: any(named: 'takenDoseKeys'),
      ),
    );
  });

  test('ข้ามตารางที่หมดอายุแล้ว (endDate ผ่านมาแล้ว)', () async {
    final schedule = buildSchedule(endDate: DateTime(2020, 1, 1));
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([schedule]));
    when(
      () => medicationRepository.getMedications(),
    ).thenAnswer((_) async => Result.success([medication]));

    await useCase.call();

    verifyNever(
      () => reminderRepository.scheduleReminders(
        schedule: any(named: 'schedule'),
        medication: any(named: 'medication'),
        takenDoseKeys: any(named: 'takenDoseKeys'),
      ),
    );
  });

  test('ข้ามตารางที่ไม่พบข้อมูลยาที่ผูกอยู่ (ตารางกำพร้า)', () async {
    final schedule = buildSchedule(medicationId: 'unknown-med');
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([schedule]));
    when(
      () => medicationRepository.getMedications(),
    ).thenAnswer((_) async => Result.success([medication]));

    await useCase.call();

    verifyNever(
      () => reminderRepository.scheduleReminders(
        schedule: any(named: 'schedule'),
        medication: any(named: 'medication'),
        takenDoseKeys: any(named: 'takenDoseKeys'),
      ),
    );
  });

  test(
    'ตั้งตารางที่เหลือต่อจนครบแม้ตารางหนึ่งล้มเหลว แล้วคืนค่า failure ไม่เงียบหาย',
    () async {
      final failing = buildSchedule();
      final succeeding = buildSchedule(medicationId: 'med-1');
      when(
        () => scheduleRepository.getSchedules(),
      ).thenAnswer((_) async => Result.success([failing, succeeding]));
      when(
        () => medicationRepository.getMedications(),
      ).thenAnswer((_) async => Result.success([medication]));
      when(
        () => reminderRepository.scheduleReminders(
          schedule: failing,
          medication: any(named: 'medication'),
          takenDoseKeys: any(named: 'takenDoseKeys'),
        ),
      ).thenAnswer((_) async => const Result.failure('ไม่ได้รับสิทธิ์ปลุกตรงเวลา'));

      final result = await useCase.call();

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (message) => expect(message, 'ไม่ได้รับสิทธิ์ปลุกตรงเวลา'),
      );
      // ตารางที่เหลือต้องถูกตั้งต่อ ไม่หยุดกลางคัน
      verify(
        () => reminderRepository.scheduleReminders(
          schedule: succeeding,
          medication: any(named: 'medication'),
          takenDoseKeys: any(named: 'takenDoseKeys'),
        ),
      ).called(1);
    },
  );

  test('คืนค่า failure ถ้าโหลดตารางยาไม่สำเร็จ และไม่ยกเลิกการแจ้งเตือนเดิม', () async {
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => const Result.failure('โหลดไม่สำเร็จ'));
    when(
      () => medicationRepository.getMedications(),
    ).thenAnswer((_) async => Result.success([medication]));

    final result = await useCase.call();

    expect(result.isFailure, isTrue);
    verifyNever(() => reminderRepository.cancelAllReminders());
  });
}
