import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/features/history/data/datasources/medication_history_local_data_source.dart';
import 'package:pillmate/features/history/data/models/medication_history_model.dart';
import 'package:pillmate/features/history/data/repositories/medication_history_repository_impl.dart';
import 'package:pillmate/features/history/domain/entities/medication_history.dart';

class MockMedicationHistoryLocalDataSource extends Mock
    implements MedicationHistoryLocalDataSource {}

class _FakeMedicationHistoryModel extends Fake
    implements MedicationHistoryModel {}

void main() {
  late MockMedicationHistoryLocalDataSource dataSource;
  late MedicationHistoryRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_FakeMedicationHistoryModel());
  });

  setUp(() {
    dataSource = MockMedicationHistoryLocalDataSource();
    repository = MedicationHistoryRepositoryImpl(dataSource: dataSource);
  });

  test('getHistory คืนค่า Success พร้อม entity list เมื่อ data source สำเร็จ', () async {
    final model = MedicationHistoryModel(
      id: '1',
      medicationId: 'med-1',
      medicationName: 'พาราเซตามอล',
      scheduledAt: DateTime(2026, 1, 1, 8),
      recordedAt: DateTime(2026, 1, 1, 8, 5),
      status: IntakeStatus.taken.name,
    );
    when(() => dataSource.getAll()).thenAnswer((_) async => [model]);

    final result = await repository.getHistory();

    expect(result.isSuccess, isTrue);
    result.when(
      success: (data) {
        expect(data.length, 1);
        expect(data.first.status, IntakeStatus.taken);
      },
      failure: (_) => fail('should not fail'),
    );
  });

  test('getHistory คืนค่า Failure เมื่อ data source โยน exception', () async {
    when(() => dataSource.getAll()).thenThrow(Exception('db error'));

    final result = await repository.getHistory();

    expect(result.isFailure, isTrue);
  });

  test('recordIntake ส่ง model ที่แปลงแล้วให้ data source บันทึก', () async {
    when(() => dataSource.create(any())).thenAnswer((_) async {});

    final history = MedicationHistory(
      id: '1',
      medicationId: 'med-1',
      medicationName: 'พาราเซตามอล',
      scheduledAt: DateTime(2026, 1, 1, 8),
      recordedAt: DateTime(2026, 1, 1, 8, 5),
      status: IntakeStatus.skipped,
    );

    final result = await repository.recordIntake(history);

    expect(result.isSuccess, isTrue);
    final captured = verify(() => dataSource.create(captureAny())).captured;
    final savedModel = captured.single as MedicationHistoryModel;
    expect(savedModel.id, '1');
    expect(savedModel.status, 'skipped');
  });
}
