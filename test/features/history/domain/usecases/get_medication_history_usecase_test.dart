import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/history/domain/entities/medication_history.dart';
import 'package:pillmate/features/history/domain/repositories/medication_history_repository.dart';
import 'package:pillmate/features/history/domain/usecases/get_medication_history_usecase.dart';

class MockMedicationHistoryRepository extends Mock
    implements MedicationHistoryRepository {}

void main() {
  late MockMedicationHistoryRepository repository;
  late GetMedicationHistoryUseCase useCase;

  setUp(() {
    repository = MockMedicationHistoryRepository();
    useCase = GetMedicationHistoryUseCase(repository: repository);
  });

  test('คืนค่าประวัติการทานยาทั้งหมดเมื่อ repository สำเร็จ', () async {
    final history = [
      MedicationHistory(
        id: '1',
        medicationId: 'med-1',
        medicationName: 'พาราเซตามอล',
        scheduledAt: DateTime(2026, 1, 1, 8),
        recordedAt: DateTime(2026, 1, 1, 8, 5),
        status: IntakeStatus.taken,
      ),
    ];
    when(
      () => repository.getHistory(),
    ).thenAnswer((_) async => Result.success(history));

    final result = await useCase.call();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (data) => expect(data, history),
      failure: (_) => fail('should not fail'),
    );
  });

  test('คืนค่า failure เมื่อ repository ล้มเหลว', () async {
    when(
      () => repository.getHistory(),
    ).thenAnswer((_) async => const Result.failure('โหลดไม่สำเร็จ'));

    final result = await useCase.call();

    expect(result.isFailure, isTrue);
  });
}
