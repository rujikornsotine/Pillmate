import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/reminder/domain/repositories/schedule_repository.dart';
import 'package:pillmate/features/reminder/domain/usecases/delete_schedule_usecase.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

void main() {
  late MockScheduleRepository repository;
  late DeleteScheduleUseCase useCase;

  setUp(() {
    repository = MockScheduleRepository();
    useCase = DeleteScheduleUseCase(repository: repository);
  });

  test('ลบตารางยาตาม id ที่ระบุ', () async {
    when(
      () => repository.deleteSchedule('1'),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call('1');

    expect(result.isSuccess, isTrue);
    verify(() => repository.deleteSchedule('1')).called(1);
  });

  test('คืนค่า failure เมื่อ repository ลบไม่สำเร็จ', () async {
    when(
      () => repository.deleteSchedule('1'),
    ).thenAnswer((_) async => const Result.failure('ลบไม่สำเร็จ'));

    final result = await useCase.call('1');

    expect(result.isFailure, isTrue);
  });
}
