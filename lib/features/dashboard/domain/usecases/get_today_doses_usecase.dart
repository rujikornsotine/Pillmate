import '../../../../core/utils/result.dart';
import '../../../history/domain/entities/medication_history.dart';
import '../../../history/domain/repositories/medication_history_repository.dart';
import '../../../medication/domain/entities/medication.dart';
import '../../../medication/domain/repositories/medication_repository.dart';
import '../../../reminder/domain/entities/schedule.dart';
import '../../../reminder/domain/repositories/schedule_repository.dart';
import '../../../reminder/domain/services/schedule_occurrence_calculator.dart';
import '../entities/medication_dose.dart';

/// รวบรวมมื้อยาทั้งหมดที่ต้องรับประทานในวันนี้ จากทุกตารางยาที่ยังใช้งานอยู่
/// พร้อมสถานะการทานจากประวัติ เรียงตามเวลาที่ต้องทาน
class GetTodayDosesUseCase {
  GetTodayDosesUseCase({
    required ScheduleRepository scheduleRepository,
    required MedicationRepository medicationRepository,
    required MedicationHistoryRepository historyRepository,
  }) : _scheduleRepository = scheduleRepository,
       _medicationRepository = medicationRepository,
       _historyRepository = historyRepository;

  final ScheduleRepository _scheduleRepository;
  final MedicationRepository _medicationRepository;
  final MedicationHistoryRepository _historyRepository;

  Future<Result<List<MedicationDose>>> call() async {
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

    final historyResult = await _historyRepository.getHistory();
    List<MedicationHistory> history = const [];
    historyResult.when(
      success: (data) => history = data,
      failure: (message) => loadError = message,
    );
    if (loadError != null) return Result.failure(loadError!);

    return Result.success(
      _buildDoses(schedules!, medications!, history),
    );
  }

  List<MedicationDose> _buildDoses(
    List<Schedule> schedules,
    List<Medication> medications,
    List<MedicationHistory> history,
  ) {
    final medicationsById = {for (final m in medications) m.id: m};
    final statusByDoseKey = _statusByDoseKey(history);

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final doses = <MedicationDose>[];
    for (final schedule in schedules) {
      if (!schedule.isActive) continue;
      final medication = medicationsById[schedule.medicationId];
      if (medication == null) continue;

      final occurrences = ScheduleOccurrenceCalculator.calculate(
        schedule,
        from: startOfToday,
        windowDays: 1,
      );
      for (final occurrence in occurrences) {
        // กันมื้อของวันพรุ่งนี้ที่อาจติดมาจากขอบหน้าต่าง 1 วัน
        if (occurrence.year != startOfToday.year ||
            occurrence.month != startOfToday.month ||
            occurrence.day != startOfToday.day) {
          continue;
        }
        doses.add(
          MedicationDose(
            medication: medication,
            scheduledAt: occurrence,
            status: statusByDoseKey[ScheduleOccurrenceCalculator.doseKey(
              medication.id,
              occurrence,
            )],
          ),
        );
      }
    }

    doses.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return doses;
  }

  /// สร้าง map จากคีย์มื้อยาไปยังสถานะล่าสุด โดยให้สถานะ "ทานแล้ว" มีความสำคัญสูงสุด
  /// (ถ้ามื้อหนึ่งเคยถูกเลื่อนแล้วภายหลังยืนยันว่าทานแล้ว ให้ถือว่าทานแล้ว)
  Map<String, IntakeStatus> _statusByDoseKey(
    List<MedicationHistory> history,
  ) {
    final result = <String, IntakeStatus>{};
    for (final record in history) {
      final key = ScheduleOccurrenceCalculator.doseKey(
        record.medicationId,
        record.scheduledAt,
      );
      if (result[key] == IntakeStatus.taken) continue;
      result[key] = record.status;
    }
    return result;
  }
}
