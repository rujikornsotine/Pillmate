import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_data_source.dart';
import '../mappers/schedule_mapper.dart';

/// Implementation ของ ScheduleRepository ที่ใช้ Hive ผ่าน ScheduleLocalDataSource
class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({required ScheduleLocalDataSource dataSource})
    : _dataSource = dataSource;

  final ScheduleLocalDataSource _dataSource;

  @override
  Future<Result<List<Schedule>>> getSchedules() async {
    try {
      final models = await _dataSource.getAll();
      return Result.success(models.map(ScheduleMapper.toEntity).toList());
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถโหลดข้อมูลตารางยาได้: $e');
    }
  }

  @override
  Future<Result<void>> createSchedule(Schedule schedule) async {
    try {
      await _dataSource.create(ScheduleMapper.toModel(schedule));
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถเพิ่มตารางยาได้: $e');
    }
  }

  @override
  Future<Result<void>> updateSchedule(Schedule schedule) async {
    try {
      await _dataSource.update(ScheduleMapper.toModel(schedule));
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถแก้ไขตารางยาได้: $e');
    }
  }

  @override
  Future<Result<void>> deleteSchedule(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถลบตารางยาได้: $e');
    }
  }

  @override
  Future<Result<void>> deleteSchedulesByMedicationId(
    String medicationId,
  ) async {
    try {
      await _dataSource.deleteByMedicationId(medicationId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('ไม่สามารถลบตารางยาได้: $e');
    }
  }
}
