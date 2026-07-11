import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../../history/presentation/providers/medication_history_providers.dart';
import '../../../medication/presentation/providers/medication_providers.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/repositories/reminder_repository.dart';
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
