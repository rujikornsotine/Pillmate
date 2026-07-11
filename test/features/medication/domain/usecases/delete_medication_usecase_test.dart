import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/utils/result.dart';
import 'package:pillmate/features/medication/domain/repositories/medication_repository.dart';
import 'package:pillmate/features/medication/domain/usecases/delete_medication_usecase.dart';

class MockMedicationRepository extends Mock implements MedicationRepository {}

void main() {
  late MockMedicationRepository repository;
  late DeleteMedicationUseCase useCase;

  setUp(() {
    repository = MockMedicationRepository();
    useCase = DeleteMedicationUseCase(repository: repository);
  });

  test('ลบข้อมูลยาตาม id ที่ระบุ', () async {
    when(
      () => repository.deleteMedication('1'),
    ).thenAnswer((_) async => const Result.success(null));

    final result = await useCase.call('1');

    expect(result.isSuccess, isTrue);
    verify(() => repository.deleteMedication('1')).called(1);
  });

  test('คืนค่า failure เมื่อ repository ลบไม่สำเร็จ', () async {
    when(
      () => repository.deleteMedication('1'),
    ).thenAnswer((_) async => const Result.failure('ลบไม่สำเร็จ'));

    final result = await useCase.call('1');

    expect(result.isFailure, isTrue);
  });
}
