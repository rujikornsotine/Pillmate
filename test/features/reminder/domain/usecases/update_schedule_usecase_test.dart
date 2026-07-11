import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';
import 'package:pillmate/features/reminder/domain/repositories/schedule_repository.dart';
import 'package:pillmate/features/reminder/domain/usecases/update_schedule_usecase.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

class _FakeSchedule extends Fake implements Schedule {}

void main() {
  late MockScheduleRepository repository;
  late UpdateScheduleUseCase useCase;
  late Schedule existing;

  setUpAll(() {
    registerFallbackValue(_FakeSchedule());
  });

  setUp(() {
    repository = MockScheduleRepository();
    useCase = UpdateScheduleUseCase(repository: repository);
    existing = Schedule(
      id: '1',
      medicationId: 'med-1',
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 6, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  test('แก้ไขตารางยาโดยคง id, medicationId และ createdAt เดิม', () async {
    when(
      () => repository.updateSchedule(any()),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(
      existing: existing,
      frequency: ScheduleFrequency.weekly,
      weekdays: const [2, 4],
      times: const ['09:00'],
      startDate: existing.startDate,
    );

    expect(result.isSuccess, isTrue);
    final captured =
        verify(() => repository.updateSchedule(captureAny())).captured;
    final schedule = captured.single as Schedule;
    expect(schedule.id, existing.id);
    expect(schedule.medicationId, existing.medicationId);
    expect(schedule.createdAt, existing.createdAt);
    expect(schedule.frequency, ScheduleFrequency.weekly);
    expect(schedule.weekdays, [2, 4]);
    expect(schedule.updatedAt.isAfter(existing.updatedAt), isTrue);
  });

  test('ล้างค่า endDate และ intervalHours เป็น null ได้เมื่อเปลี่ยนรูปแบบ', () async {
    when(
      () => repository.updateSchedule(any()),
    ).thenAnswer((_) async => const Result.success(null));

    await useCase.call(
      existing: existing,
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: existing.startDate,
      // ไม่ส่ง endDate เท่ากับตั้งใจล้างค่า แม้ existing เคยมีค่าอยู่
    );

    final captured =
        verify(() => repository.updateSchedule(captureAny())).captured;
    final schedule = captured.single as Schedule;
    expect(schedule.endDate, isNull);
    expect(schedule.intervalHours, isNull);
  });

  test('คืนค่า failure เมื่อ repository แก้ไขไม่สำเร็จ', () async {
    when(
      () => repository.updateSchedule(any()),
    ).thenAnswer((_) async => const Result.failure('แก้ไขไม่สำเร็จ'));

    final result = await useCase.call(
      existing: existing,
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: existing.startDate,
    );

    expect(result.isFailure, isTrue);
  });
}
