import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart';
import '../../../history/domain/entities/medication_history.dart';
import '../../../history/presentation/providers/medication_history_providers.dart';
import '../../../medication/presentation/providers/medication_providers.dart';
import '../../../reminder/presentation/providers/reminder_providers.dart';
import '../../../reminder/presentation/providers/schedule_providers.dart';
import '../../domain/entities/medication_dose.dart';
import '../../domain/usecases/get_today_doses_usecase.dart';

final getTodayDosesUseCaseProvider = Provider<GetTodayDosesUseCase>((ref) {
  return GetTodayDosesUseCase(
    scheduleRepository: ref.watch(scheduleRepositoryProvider),
    medicationRepository: ref.watch(medicationRepositoryProvider),
    historyRepository: ref.watch(medicationHistoryRepositoryProvider),
  );
});

/// State ของมื้อยาที่ต้องทานวันนี้ พร้อมสถานะการทานจากประวัติ
class TodayDosesNotifier extends AsyncNotifier<List<MedicationDose>> {
  @override
  Future<List<MedicationDose>> build() {
    return _fetch();
  }

  Future<List<MedicationDose>> _fetch() async {
    final result = await ref.read(getTodayDosesUseCaseProvider).call();
    return result.when(
      success: (data) => data,
      failure: (message) => throw StateError(message),
    );
  }

  /// โหลดมื้อยาวันนี้ใหม่ทั้งหมด
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// ยืนยันว่าทานยามื้อนี้แล้ว: บันทึกประวัติ (สถานะทานแล้ว) และยกเลิกการแจ้งเตือน
  /// ของมื้อนั้น เพื่อไม่ให้เด้งแจ้งเตือนซ้ำ คืนค่า Result ให้หน้าจอแสดง error ได้
  Future<Result<void>> markDoseTaken(MedicationDose dose) async {
    final result = await ref
        .read(recordMedicationIntakeUseCaseProvider)
        .call(
          medicationId: dose.medication.id,
          medicationName: dose.medication.name,
          scheduledAt: dose.scheduledAt,
          status: IntakeStatus.taken,
        );

    if (result.isSuccess) {
      await ref
          .read(reminderRepositoryProvider)
          .cancelDoseReminder(
            medicationId: dose.medication.id,
            occurrence: dose.scheduledAt,
          );
      await refresh();
      ref.read(medicationHistoryListProvider.notifier).refresh();
    }
    return result;
  }
}

final todayDosesProvider =
    AsyncNotifierProvider<TodayDosesNotifier, List<MedicationDose>>(
      TodayDosesNotifier.new,
    );
