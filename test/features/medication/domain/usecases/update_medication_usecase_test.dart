import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';
import 'package:pillmate/features/medication/domain/repositories/medication_repository.dart';
import 'package:pillmate/features/medication/domain/usecases/update_medication_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

class _FakeMedication extends Fake implements Medication {}

void main() {
  late MockMedicationRepository repository;
  late UpdateMedicationUseCase useCase;
  late Medication existing;

  setUpAll(() {
    registerFallbackValue(_FakeMedication());
  });

  setUp(() {
    repository = MockMedicationRepository();
    useCase = UpdateMedicationUseCase(repository: repository);
    existing = Medication(
      id: '1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      imagePath: '/app/medication_images/old.jpg',
      note: 'ทานหลังอาหาร',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  test('แก้ไขข้อมูลยาโดยคง id และ createdAt เดิม', () async {
    when(
      () => repository.updateMedication(any()),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call(
      existing: existing,
      name: 'พาราเซตามอล 650',
      dosage: '650 mg',
      quantity: '2 เม็ด',
    );

    expect(result.isSuccess, isTrue);
    final captured =
        verify(() => repository.updateMedication(captureAny())).captured;
    final medication = captured.single as Medication;
    expect(medication.id, existing.id);
    expect(medication.createdAt, existing.createdAt);
    expect(medication.name, 'พาราเซตามอล 650');
    expect(medication.dosage, '650 mg');
    expect(medication.quantity, '2 เม็ด');
    expect(medication.updatedAt.isAfter(existing.updatedAt), isTrue);
  });

  test('ล้างค่า note และ imagePath เป็น null ได้เมื่อผู้ใช้ไม่ระบุ', () async {
    when(
      () => repository.updateMedication(any()),
    ).thenAnswer((_) async => const Result.success(null));

    await useCase.call(
      existing: existing,
      name: existing.name,
      dosage: existing.dosage,
      quantity: existing.quantity,
      // ไม่ส่ง imagePath และ note เท่ากับตั้งใจล้างค่าทั้งสอง
    );

    final captured =
        verify(() => repository.updateMedication(captureAny())).captured;
    final medication = captured.single as Medication;
    expect(medication.imagePath, isNull);
    expect(medication.note, isNull);
  });

  test('คืนค่า failure เมื่อ repository แก้ไขไม่สำเร็จ', () async {
    when(
      () => repository.updateMedication(any()),
    ).thenAnswer((_) async => const Result.failure('แก้ไขไม่สำเร็จ'));

    final result = await useCase.call(
      existing: existing,
      name: 'พาราเซตามอล 650',
      dosage: '650 mg',
      quantity: '2 เม็ด',
    );

    expect(result.isFailure, isTrue);
  });
}
