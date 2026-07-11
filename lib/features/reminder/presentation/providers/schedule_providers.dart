import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/utils/result.dart';
import '../../data/datasources/schedule_local_data_source.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/usecases/create_schedule_usecase.dart';
import '../../domain/usecases/delete_schedule_usecase.dart';
import '../../domain/usecases/delete_schedules_for_medication_usecase.dart';
import '../../domain/usecases/get_schedules_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import 'reminder_providers.dart';

/// Hive Box ของตารางยา ต้องถูก override ด้วย Box ที่เปิดไว้แล้วตอน main.dart ก่อนเรียกใช้งาน
final scheduleBoxProvider = Provider<Box<ScheduleModel>>((ref) {
  throw UnimplementedError(
    'scheduleBoxProvider ต้องถูก override ด้วย Box ที่เปิดแล้วใน main.dart',
  );
});

final scheduleLocalDataSourceProvider = Provider<ScheduleLocalDataSource>((
  ref,
) {
  return ScheduleLocalDataSource(box: ref.watch(scheduleBoxProvider));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepositoryImpl(
    dataSource: ref.watch(scheduleLocalDataSourceProvider),
  );
});

final getSchedulesUseCaseProvider = Provider<GetSchedulesUseCase>((ref) {
  return GetSchedulesUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final createScheduleUseCaseProvider = Provider<CreateScheduleUseCase>((ref) {
  return CreateScheduleUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final updateScheduleUseCaseProvider = Provider<UpdateScheduleUseCase>((ref) {
  return UpdateScheduleUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final deleteScheduleUseCaseProvider = Provider<DeleteScheduleUseCase>((ref) {
  return DeleteScheduleUseCase(
    repository: ref.watch(scheduleRepositoryProvider),
  );
});

final deleteSchedulesForMedicationUseCaseProvider =
    Provider<DeleteSchedulesForMedicationUseCase>((ref) {
      return DeleteSchedulesForMedicationUseCase(
        repository: ref.watch(scheduleRepositoryProvider),
      );
    });

/// State ของตารางยาทั้งหมด (ทุกยารวมกัน) รองรับการเพิ่ม/แก้ไข/ลบ พร้อม refresh อัตโนมัติ
/// หน้าจอที่ต้องการตารางของยารายการเดียวให้ filter ด้วย medicationId เอง
class ScheduleListNotifier extends AsyncNotifier<List<Schedule>> {
  @override
  Future<List<Schedule>> build() {
    return _fetch();
  }

  Future<List<Schedule>> _fetch() async {
    final result = await ref.read(getSchedulesUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (message) => throw StateError(message),
    );
  }

  /// โหลดตารางยาใหม่ทั้งหมด
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// เพิ่มตารางยาใหม่ คืนค่า Result เพื่อให้หน้าจอแสดงข้อความ error ได้ตรงจุด
  Future<Result<void>> addSchedule({
    required String medicationId,
    required ScheduleFrequency frequency,
    List<int> weekdays = const [],
    List<String> times = const [],
    int? intervalHours,
    String? startTime,
    int? intervalDays,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final result = await ref
        .read(createScheduleUseCaseProvider)
        .call(
          medicationId: medicationId,
          frequency: frequency,
          weekdays: weekdays,
          times: times,
          intervalHours: intervalHours,
          startTime: startTime,
          intervalDays: intervalDays,
          startDate: startDate,
          endDate: endDate,
        );
    if (result.isSuccess) {
      await refresh();
      unawaited(ref.read(syncRemindersUseCaseProvider).call());
    }
    return result;
  }

  /// แก้ไขตารางยาที่มีอยู่แล้ว คืนค่า Result เพื่อให้หน้าจอแสดงข้อความ error ได้ตรงจุด
  Future<Result<void>> editSchedule({
    required Schedule existing,
    required ScheduleFrequency frequency,
    List<int> weekdays = const [],
    List<String> times = const [],
    int? intervalHours,
    String? startTime,
    int? intervalDays,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final result = await ref
        .read(updateScheduleUseCaseProvider)
        .call(
          existing: existing,
          frequency: frequency,
          weekdays: weekdays,
          times: times,
          intervalHours: intervalHours,
          startTime: startTime,
          intervalDays: intervalDays,
          startDate: startDate,
          endDate: endDate,
        );
    if (result.isSuccess) {
      await refresh();
      unawaited(ref.read(syncRemindersUseCaseProvider).call());
    }
    return result;
  }

  /// ลบตารางยา คืนค่า Result เพื่อให้หน้าจอแสดงข้อความ error ได้ตรงจุด
  Future<Result<void>> removeSchedule(String id) async {
    final result = await ref.read(deleteScheduleUseCaseProvider).call(id);
    if (result.isSuccess) {
      await refresh();
      unawaited(ref.read(syncRemindersUseCaseProvider).call());
    }
    return result;
  }
}

final scheduleListProvider =
    AsyncNotifierProvider<ScheduleListNotifier, List<Schedule>>(
      ScheduleListNotifier.new,
    );
