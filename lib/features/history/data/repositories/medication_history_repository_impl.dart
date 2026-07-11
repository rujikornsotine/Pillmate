import '../../../../core/utils/result.dart';
import '../../domain/entities/medication_history.dart';
import '../../domain/repositories/medication_history_repository.dart';
import '../datasources/medication_history_local_data_source.dart';
import '../mappers/medication_history_mapper.dart';

/// Implementation ของ MedicationHistoryRepository ที่ใช้ Hive ผ่าน MedicationHistoryLocalDataSource
class MedicationHistoryRepositoryImpl implements MedicationHistoryRepository {
  MedicationHistoryRepositoryImpl({
    required MedicationHistoryLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final MedicationHistoryLocalDataSource _dataSource;

  @override
  Future<Result<List<MedicationHistory>>> getHistory() async {
    try {
      final models = await _dataSource.getAll();
      return Result.success(
        models.map(MedicationHistoryMapper.toEntity).toList(),
      );
    } catch (e) {
      return Result.failure('ไม่สามารถโหลดประวัติการทานยาได้: $e');
    }
  }

  @override
  Future<Result<void>> recordIntake(MedicationHistory history) async {
    try {
      await _dataSource.create(MedicationHistoryMapper.toModel(history));
      return const Result.success(null);
    } catch (e) {
      return Result.failure('ไม่สามารถบันทึกประวัติการทานยาได้: $e');
    }
  }
}
