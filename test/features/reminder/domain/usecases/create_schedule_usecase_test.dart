import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';
import 'package:pillmate/features/reminder/domain/repositories/schedule_repository.dart';
import 'package:pillmate/features/reminder/domain/usecases/create_schedule_usecase.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

class _FakeSchedule extends Fake implements Schedule {}

void main() {
  late MockScheduleRepository repository;
  late CreateScheduleUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_FakeSchedule());
  });

  setUp(() {
    repository = MockScheduleRepository();
    useCase = CreateScheduleUseCase(repository: repository);
  });

  test('สร้าง Schedule พร้อม id และเวลา แล้วส่งให้ repository บันทึก', () async {
    when(
      () => repository.createSchedule(any()),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(
      medicationId: 'med-1',
      frequency: ScheduleFrequency.weekly,
      weekdays: const [1, 3, 5],
      times: const ['08:00', '20:00'],
      startDate: DateTime(2026, 1, 1),
    );

    expect(result.isSuccess, isTrue);
    final captured =
        verify(() => repository.createSchedule(captureAny())).captured;
    final schedule = captured.single as Schedule;
    expect(schedule.medicationId, 'med-1');
    expect(schedule.frequency, ScheduleFrequency.weekly);
    expect(schedule.weekdays, [1, 3, 5]);
    expect(schedule.times, ['08:00', '20:00']);
    expect(schedule.id, isNotEmpty);
  });

  test('คืนค่า failure เมื่อ repository บันทึกไม่สำเร็จ', () async {
    when(
      () => repository.createSchedule(any()),
    ).thenAnswer((_) async => const Result.failure('บันทึกไม่สำเร็จ'));

    final result = await useCase.call(
      medicationId: 'med-1',
      frequency: ScheduleFrequency.daily,
      times: const ['08:00'],
      startDate: DateTime(2026, 1, 1),
    );

    expect(result.isFailure, isTrue);
  });
}
