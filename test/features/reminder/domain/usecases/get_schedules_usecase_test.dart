import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';
import 'package:pillmate/features/reminder/domain/repositories/schedule_repository.dart';
import 'package:pillmate/features/reminder/domain/usecases/get_schedules_usecase.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  late MockScheduleRepository repository;
  late GetSchedulesUseCase useCase;

  setUp(() {
    repository = MockScheduleRepository();
    useCase = GetSchedulesUseCase(repository: repository);
  });

  test('คืนค่ารายการตารางยาทั้งหมดเมื่อ repository สำเร็จ', () async {
    final schedules = [
      Schedule(
        id: '1',
        medicationId: 'med-1',
        frequency: ScheduleFrequency.daily,
        times: const ['08:00'],
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];
    when(
      () => repository.getSchedules(),
    ).thenAnswer((_) async => Result.success(schedules));

    final result = await useCase.call();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (data) => expect(data, schedules),
      failure: (_) => fail('should not fail'),
    );
    verify(() => repository.getSchedules()).called(1);
  });

  test('คืนค่า failure เมื่อ repository ล้มเหลว', () async {
    when(
      () => repository.getSchedules(),
    ).thenAnswer((_) async => const Result.failure('โหลดข้อมูลไม่สำเร็จ'));

    final result = await useCase.call();

    expect(result.isFailure, isTrue);
  });
}
