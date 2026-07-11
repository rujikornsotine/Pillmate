import '../../../../core/constants/reminder_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/result.dart';
import '../../../medication/domain/entities/medication.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/services/schedule_occurrence_calculator.dart';

/// Implementation ของ ReminderRepository ที่ใช้ NotificationService ในการแจ้งเตือนจริง
class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({required NotificationService notificationService})
    : _notificationService = notificationService;

  final NotificationService _notificationService;

  @override
  Future<Result<bool>> requestPermission() async {
    try {
      final granted = await _notificationService.requestPermission();
      return Result.success(granted);
    } catch (e) {
      return Result.failure('ไม่สามารถขอสิทธิ์การแจ้งเตือนได้: $e');
    }
  }

  @override
  Future<Result<void>> cancelAllReminders() async {
    try {
      await _notificationService.cancelAll();
      return const Result.success(null);
    } catch (e) {
      return Result.failure('ไม่สามารถยกเลิกการแจ้งเตือนได้: $e');
    }
  }

  @override
  Future<Result<void>> cancelDoseReminder({
    required String medicationId,
    required DateTime occurrence,
  }) async {
    try {
      await _notificationService.cancelDoseReminder(
        medicationId: medicationId,
        occurrence: occurrence,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure('ไม่สามารถยกเลิกการแจ้งเตือนของมื้อยาได้: $e');
    }
  }

  @override
  Future<Result<void>> scheduleReminders({
    required Schedule schedule,
    required Medication medication,
    Set<String> takenDoseKeys = const {},
  }) async {
    try {
      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: DateTime.now(),
        windowDays: ReminderConstants.syncWindowDays,
      );
      for (final occurrence in occurrences) {
        // ข้ามมื้อที่ผู้ใช้ยืนยันการทานไปแล้ว จะได้ไม่แจ้งเตือนซ้ำ
        final key = ScheduleOccurrenceCalculator.doseKey(
          medication.id,
          occurrence,
        );
        if (takenDoseKeys.contains(key)) continue;

        await _notificationService.scheduleDoseReminder(
          medicationId: medication.id,
          occurrence: occurrence,
          medicationName: medication.name,
          dosage: medication.dosage,
          quantity: medication.quantity,
        );
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure('ไม่สามารถตั้งเวลาแจ้งเตือนได้: $e');
    }
  }
}
