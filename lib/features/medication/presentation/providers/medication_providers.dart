import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/services/image_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/medication_local_data_source.dart';
import '../../data/models/medication_model.dart';
import '../../data/repositories/medication_repository_impl.dart';
import '../../domain/entities/medication.dart';
import '../../domain/repositories/medication_repository.dart';
import '../../domain/usecases/create_medication_usecase.dart';
import '../../domain/usecases/delete_medication_usecase.dart';
import '../../domain/usecases/get_medications_usecase.dart';
import '../../domain/usecases/update_medication_usecase.dart';
import '../../../reminder/presentation/providers/reminder_providers.dart';
import '../../../reminder/presentation/providers/schedule_providers.dart';

/// Hive Box ของยา ต้องถูก override ด้วย Box ที่เปิดไว้แล้วตอน main.dart ก่อนเรียกใช้งาน
final medicationBoxProvider = Provider<Box<MedicationModel>>((ref) {
  throw UnimplementedError(
    'medicationBoxProvider ต้องถูก override ด้วย Box ที่เปิดแล้วใน main.dart',
  );
});

final medicationLocalDataSourceProvider = Provider<MedicationLocalDataSource>((
  ref,
) {
  return MedicationLocalDataSource(box: ref.watch(medicationBoxProvider));
});

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepositoryImpl(
    dataSource: ref.watch(medicationLocalDataSourceProvider),
  );
});

final getMedicationsUseCaseProvider = Provider<GetMedicationsUseCase>((ref) {
  return GetMedicationsUseCase(
    repository: ref.watch(medicationRepositoryProvider),
  );
});

final createMedicationUseCaseProvider = Provider<CreateMedicationUseCase>((
  ref,
) {
  return CreateMedicationUseCase(
    repository: ref.watch(medicationRepositoryProvider),
  );
});

final updateMedicationUseCaseProvider = Provider<UpdateMedicationUseCase>((
  ref,
) {
  return UpdateMedicationUseCase(
    repository: ref.watch(medicationRepositoryProvider),
  );
});

final deleteMedicationUseCaseProvider = Provider<DeleteMedicationUseCase>((
  ref,
) {
  return DeleteMedicationUseCase(
    repository: ref.watch(medicationRepositoryProvider),
  );
});

/// State ของรายการยาทั้งหมด รองรับการเพิ่ม/แก้ไข/ลบ พร้อม refresh อัตโนมัติ
class MedicationListNotifier extends AsyncNotifier<List<Medication>> {
  @override
  Future<List<Medication>> build() {
    return _fetch();
  }

  Future<List<Medication>> _fetch() async {
    final result = await ref.read(getMedicationsUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (message) => throw StateError(message),
    );
  }

  /// โหลดรายการยาใหม่ทั้งหมด
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// เพิ่มข้อมูลยาใหม่ คืนค่า Result เพื่อให้หน้าจอแสดงข้อความ error ได้ตรงจุด
  Future<Result<void>> addMedication({
    required String name,
    required String dosage,
    required String quantity,
    String? imagePath,
    String? note,
  }) async {
    final persistedImagePath = imagePath == null
        ? null
        : await ref.read(imageStorageServiceProvider).persist(imagePath);

    final result = await ref
        .read(createMedicationUseCaseProvider)
        .call(
          name: name,
          dosage: dosage,
          quantity: quantity,
          imagePath: persistedImagePath,
          note: note,
        );
    if (result.isSuccess) {
      await refresh();
    }
    return result;
  }

  /// แก้ไขข้อมูลยาที่มีอยู่แล้ว คืนค่า Result เพื่อให้หน้าจอแสดงข้อความ error ได้ตรงจุด
  Future<Result<void>> editMedication({
    required Medication existing,
    required String name,
    required String dosage,
    required String quantity,
    String? imagePath,
    String? note,
  }) async {
    final imageService = ref.read(imageStorageServiceProvider);
    final persistedImagePath = imagePath == null
        ? null
        : await imageService.persist(imagePath);

    final result = await ref
        .read(updateMedicationUseCaseProvider)
        .call(
          existing: existing,
          name: name,
          dosage: dosage,
          quantity: quantity,
          imagePath: persistedImagePath,
          note: note,
        );
    if (result.isSuccess) {
      // ลบรูปเก่าทิ้งถ้าถูกเปลี่ยนหรือถูกลบออก
      if (existing.imagePath != null &&
          existing.imagePath != persistedImagePath) {
        await imageService.delete(existing.imagePath);
      }
      await refresh();
      // ชื่อ/ขนาดยาอาจเปลี่ยน ต้องตั้งเวลาแจ้งเตือนใหม่เพื่อให้เนื้อหาไม่ล้าสมัย
      unawaited(ref.read(syncRemindersUseCaseProvider).call());
    }
    return result;
  }

  /// ลบข้อมูลยา คืนค่า Result เพื่อให้หน้าจอแสดงข้อความ error ได้ตรงจุด
  Future<Result<void>> removeMedication(String id) async {
    Medication? target;
    for (final medication in state.value ?? const <Medication>[]) {
      if (medication.id == id) {
        target = medication;
        break;
      }
    }

    final result = await ref.read(deleteMedicationUseCaseProvider).call(id);
    if (result.isSuccess) {
      if (target?.imagePath != null) {
        await ref.read(imageStorageServiceProvider).delete(target!.imagePath);
      }
      // ลบตารางยาที่ผูกกับยานี้ทั้งหมด ไม่ให้เหลือตารางกำพร้า
      await ref.read(deleteSchedulesForMedicationUseCaseProvider).call(id);
      await refresh();
      unawaited(ref.read(syncRemindersUseCaseProvider).call());
    }
    return result;
  }
}

final medicationListProvider =
    AsyncNotifierProvider<MedicationListNotifier, List<Medication>>(
      MedicationListNotifier.new,
    );
