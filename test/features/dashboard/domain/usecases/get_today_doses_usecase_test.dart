import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/history/domain/entities/medication_history.dart';
import 'package:pillmate/features/history/domain/repositories/medication_history_repository.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';
import 'package:pillmate/features/medication/domain/repositories/medication_repository.dart';
import 'package:pillmate/features/dashboard/domain/usecases/get_today_doses_usecase.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';
import 'package:pillmate/features/reminder/domain/repositories/schedule_repository.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

class MockMedicationRepository extends Mock implements MedicationRepository {}

class MockMedicationHistoryRepository extends Mock
    implements MedicationHistoryRepository {}

void main() {
  late MockScheduleRepository scheduleRepository;
  late MockMedicationRepository medicationRepository;
  late MockMedicationHistoryRepository historyRepository;
  late GetTodayDosesUseCase useCase;
  late Medication medication;

  final now = DateTime.now();
  final today8 = DateTime(now.year, now.month, now.day, 8);
  final today20 = DateTime(now.year, now.month, now.day, 20);

  setUp(() {
    scheduleRepository = MockScheduleRepository();
    medicationRepository = MockMedicationRepository();
    historyRepository = MockMedicationHistoryRepository();
    useCase = GetTodayDosesUseCase(
      scheduleRepository: scheduleRepository,
      medicationRepository: medicationRepository,
      historyRepository: historyRepository,
    );
    medication = Medication(
      id: 'med-1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      createdAt: DateTime(2020, 1, 1),
      updatedAt: DateTime(2020, 1, 1),
    );
    when(
      () => medicationRepository.getMedications(),
    ).thenAnswer((_) async => Result.success([medication]));
    when(
      () => historyRepository.getHistory(),
    ).thenAnswer((_) async => const Result.success([]));
  });

  Schedule dailySchedule() => Schedule(
    id: 'sch-1',
    medicationId: 'med-1',
    frequency: ScheduleFrequency.daily,
    times: const ['08:00', '20:00'],
    startDate: DateTime(2020, 1, 1),
    createdAt: DateTime(2020, 1, 1),
    updatedAt: DateTime(2020, 1, 1),
  );

  test('คืนค่ามื้อยาวันนี้ทุกมื้อ เรียงตามเวลา สถานะยังไม่ทานเมื่อไม่มีประวัติ', () async {
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([dailySchedule()]));

    final result = await useCase.call();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (doses) {
        expect(doses.length, 2);
        expect(doses[0].scheduledAt, today8);
        expect(doses[1].scheduledAt, today20);
        expect(doses[0].isTaken, isFalse);
        expect(doses[0].status, isNull);
      },
      failure: (_) => fail('should not fail'),
    );
  });

  test('มื้อที่มีประวัติสถานะทานแล้ว จะแสดง isTaken เป็น true', () async {
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([dailySchedule()]));
    when(() => historyRepository.getHistory()).thenAnswer(
      (_) async => Result.success([
        MedicationHistory(
          id: 'h1',
          medicationId: 'med-1',
          medicationName: 'พาราเซตามอล',
          scheduledAt: today8,
          recordedAt: today8,
          status: IntakeStatus.taken,
        ),
      ]),
    );

    final result = await useCase.call();

    result.when(
      success: (doses) {
        expect(doses[0].scheduledAt, today8);
        expect(doses[0].isTaken, isTrue);
        expect(doses[1].scheduledAt, today20);
        expect(doses[1].isTaken, isFalse);
      },
      failure: (_) => fail('should not fail'),
    );
  });

  test('ตารางที่ยังไม่เริ่ม (startDate อนาคต) จะไม่มีมื้อวันนี้', () async {
    final future = DateTime(now.year + 1, now.month, now.day);
    final schedule = Schedule(
      id: 'sch-2',
      medicationId: 'med-1',
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: future,
      createdAt: DateTime(2020, 1, 1),
      updatedAt: DateTime(2020, 1, 1),
    );
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([schedule]));

    final result = await useCase.call();

    result.when(
      success: (doses) => expect(doses, isEmpty),
      failure: (_) => fail('should not fail'),
    );
  });

  test('ข้ามตารางที่ปิดใช้งาน (isActive เป็น false)', () async {
    final schedule = Schedule(
      id: 'sch-3',
      medicationId: 'med-1',
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: DateTime(2020, 1, 1),
      isActive: false,
      createdAt: DateTime(2020, 1, 1),
      updatedAt: DateTime(2020, 1, 1),
    );
    when(
      () => scheduleRepository.getSchedules(),
    ).thenAnswer((_) async => Result.success([schedule]));

    final result = await useCase.call();

    result.when(
      success: (doses) => expect(doses, isEmpty),
      failure: (_) => fail('should not fail'),
    );
  });
}
