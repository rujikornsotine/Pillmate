import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/history/domain/entities/medication_history.dart';
import 'package:pillmate/features/history/domain/repositories/medication_history_repository.dart';
import 'package:pillmate/features/history/domain/usecases/record_medication_intake_usecase.dart';

class MockMedicationHistoryRepository extends Mock
    implements MedicationHistoryRepository {}

class _FakeMedicationHistory extends Fake implements MedicationHistory {}

void main() {
  late MockMedicationHistoryRepository repository;
  late RecordMedicationIntakeUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_FakeMedicationHistory());
  });

  setUp(() {
    repository = MockMedicationHistoryRepository();
    useCase = RecordMedicationIntakeUseCase(repository: repository);
  });

  test('สร้างประวัติพร้อม id และ recordedAt แล้วส่งให้ repository บันทึก', () async {
    when(
      () => repository.recordIntake(any()),
    ).thenAnswer((_) async => const Result.success(null));

    final scheduledAt = DateTime(2026, 1, 1, 8);
    final result = await useCase.call(
      medicationId: 'med-1',
      medicationName: 'พาราเซตามอล',
      scheduledAt: scheduledAt,
      status: IntakeStatus.taken,
    );

    expect(result.isSuccess, isTrue);
    final captured =
        verify(() => repository.recordIntake(captureAny())).captured;
    final history = captured.single as MedicationHistory;
    expect(history.medicationId, 'med-1');
    expect(history.medicationName, 'พาราเซตามอล');
    expect(history.scheduledAt, scheduledAt);
    expect(history.status, IntakeStatus.taken);
    expect(history.id, isNotEmpty);
  });

  test('คืนค่า failure เมื่อ repository บันทึกไม่สำเร็จ', () async {
    when(
      () => repository.recordIntake(any()),
    ).thenAnswer((_) async => const Result.failure('บันทึกไม่สำเร็จ'));

    final result = await useCase.call(
      medicationId: 'med-1',
      medicationName: 'พาราเซตามอล',
      scheduledAt: DateTime(2026, 1, 1, 8),
      status: IntakeStatus.snoozed,
    );

    expect(result.isFailure, isTrue);
  });
}
