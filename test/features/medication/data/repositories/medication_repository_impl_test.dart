import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/exceptions/app_exception.dart';
import 'package:pillmate/features/medication/data/datasources/medication_local_data_source.dart';
import 'package:pillmate/features/medication/data/models/medication_model.dart';
import 'package:pillmate/features/medication/data/repositories/medication_repository_impl.dart';
import 'package:pillmate/features/medication/domain/entities/medication.dart';

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class _FakeMedicationModel extends Fake implements MedicationModel {}

void main() {
  late MockMedicationLocalDataSource dataSource;
  late MedicationRepositoryImpl repository;
  late MedicationModel model;
  late Medication entity;

  setUpAll(() {
    registerFallbackValue(_FakeMedicationModel());
  });

  setUp(() {
    dataSource = MockMedicationLocalDataSource();
    repository = MedicationRepositoryImpl(dataSource: dataSource);
    model = MedicationModel(
      id: '1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    entity = Medication(
      id: '1',
      name: 'พาราเซตามอล',
      dosage: '500 mg',
      quantity: '1 เม็ด',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  group('getMedications', () {
    test('คืนค่า Success พร้อม entity list เมื่อ data source สำเร็จ', () async {
      when(() => dataSource.getAll()).thenAnswer((_) async => [model]);

      final result = await repository.getMedications();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (data) {
          expect(data.length, 1);
          expect(data.first.id, entity.id);
        },
        failure: (_) => fail('should not fail'),
      );
    });

    test('คืนค่า Failure เมื่อ data source โยน AppException', () async {
      when(
        () => dataSource.getAll(),
      ).thenThrow(const AppException('เกิดข้อผิดพลาด'));

      final result = await repository.getMedications();

      expect(result.isFailure, isTrue);
    });
  });

  group('createMedication', () {
    test('ส่ง model ที่แปลงแล้วให้ data source บันทึก', () async {
      when(() => dataSource.create(any())).thenAnswer((_) async {});

      final result = await repository.createMedication(entity);

      expect(result.isSuccess, isTrue);
      final captured = verify(() => dataSource.create(captureAny())).captured;
      final savedModel = captured.single as MedicationModel;
      expect(savedModel.id, entity.id);
      expect(savedModel.name, entity.name);
    });

    test('คืนค่า Failure เมื่อ data source โยน exception ทั่วไป', () async {
      when(() => dataSource.create(any())).thenThrow(Exception('db error'));

      final result = await repository.createMedication(entity);

      expect(result.isFailure, isTrue);
    });
  });

  group('deleteMedication', () {
    test('คืนค่า Success เมื่อลบสำเร็จ', () async {
      when(() => dataSource.delete('1')).thenAnswer((_) async {});

      final result = await repository.deleteMedication('1');

      expect(result.isSuccess, isTrue);
      verify(() => dataSource.delete('1')).called(1);
    });

    test('คืนค่า Failure เมื่อไม่พบข้อมูลที่จะลบ', () async {
      when(
        () => dataSource.delete('1'),
      ).thenThrow(const AppException('ไม่พบข้อมูลยาที่ต้องการลบ'));

      final result = await repository.deleteMedication('1');

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('should not succeed'),
        failure: (message) => expect(message, 'ไม่พบข้อมูลยาที่ต้องการลบ'),
      );
    });
  });
}
