import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../history/presentation/providers/medication_history_providers.dart';
import '../../../medication/presentation/providers/medication_providers.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/entities/reminder_permission_status.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/get_reminder_permission_status_usecase.dart';
import '../../domain/usecases/request_exact_alarm_permission_usecase.dart';
import '../../domain/usecases/request_notification_permission_usecase.dart';
import '../../domain/usecases/sync_reminders_usecase.dart';
import 'schedule_providers.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final requestNotificationPermissionUseCaseProvider =
    Provider<RequestNotificationPermissionUseCase>((ref) {
      return RequestNotificationPermissionUseCase(
        repository: ref.watch(reminderRepositoryProvider),
      );
    });

final requestExactAlarmPermissionUseCaseProvider =
    Provider<RequestExactAlarmPermissionUseCase>((ref) {
      return RequestExactAlarmPermissionUseCase(
        repository: ref.watch(reminderRepositoryProvider),
      );
    });

final getReminderPermissionStatusUseCaseProvider =
    Provider<GetReminderPermissionStatusUseCase>((ref) {
      return GetReminderPermissionStatusUseCase(
        repository: ref.watch(reminderRepositoryProvider),
      );
    });

/// คำนวณและตั้งเวลาแจ้งเตือนใหม่ทั้งหมด ต้องเรียกทุกครั้งที่แอปเปิดขึ้นมา
/// และทุกครั้งที่มีการแก้ไขข้อมูลยาหรือตารางยา
final syncRemindersUseCaseProvider = Provider<SyncRemindersUseCase>((ref) {
  return SyncRemindersUseCase(
    reminderRepository: ref.watch(reminderRepositoryProvider),
    scheduleRepository: ref.watch(scheduleRepositoryProvider),
    medicationRepository: ref.watch(medicationRepositoryProvider),
    historyRepository: ref.watch(medicationHistoryRepositoryProvider),
  );
});

/// State ของสิทธิ์การแจ้งเตือน ใช้ตัดสินใจว่าจะแสดงแถบเตือนให้ผู้ใช้เปิดสิทธิ์หรือไม่
///
/// ต้อง [refresh] ทุกครั้งที่แอปกลับมาทำงาน เพราะผู้ใช้เปลี่ยนสิทธิ์จากหน้าตั้งค่า
/// ของระบบได้ตลอดโดยที่แอปไม่รู้ตัว
class ReminderPermissionNotifier extends AsyncNotifier<ReminderPermissionStatus> {
  @override
  Future<ReminderPermissionStatus> build() {
    return _fetch();
  }

  Future<ReminderPermissionStatus> _fetch() async {
    final result = await ref
        .read(getReminderPermissionStatusUseCaseProvider)
        .call();
    return result.when(
      success: (status) => status,
      failure: (message) => throw StateError(message),
    );
  }

  /// อ่านสถานะสิทธิ์ใหม่ โดยไม่แสดงสถานะกำลังโหลด เพื่อไม่ให้แถบเตือนกะพริบ
  Future<void> refresh() async {
    state = await AsyncValue.guard(_fetch);
  }

  /// ขอสิทธิ์ที่ยังขาดอยู่ทั้งหมด แล้วตั้งเวลาแจ้งเตือนใหม่ถ้าได้รับสิทธิ์เพิ่ม
  ///
  /// ต้องเรียกหลังจากผู้ใช้เห็นคำอธิบายและกดยืนยันแล้วเท่านั้น
  Future<void> requestMissingPermissions() async {
    final current = state.value;

    if (current == null || !current.notificationsEnabled) {
      await ref.read(requestNotificationPermissionUseCaseProvider).call();
    }
    if (current == null || !current.exactAlarmsAllowed) {
      await ref.read(requestExactAlarmPermissionUseCaseProvider).call();
    }

    await refresh();
    // ตั้งเวลาแจ้งเตือนใหม่เสมอ เพราะรอบก่อนหน้าอาจตั้งไม่สำเร็จหรือตั้งเป็นแบบ
    // ไม่ตรงเวลาไว้ตอนที่ยังไม่ได้รับสิทธิ์
    await ref.read(syncRemindersUseCaseProvider).call();
  }
}

final reminderPermissionProvider =
    AsyncNotifierProvider<ReminderPermissionNotifier, ReminderPermissionStatus>(
      ReminderPermissionNotifier.new,
    );
