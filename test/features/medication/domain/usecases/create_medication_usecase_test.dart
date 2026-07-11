import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';
import 'package:pillmate/features/medication/domain/repositories/medication_repository.dart';
import 'package:pillmate/features/medication/domain/usecases/create_medication_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

class _FakeMedication extends Fake implements Medication {}

void main() {
  late MockMedicationRepository repository;
  late CreateMedicationUseCase useCase;

  setUpAll(() {
    registerFallbackValue(_FakeMedication());
  });

  setUp(() {
    repository = MockMedicationRepository();
    useCase = CreateMedicationUseCase(repository: repository);
  });

  test('สร้าง Medication พร้อม id และเวลา แล้วส่งให้ repository บันทึก', () async {
    when(
      () => repository.createMedication(any()),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      note: 'ทานหลังอาหาร',
    );

    expect(result.isSuccess, isTrue);
    final captured =
        verify(() => repository.createMedication(captureAny())).captured;
    final medication = captured.single as Medication;
    expect(medication.name, 'พาราเซตามอล');
    expect(medication.dosage, '500 mg');
    expect(medication.quantity, '1 เม็ด');
    expect(medication.note, 'ทานหลังอาหาร');
    expect(medication.id, isNotEmpty);
  });

  test('คืนค่า failure เมื่อ repository บันทึกไม่สำเร็จ', () async {
    when(
      () => repository.createMedication(any()),
    ).thenAnswer((_) async => const Result.failure('บันทึกไม่สำเร็จ'));

    final result = await useCase.call(
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
    );

    expect(result.isFailure, isTrue);
  });
}
