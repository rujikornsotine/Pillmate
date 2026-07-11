import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';
import 'package:pillmate/features/medication/domain/repositories/medication_repository.dart';
import 'package:pillmate/features/medication/domain/usecases/get_medications_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository repository;
  late GetMedicationsUseCase useCase;

  setUp(() {
    repository = MockMedicationRepository();
    useCase = GetMedicationsUseCase(repository: repository);
  });

  test('คืนค่ารายการยาทั้งหมดเมื่อ repository สำเร็จ', () async {
    final medications = [
      Medication(
        id: '1',
        name: 'พาราเซตามอล',
        dosage: '500 mg',
        quantity: '1 เม็ด',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];
    when(
      () => repository.getMedications(),
    ).thenAnswer((_) async => Result.success(medications));

    final result = await useCase.call();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (data) => expect(data, medications),
      failure: (_) => fail('should not fail'),
    );
    verify(() => repository.getMedications()).called(1);
  });

  test('คืนค่า failure เมื่อ repository ล้มเหลว', () async {
    when(
      () => repository.getMedications(),
    ).thenAnswer((_) async => const Result.failure('โหลดข้อมูลไม่สำเร็จ'));

    final result = await useCase.call();

    expect(result.isFailure, isTrue);
  });
}
