import '../../../../core/utils/result.dart';
import '../../../history/domain/entities/medication_history.dart';
import '../../../history/domain/repositories/medication_history_repository.dart';
import '../../../medication/domain/entities/medication.dart';
import '../../../medication/domain/repositories/medication_repository.dart';
import '../entities/schedule.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/schedule_repository.dart';
import '../services/schedule_occurrence_calculator.dart';

/// คำนวณและตั้งเวลาแจ้งเตือนใหม่ทั้งหมดจากตารางยาที่ยังใช้งานอยู่
///
/// ล้างการแจ้งเตือนเดิมทั้งหมดก่อนแล้วตั้งใหม่จากข้อมูลปัจจุบันเสมอ (แอปนี้ใช้
/// การแจ้งเตือนสำหรับยาเพียงอย่างเดียว จึงไม่มีการแจ้งเตือนประเภทอื่นที่ต้องรักษาไว้)
/// ต้องเรียกทุกครั้งที่แอปเปิดขึ้นมา และทุกครั้งที่มีการแก้ไขยาหรือตารางยา
///
/// มื้อที่ผู้ใช้ยืนยันการทานไปแล้ว (มีประวัติสถานะ taken) จะถูกข้าม ไม่ตั้งแจ้งเตือน
/// ซ้ำ เพื่อให้การกด "ทานแล้ว" ในแอปมีผลถาวรแม้จะ sync ใหม่หลายครั้ง
class SyncRemindersUseCase {
  SyncRemindersUseCase({
    required ReminderRepository reminderRepository,
    required ScheduleRepository scheduleRepository,
    required MedicationRepository medicationRepository,
    required MedicationHistoryRepository historyRepository,
  }) : _reminderRepository = reminderRepository,
       _scheduleRepository = scheduleRepository,
       _medicationRepository = medicationRepository,
       _historyRepository = historyRepository;

  final ReminderRepository _reminderRepository;
  final ScheduleRepository _scheduleRepository;
  final MedicationRepository _medicationRepository;
  final MedicationHistoryRepository _historyRepository;

  Future<Result<void>> call() async {
    final schedulesResult = await _scheduleRepository.getSchedules();
    List<Schedule>? schedules;
    String? loadError;
    schedulesResult.when(
      success: (data) => schedules = data,
      failure: (message) => loadError = message,
    );
    if (loadError != null) return Result.failure(loadError!);

    final medicationsResult = await _medicationRepository.getMedications();
    List<Medication>? medications;
    medicationsResult.when(
      success: (data) => medications = data,
      failure: (message) => loadError = message,
    );
    if (loadError != null) return Result.failure(loadError!);

    // โหลดประวัติเพื่อสร้างชุดคีย์ของมื้อที่ทานแล้ว ถ้าโหลดไม่ได้ให้ถือว่าไม่มีมื้อ
    // ที่ทานแล้ว (ยอมแจ้งเตือนซ้ำดีกว่าไม่แจ้งเตือนเลยเมื่อยังจำเป็น)
    final historyResult = await _historyRepository.getHistory();
    final takenDoseKeys = <String>{};
    historyResult.when(
      success: (records) {
        for (final record in records) {
          if (record.status == IntakeStatus.taken) {
            takenDoseKeys.add(
              ScheduleOccurrenceCalculator.doseKey(
                record.medicationId,
                record.scheduledAt,
              ),
            );
          }
        }
      },
      failure: (_) {},
    );

    return _syncAll(schedules!, medications!, takenDoseKeys);
  }

  Future<Result<void>> _syncAll(
    List<Schedule> schedules,
    List<Medication> medications,
    Set<String> takenDoseKeys,
  ) async {
    final cancelResult = await _reminderRepository.cancelAllReminders();
    if (cancelResult.isFailure) return cancelResult;

    final medicationsById = {for (final m in medications) m.id: m};
    final now = DateTime.now();

    for (final schedule in schedules) {
      if (!schedule.isActive) continue;
      if (schedule.endDate != null && schedule.endDate!.isBefore(now)) {
        continue;
      }
      final medication = medicationsById[schedule.medicationId];
      if (medication == null) continue;

      await _reminderRepository.scheduleReminders(
        schedule: schedule,
        medication: medication,
        takenDoseKeys: takenDoseKeys,
      );
    }

    return const Result.success(null);
  }
}
