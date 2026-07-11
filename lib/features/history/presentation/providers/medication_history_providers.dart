import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/datasources/medication_history_local_data_source.dart';
import '../../data/models/medication_history_model.dart';
import '../../data/repositories/medication_history_repository_impl.dart';
import '../../domain/entities/medication_history.dart';
import '../../domain/repositories/medication_history_repository.dart';
import '../../domain/usecases/get_medication_history_usecase.dart';
import '../../domain/usecases/record_medication_intake_usecase.dart';

/// Hive Box ของประวัติการทานยา ต้องถูก override ด้วย Box ที่เปิดไว้แล้วตอน main.dart
final medicationHistoryBoxProvider = Provider<Box<MedicationHistoryModel>>((
  ref,
) {
  throw UnimplementedError(
    'medicationHistoryBoxProvider ต้องถูก override ด้วย Box ที่เปิดแล้วใน main.dart',
  );
});

final medicationHistoryLocalDataSourceProvider =
    Provider<MedicationHistoryLocalDataSource>((ref) {
      return MedicationHistoryLocalDataSource(
        box: ref.watch(medicationHistoryBoxProvider),
      );
    });

final medicationHistoryRepositoryProvider =
    Provider<MedicationHistoryRepository>((ref) {
      return MedicationHistoryRepositoryImpl(
        dataSource: ref.watch(medicationHistoryLocalDataSourceProvider),
      );
    });

final getMedicationHistoryUseCaseProvider =
    Provider<GetMedicationHistoryUseCase>((ref) {
      return GetMedicationHistoryUseCase(
        repository: ref.watch(medicationHistoryRepositoryProvider),
      );
    });

final recordMedicationIntakeUseCaseProvider =
    Provider<RecordMedicationIntakeUseCase>((ref) {
      return RecordMedicationIntakeUseCase(
        repository: ref.watch(medicationHistoryRepositoryProvider),
      );
    });

/// State ของประวัติการทานยาทั้งหมด (อ่านอย่างเดียว/append-only ไม่มีการแก้ไขย้อนหลัง)
class MedicationHistoryListNotifier
    extends AsyncNotifier<List<MedicationHistory>> {
  @override
  Future<List<MedicationHistory>> build() {
    return _fetch();
  }

  Future<List<MedicationHistory>> _fetch() async {
    final result = await ref.read(getMedicationHistoryUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (message) => throw StateError(message),
    );
  }

  /// โหลดประวัติการทานยาใหม่ทั้งหมด
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final medicationHistoryListProvider =
    AsyncNotifierProvider<MedicationHistoryListNotifier, List<MedicationHistory>>(
      MedicationHistoryListNotifier.new,
    );
