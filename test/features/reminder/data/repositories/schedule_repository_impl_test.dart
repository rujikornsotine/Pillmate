import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pillmate/core/exceptions/app_exception.dart';
import 'package:pillmate/features/reminder/data/datasources/schedule_local_data_source.dart';
import 'package:pillmate/features/reminder/data/models/schedule_model.dart';
import 'package:pillmate/features/reminder/data/repositories/schedule_repository_impl.dart';
import 'package:pillmate/features/reminder/domain/entities/schedule.dart';

class MockScheduleLocalDataSource extends Mock
    implements ScheduleLocalDataSource {}

class _FakeScheduleModel extends Fake implements ScheduleModel {}

void main() {
  late MockScheduleLocalDataSource dataSource;
  late ScheduleRepositoryImpl repository;
  late ScheduleModel model;

  setUpAll(() {
    registerFallbackValue(_FakeScheduleModel());
  });

  setUp(() {
    dataSource = MockScheduleLocalDataSource();
    repository = ScheduleRepositoryImpl(dataSource: dataSource);
    model = ScheduleModel(
      id: '1',
      medicationId: 'med-1',
      frequency: ScheduleFrequency.daily.name,
      weekdays: const [],
      times: const ['08:00'],
      startDate: DateTime(2026, 1, 1),
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  });

  group('getSchedules', () {
    test('คืนค่า Success พร้อม entity list เมื่อ data source สำเร็จ', () async {
      when(() => dataSource.getAll()).thenAnswer((_) async => [model]);

      final result = await repository.getSchedules();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (data) {
          expect(data.length, 1);
          expect(data.first.frequency, ScheduleFrequency.daily);
        },
        failure: (_) => fail('should not fail'),
      );
    });

    test('คืนค่า Failure เมื่อ data source โยน AppException', () async {
      when(
        () => dataSource.getAll(),
      ).thenThrow(const AppException('เกิดข้อผิดพลาด'));

      final result = await repository.getSchedules();

      expect(result.isFailure, isTrue);
    });
  });

  group('deleteSchedule', () {
    test('คืนค่า Success เมื่อลบสำเร็จ', () async {
      when(() => dataSource.delete('1')).thenAnswer((_) async {});

      final result = await repository.deleteSchedule('1');

      expect(result.isSuccess, isTrue);
      verify(() => dataSource.delete('1')).called(1);
    });

    test('คืนค่า Failure เมื่อไม่พบข้อมูลที่จะลบ', () async {
      when(
        () => dataSource.delete('1'),
      ).thenThrow(const AppException('ไม่พบตารางยาที่ต้องการลบ'));

      final result = await repository.deleteSchedule('1');

      expect(result.isFailure, isTrue);
    });
  });

  group('deleteSchedulesByMedicationId', () {
    test('เรียก data source เพื่อลบตารางยาทั้งหมดของยารายการนั้น', () async {
      when(
        () => dataSource.deleteByMedicationId('med-1'),
      ).thenAnswer((_) async {});

      final result = await repository.deleteSchedulesByMedicationId('med-1');

      expect(result.isSuccess, isTrue);
      verify(() => dataSource.deleteByMedicationId('med-1')).called(1);
    });
  });
}
