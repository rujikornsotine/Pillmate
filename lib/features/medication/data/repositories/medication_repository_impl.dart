import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_local_data_source.dart';
import '../mappers/medication_mapper.dart';

/// Implementation ของ MedicationRepository ที่ใช้ Hive ผ่าน MedicationLocalDataSource
class MedicationRepositoryImpl implements MedicationRepository {
  MedicationRepositoryImpl({required MedicationLocalDataSource dataSource})
    : _dataSource = dataSource;

  final MedicationLocalDataSource _dataSource;

  @override
  Future<Result<List<Medication>>> getMedications() async {
    try {
      final models = await _dataSource.getAll();
      return Result.success(models.map(MedicationMapper.toEntity).toList());
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถโหลดข้อมูลยาได้: $e');
    }
  }

  @override
  Future<Result<Medication>> getMedicationById(String id) async {
    try {
      final model = await _dataSource.getById(id);
      return Result.success(MedicationMapper.toEntity(model));
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถโหลดข้อมูลยาได้: $e');
    }
  }

  @override
  Future<Result<void>> createMedication(Medication medication) async {
    try {
      await _dataSource.create(MedicationMapper.toModel(medication));
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถเพิ่มข้อมูลยาได้: $e');
    }
  }

  @override
  Future<Result<void>> updateMedication(Medication medication) async {
    try {
      await _dataSource.update(MedicationMapper.toModel(medication));
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถแก้ไขข้อมูลยาได้: $e');
    }
  }

  @override
  Future<Result<void>> deleteMedication(String id) async {
    try {
      await _dataSource.delete(id);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('ไม่สามารถลบข้อมูลยาได้: $e');
    }
  }
}
